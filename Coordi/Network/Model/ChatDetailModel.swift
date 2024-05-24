//
//  ChatDetailModel.swift
//  Coordi
//
//  Created by 차소민 on 5/25/24.
//

import Foundation

struct ChatDetailModel: Decodable {
    let chat_id: String
    let room_id: String
    let content: String?
    let createdAt: String
    let sender: UserModel
    let files: [String]
    
    enum CodingKeys: CodingKey {
        case chat_id
        case room_id
        case content
        case createdAt
        case sender
        case files
    }
    
    init(chat_id: String, room_id: String, content: String?, createdAt: String, sender: UserModel, files: [String]) {
        self.chat_id = chat_id
        self.room_id = room_id
        self.content = content
        self.createdAt = createdAt
        self.sender = sender
        self.files = files
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chat_id = try container.decode(String.self, forKey: .chat_id)
        self.room_id = try container.decode(String.self, forKey: .room_id)
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.sender = try container.decode(UserModel.self, forKey: .sender)
        self.files = try container.decode([String].self, forKey: .files)
    }
    
    static var dummy: ChatDetailModel {
        return .init(chat_id: "", room_id : "", content: "", createdAt: "", sender: .dummy, files: [])
    }
    

}
