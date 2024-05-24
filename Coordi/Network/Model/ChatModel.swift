//
//  ChatModel.swift
//  Coordi
//
//  Created by 차소민 on 5/25/24.
//

import Foundation

struct ChatModel: Decodable {
    let room_id: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserModel]
    let lastChat: ChatDetailModel?
    
    enum CodingKeys: CodingKey {
        case room_id
        case createdAt
        case updatedAt
        case participants
        case lastChat
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.room_id = try container.decode(String.self, forKey: .room_id)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.participants = try container.decode([UserModel].self, forKey: .participants)
        self.lastChat = try container.decodeIfPresent(ChatDetailModel.self, forKey: .lastChat) ?? ChatDetailModel.dummy
    }
}
