//
//  WebRTCManager.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//


import Foundation
import WebRTC
import CoreMedia

class WebRTCManager: NSObject {
    public var peerConnection: RTCPeerConnection?
    private let factory: RTCPeerConnectionFactory
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = RTCMediaConstraints(mandatoryConstraints: nil,
                                                    optionalConstraints: nil)
    
    private var videoCapturer: RTCCameraVideoCapturer?
    public private(set) var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    
    weak var delegate: WebRTCManagerDelegate?
    
    override init() {
        RTCInitializeSSL()
        factory = RTCPeerConnectionFactory()
        super.init()
        
        configure()
    }
    
    private func configure() {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"])
        ]
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                            optionalConstraints: nil)
        
        let connection = factory.peerConnection(with: config, constraints: constraints, delegate: self)
        self.peerConnection = connection
        
        setupAudioSession()
        setupLocalTracks()
    }
    
    private func setupAudioSession() {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.setMode(AVAudioSession.Mode.videoChat.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Error setting up audio session:", error)
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // WebRTCManager.swift içine eklenecek
    func endCall() {
        // Mevcut bağlantıyı kapat
        peerConnection?.close()
        peerConnection = nil
        
        // Video ve ses izlerini temizle
        localVideoTrack?.isEnabled = false
        localVideoTrack = nil
        remoteVideoTrack?.isEnabled = false
        remoteVideoTrack = nil
        
        // Video yakalayıcıyı durdur
        videoCapturer?.stopCapture()
        videoCapturer = nil
        
        // Ses oturumunu resetle
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setActive(false)
            } catch let error {
                debugPrint("Error stopping audio session:", error)
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setupLocalTracks() {
        let streamId = "local-stream"
        
        // Audio Track
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil,
                                                optionalConstraints: nil)
        let audioSource = factory.audioSource(with: audioConstrains)
        let audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        
        // Video Track
        let videoSource = factory.videoSource()
        
        #if !targetEnvironment(simulator)
        let capturer = RTCCameraVideoCapturer(delegate: videoSource)
        self.videoCapturer = capturer
        
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == .front }),
            let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted(by: {
                let dimensions1 = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
                let dimensions2 = CMVideoFormatDescriptionGetDimensions($1.formatDescription)
                return dimensions1.width * dimensions1.height < dimensions2.width * dimensions2.height
            }).last,
            let fps = format.videoSupportedFrameRateRanges.first else {
            return
        }
        
        capturer.startCapture(with: frontCamera,
                            format: format,
                            fps: Int(fps.maxFrameRate))
        #endif
        
        let videoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
        self.localVideoTrack = videoTrack
        
        if let videoTrack = self.localVideoTrack {
            delegate?.webRTCManager(self, didUpdateLocalVideo: videoTrack)
        }
        
        // Add tracks to peer connection
        peerConnection?.add(audioTrack, streamIds: [streamId])
        peerConnection?.add(videoTrack, streamIds: [streamId])
    }
    
    func createOffer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                            optionalConstraints: nil)
        
        peerConnection?.offer(for: constraints) { [weak self] sdp, error in
            guard let self = self, let sdp = sdp else {
                return
            }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { error in
                if let error = error {
                    print("Error setting local description:", error)
                }
            })
        }
    }
    
    func toggleVideo(enabled: Bool) {
        if let localVideoTrack = self.localVideoTrack {
            localVideoTrack.isEnabled = enabled
        }
    }
    
    func toggleAudio(enabled: Bool) {
        if let audioTrack = peerConnection?.transceivers.first(where: { $0.mediaType == .audio })?.sender.track as? RTCAudioTrack {
            audioTrack.isEnabled = enabled
        }
    }
    
    func speakerOn(enabled: Bool) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.overrideOutputAudioPort(enabled ? .speaker : .none)
            } catch let error {
                debugPrint("Error toggling speaker:", error)
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    
    
    func handleRemoteOffer(_ sessionDescription: RTCSessionDescription) {
            print("Received offer:", sessionDescription.sdp)
            peerConnection?.setRemoteDescription(sessionDescription) { [weak self] error in
                if let error = error {
                    print("Error setting remote description: \(error)")
                    return
                }
                print("Remote description set successfully") // Debug
                
                // Create answer
                let constraints = RTCMediaConstraints(
                    mandatoryConstraints: ["OfferToReceiveVideo": "true", "OfferToReceiveAudio": "true"],
                    optionalConstraints: nil
                )
                
                self?.peerConnection?.answer(for: constraints) { [weak self] sdp, error in
                    if let error = error {
                        print("Error creating answer: \(error)")
                        return
                    }
                    
                    guard let sdp = sdp else { return }
                    print("Created answer successfully") // Debug
                    
                    self?.peerConnection?.setLocalDescription(sdp) { error in
                        if let error = error {
                            print("Error setting local description: \(error)")
                            return
                        }
                        print("Local description set successfully") // Debug
                        self?.delegate?.webRTCManager(self!, didCreateAnswer: sdp)
                    }
                }
            }
        }

    func handleRemoteAnswer(_ sessionDescription: RTCSessionDescription) {
            print("Handling remote answer") // Debug
            peerConnection?.setRemoteDescription(sessionDescription) { error in
                if let error = error {
                    print("Error setting remote answer: \(error)")
                } else {
                    print("Remote answer set successfully") // Debug
                }
            }
        }

        
    func handleRemoteCandidate(_ iceCandidate: RTCIceCandidate) {
            print("Adding ICE candidate:", iceCandidate.sdp)
            peerConnection?.add(iceCandidate)
        }
}

extension WebRTCManager: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
        if let videoTrack = stream.videoTracks.first {
            self.remoteVideoTrack = videoTrack
            delegate?.webRTCManager(self, didUpdateRemoteVideo: videoTrack)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
            let iceCandidate = IceCandidateModel(
                sdpMid: candidate.sdpMid,
                sdpMLineIndex: candidate.sdpMLineIndex,
                sdpCandidate: candidate.sdp
            )
            
            delegate?.webRTCManager(self, didGenerateIceCandidate: iceCandidate)
        }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
    
    
    
    
}
