//
//  MessageModel.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//

import Foundation

// MessageModel.swift
struct MessageModel: Codable {
    let type: String
    let name: String?
    let target: String?
    let data: AnyCodable?
}
