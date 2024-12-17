// CallViewModel.swift
import Foundation
import Combine

class CallViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var username = ""
    @Published var targetUsername = ""
    @Published var isMicEnabled = true
    @Published var isCameraEnabled = true
    @Published var isSpeakerEnabled = true
    
    private let webRTCManager = WebRTCManager()
    
    init() {
        webRTCManager.delegate = self
    }
    
    func startCall() {
        webRTCManager.createOffer()
    }
    
    func toggleMicrophone() {
        isMicEnabled.toggle()
        // Implement microphone toggle
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        // Implement camera toggle
    }
    
    func toggleSpeaker() {
        isSpeakerEnabled.toggle()
        // Implement speaker toggle
    }
}

extension CallViewModel: WebRTCManagerDelegate {
    func webRTCManager(_ manager: WebRTCManager, didUpdateLocalVideo video: RTCVideoTrack) {
        // Handle local video update
    }
    
    func webRTCManager(_ manager: WebRTCManager, didUpdateRemoteVideo video: RTCVideoTrack) {
        // Handle remote video update
    }
    
    func webRTCManager(_ manager: WebRTCManager, didReceiveError error: Error) {
        // Handle error
    }
}