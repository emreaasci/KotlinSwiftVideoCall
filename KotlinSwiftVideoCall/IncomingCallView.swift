//
//  IncomingCallView.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//



import SwiftUI

// Yeni View: Gelen arama ekranı
struct IncomingCallView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.incomingCallName) is calling...")
                .font(.title)
            
            HStack(spacing: 50) {
                Button(action: { viewModel.acceptCall() }) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                
                Button(action: { viewModel.rejectCall() }) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
    }
}
