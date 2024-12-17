//
//  IceCandidateModel.swift
//  KotlinSwiftVideoCall
//
//  Created by Emre Aşcı on 16.12.2024.
//


// IceCandidateModel.swift
struct IceCandidateModel: Codable {
    let sdpMid: String
    let sdpMLineIndex: Double
    let sdpCandidate: String
}
