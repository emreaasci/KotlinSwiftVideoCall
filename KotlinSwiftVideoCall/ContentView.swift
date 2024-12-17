//
//  ContentView.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CallViewModel()
    
    
    
    var body: some View {
            if !viewModel.isConnected {
                LoginView(viewModel: viewModel)
            } else if viewModel.isIncomingCall {  // Yeni durum kontrolü
                IncomingCallView(viewModel: viewModel)
            } else {
                CallView(viewModel: viewModel)
            }
        }
}

struct LoginView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Connect") {
                viewModel.connect()
            }
            .disabled(viewModel.username.isEmpty)
            .padding()
        }
        .padding()
    }
}

struct CallView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack {
            if viewModel.localVideoTrack == nil {
                // Call initiation view
                VStack(spacing: 20) {
                    TextField("Target username", text: $viewModel.targetUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Start Call") {
                        viewModel.startCall()
                    }
                    .disabled(viewModel.targetUsername.isEmpty)
                    .padding()
                }
            } else {
                // Video call view
                ZStack {
                    VideoView(videoTrack: viewModel.remoteVideoTrack)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VideoView(videoTrack: viewModel.localVideoTrack)
                        .frame(width: 120, height: 160)
                        .cornerRadius(10)
                        .position(x: UIScreen.main.bounds.width - 80, y: 50)
                    
                    VStack {
                        Spacer()
                        HStack(spacing: 20) {
                            Button(action: { viewModel.toggleMicrophone() }) {
                                Image(systemName: viewModel.isMicEnabled ? "mic.fill" : "mic.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: { viewModel.toggleCamera() }) {
                                Image(systemName: viewModel.isCameraEnabled ? "video.fill" : "video.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: { viewModel.toggleSpeaker() }) {
                                Image(systemName: viewModel.isSpeakerEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: { viewModel.endCall() }) {
                                Image(systemName: "phone.down.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
