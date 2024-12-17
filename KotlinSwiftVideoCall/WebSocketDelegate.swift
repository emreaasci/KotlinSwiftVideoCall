// WebSocketManager.swift
import Foundation
import Starscream

protocol WebSocketDelegate: AnyObject {
    func onNewMessage(message: MessageModel)
}

class WebSocketManager {
    private var socket: WebSocket?
    weak var delegate: WebSocketDelegate?
    
    func initSocket(username: String) {
        guard let url = URL(string: "ws://10.0.2.2:3000") else { return }
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

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            print("WebSocket Connected")
            
        case .text(let string):
            if let data = string.data(using: .utf8),
               let message = try? JSONDecoder().decode(MessageModel.self, from: data) {
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