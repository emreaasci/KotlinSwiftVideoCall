// VideoView.swift
import SwiftUI
import WebRTC

struct VideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack?
    
    func makeUIView(context: Context) -> RTCEAGLVideoView {
        let videoView = RTCEAGLVideoView()
        videoView.contentMode = .scaleAspectFill
        if let videoTrack = videoTrack {
            videoTrack.add(videoView)
        }
        return videoView
    }
    
    func updateUIView(_ uiView: RTCEAGLVideoView, context: Context) {
    }
}
