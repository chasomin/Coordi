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
    
    init(user_id: String, email: String, nick: String, phoneNum: String, birthDay: String, profileImage: String, followers: [UserModel], following: [UserModel], posts: [String]) {
        self.user_id = user_id
        self.email = email
        self.nick = nick
        self.phoneNum = phoneNum
        self.birthDay = birthDay
        self.profileImage = profileImage
        self.followers = followers
        self.following = following
        self.posts = posts
    }
    
    static var dummy: ProfileModel {
        return .init(user_id: "String", email: "", nick: "", phoneNum: "", birthDay: "", profileImage: "", followers: [], following: [], posts: [])
    }
}
