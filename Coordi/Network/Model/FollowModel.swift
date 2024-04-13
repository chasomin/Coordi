//
//  FollowModel.swift
//  Coordi
//
//  Created by 차소민 on 4/14/24.
//

import Foundation

struct FollowModel: Decodable {
    let nick: String            // 나의 닉네임
    let opponent_nick: String   // 내가 팔로우한 상대 닉네임
    let following_status: Bool
}
