// CallViewModel.swift
import Foundation
import WebRTC
import SwiftUI

class CallViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var username = ""
    @Published var targetUsername = ""
    @Published var isMicEnabled = true
    @Published var isCameraEnabled = true
    @Published var isSpeakerEnabled = true
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?
    
    
    @Published var isIncomingCall = false
    @Published var incomingCallName = ""
    
    private let webRTCManager = WebRTCManager()
    private var socketManager = WebSocketManager()
    
    init() {
        webRTCManager.delegate = self
        socketManager.delegate = self
    }
    
    func connect() {
        socketManager.initSocket(username: username)
        
        let message = MessageModel(
            type: "store_user",
            name: username,
            target: nil,
            data: nil
        )
        socketManager.sendMessageToSocket(message: message)
        isConnected = true
    }
    
    func startCall() {
        let message = MessageModel(
            type: "start_call",
            name: username,
            target: targetUsername,
            data: nil
        )
        socketManager.sendMessageToSocket(message: message)
    }
    
    func toggleMicrophone() {
        isMicEnabled.toggle()
        webRTCManager.toggleAudio(enabled: isMicEnabled)
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        webRTCManager.toggleVideo(enabled: isCameraEnabled)
    }
    
    func toggleSpeaker() {
        isSpeakerEnabled.toggle()
        webRTCManager.speakerOn(enabled: isSpeakerEnabled)
    }
    
    func endCall() {
        webRTCManager.endCall()
        localVideoTrack = nil
        remoteVideoTrack = nil
    }
    
    
    func acceptCall() {
            isIncomingCall = false
            // Video tracks'ı başlat
            if let videoTrack = webRTCManager.localVideoTrack {
                self.localVideoTrack = videoTrack
            }
        }
        
        func rejectCall() {
            isIncomingCall = false
            incomingCallName = ""
        }
}

extension CallViewModel: WebRTCManagerDelegate {
    func webRTCManager(_ manager: WebRTCManager, didUpdateLocalVideo video: RTCVideoTrack) {
        DispatchQueue.main.async {
            self.localVideoTrack = video
        }
    }
    
    func webRTCManager(_ manager: WebRTCManager, didUpdateRemoteVideo video: RTCVideoTrack) {
        DispatchQueue.main.async {
            self.remoteVideoTrack = video
        }
    }
    
    func webRTCManager(_ manager: WebRTCManager, didReceiveError error: Error) {
        print("WebRTC Error:", error)
    }
    
    func webRTCManager(_ manager: WebRTCManager, didGenerateIceCandidate candidate: IceCandidateModel) {
        if let jsonData = try? JSONEncoder().encode(candidate),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let message = MessageModel(
                type: "ice_candidate",
                name: username,
                target: targetUsername,
                data: jsonString
            )
            socketManager.sendMessageToSocket(message: message)
        }
    }
    func webRTCManager(_ manager: WebRTCManager, didCreateAnswer sdp: RTCSessionDescription) {
            print("Sending answer to remote peer") // Debug
            let message = MessageModel(
                type: "create_answer",
                name: username,
                target: targetUsername,
                data: sdp.sdp
            )
            socketManager.sendMessageToSocket(message: message)
        }
    
    
}

extension CallViewModel: WebSocketDelegate {
    func onNewMessage(message: MessageModel) {
        print("Received message type:", message.type)
        print("Message data:", message.data)
        print("Processing message:", message) // Debug için
        
        DispatchQueue.main.async {
            switch message.type {
            case "call_response":
                print("Call response received:", message.data ?? "") // Debug için
                if message.data == "user is ready for call" {
                    self.webRTCManager.createOffer()
                }
                            
            case "offer_received":
                print("Offer received from:", message.name ?? "unknown")
                self.isIncomingCall = true  // Bunu true yaparak gelen arama ekranını gösteriyoruz
                self.incomingCallName = message.name ?? "unknown"
                self.targetUsername = message.name ?? ""
                
                if let sdp = message.data {
                    let sessionDescription = RTCSessionDescription(type: .offer, sdp: sdp)
                    self.webRTCManager.handleRemoteOffer(sessionDescription)
                }
                            
            case "answer_received":
                print("Answer received") // Debug için
                if let sdpString = message.data {
                let sessionDescription = RTCSessionDescription(type: .answer, sdp: sdpString)
                    self.webRTCManager.handleRemoteAnswer(sessionDescription)
                }
                            
            case "ice_candidate":
                print("ICE candidate received") // Debug için
                if let dataString = message.data,
                   let data = dataString.data(using: .utf8),
                   let candidate = try? JSONDecoder().decode(IceCandidateModel.self, from: data) {
                    let iceCandidate = RTCIceCandidate(
                        sdp: candidate.sdpCandidate,
                        sdpMLineIndex: candidate.sdpMLineIndex,
                        sdpMid: candidate.sdpMid ?? ""
                    )
                    self.webRTCManager.handleRemoteCandidate(iceCandidate)
                }
                            
            default:
                print("Unknown message type:", message.type)
            }
        }
    }
}
