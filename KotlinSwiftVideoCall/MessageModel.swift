// MessageModel.swift
struct MessageModel: Codable {
    let type: String
    let name: String?
    let target: String?
    let data: AnyCodable?
}