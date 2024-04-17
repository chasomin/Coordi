//
//  ProfileModel.swift
//  Coordi
//
//  Created by 차소민 on 4/14/24.
//

import Foundation

struct ProfileModel: Decodable, Hashable {
    let user_id: String
    let email: String
    let nick: String
    let phoneNum: String
    let birthDay: String
    let profileImage: String
    let followers: [UserModel]
    let following: [UserModel]
    let posts: [String]
    
    enum CodingKeys: CodingKey {
        case user_id
        case email
        case nick
        case phoneNum
        case birthDay
        case profileImage
        case followers
        case following
        case posts
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum) ?? ""
        self.birthDay = try container.decodeIfPresent(String.self, forKey: .birthDay) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.followers = try container.decode([UserModel].self, forKey: .followers)
        self.following = try container.decode([UserModel].self, forKey: .following)
        self.posts = try container.decode([String].self, forKey: .posts)
    }
}
