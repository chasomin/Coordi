//
//  CommentModel.swift
//  Coordi
//
//  Created by 차소민 on 4/13/24.
//

import Foundation

struct CommentModel: Decodable, Hashable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: UserModel
}
