//
//  PostListModel.swift
//  Coordi
//
//  Created by 차소민 on 4/13/24.
//

import Foundation

struct PostListModel: Decodable {
    var data: [PostModel]
    let next_cursor: String
}
