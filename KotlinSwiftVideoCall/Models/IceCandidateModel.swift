//
//  IceCandidateModel.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//

import Foundation

struct IceCandidateModel: Codable {
    let sdpMid: String?
    let sdpMLineIndex: Int32
    let sdpCandidate: String
}
