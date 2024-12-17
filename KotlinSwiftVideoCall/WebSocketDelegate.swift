//
//  WebSocketDelegate.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//


import Foundation
import Starscream

protocol WebSocketDelegate: AnyObject {
    func onNewMessage(message: MessageModel)
}



class WebSocketManager: NSObject {
    private var socket: WebSocket?
    weak var delegate: WebSocketDelegate?
    private var username: String?
    
    func initSocket(username: String) {
            self.username = username // username'i sakladık
            guard let url = URL(string: "ws://172.10.40.174:3000") else { return }
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        }
    
    func sendMessageToSocket(message: MessageModel) {
            do {
                let jsonData = try JSONEncoder().encode(message)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    socket?.write(string: jsonString)
                }
            } catch {
                print("Error encoding message:", error)
            }
        }
}

// WebSocket Delegate methods
extension WebSocketManager: Starscream.WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
                    print("WebSocket Connected")
                    // Şimdi username'e erişebiliriz
                    if let username = self.username {
                        let connectMessage = MessageModel(
                            type: "store_user",
                            name: username,
                            target: nil,
                            data: nil
                        )
                        sendMessageToSocket(message: connectMessage)
                    }
                    
                case .text(let string):
                    print("Received WebSocket message:", string)
                    if let data = string.data(using: .utf8),
                       let message = try? JSONDecoder().decode(MessageModel.self, from: data) {
                        print("Decoded message:", message)
                        delegate?.onNewMessage(message: message)
                    }
            
        case .disconnected(let reason, let code):
            print("WebSocket Disconnected: \(reason) with code: \(code)")
            
        case .error(let error):
            print("WebSocket Error:", error?.localizedDescription ?? "")
            
        case .viabilityChanged(let isViable):
            print("WebSocket viability changed:", isViable)
            
        default:
            break
        }
    }
}
