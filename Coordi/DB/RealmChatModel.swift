//
//  RealmChatModel.swift
//  Coordi
//
//  Created by 차소민 on 5/20/24.
//

import Foundation
import RealmSwift

final class RealmChatModel: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var roomID: String
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var sendUserID: String
    @Persisted var sendUserNickname: String
    @Persisted var sendUserProfileImage: String
    @Persisted var files: List<String>

    init(chatID: String, roomID: String, content: String, createdAt: String, sendUserID: String, sendUserNickname: String, sendUserProfileImage: String, files: List<String>) {
        super.init()
        self.chatID = chatID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.sendUserID = sendUserID
        self.sendUserNickname = sendUserNickname
        self.sendUserProfileImage = sendUserProfileImage
        self.files = files
    }
}


