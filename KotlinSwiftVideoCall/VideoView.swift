//
//  VideoView.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//

// VideoView.swift
import SwiftUI
import WebRTC

struct VideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack?
    
    func makeUIView(context: Context) -> RTCEAGLVideoView {
        let videoView = RTCEAGLVideoView()
        videoView.contentMode = .scaleAspectFit
        if let videoTrack = videoTrack {
            videoTrack.add(videoView)
        }
        return videoView
    }
    
    func updateUIView(_ uiView: RTCEAGLVideoView, context: Context) {
    }
}
