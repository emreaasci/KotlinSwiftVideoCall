//
//  WebRTCManagerDelegate.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//


// WebRTCManagerDelegate.swift
import Foundation
import WebRTC

protocol WebRTCManagerDelegate: AnyObject {
    func webRTCManager(_ manager: WebRTCManager, didUpdateLocalVideo video: RTCVideoTrack)
    func webRTCManager(_ manager: WebRTCManager, didUpdateRemoteVideo video: RTCVideoTrack)
    func webRTCManager(_ manager: WebRTCManager, didReceiveError error: Error)
    func webRTCManager(_ manager: WebRTCManager, didGenerateIceCandidate candidate: IceCandidateModel)
    func webRTCManager(_ manager: WebRTCManager, didCreateAnswer sdp: RTCSessionDescription)
}

