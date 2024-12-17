// WebRTCManagerDelegate.swift
import Foundation
import WebRTC

protocol WebRTCManagerDelegate: AnyObject {
    func webRTCManager(_ manager: WebRTCManager, didUpdateLocalVideo video: RTCVideoTrack)
    func webRTCManager(_ manager: WebRTCManager, didUpdateRemoteVideo video: RTCVideoTrack)
    func webRTCManager(_ manager: WebRTCManager, didReceiveError error: Error)
}