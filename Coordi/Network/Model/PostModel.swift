//
//  PostModel.swift
//  Coordi
//
//  Created by 차소민 on 4/13/24.
//

import Foundation

struct PostModel: Decodable, Hashable {

    let post_id: String
    let product_id: String
    let title: String
    let content: String
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let content5: String
    let createdAt: String
    let creator: UserModel
    let files: [String]
    let likes: [String]
    let likes2: [String]
    let hashTags: [String]
    var comments: [CommentModel]
    
    var temp: String {
        let count = hashTags.count
        return hashTags[count / 2] + "℃"
    }
    
    var tempNum: Int {
        Int(content.dropFirst()) ?? 0
    }
    
    enum CodingKeys: CodingKey {
        case post_id
        case product_id
        case title
        case content
        case content1
        case content2
        case content3
        case content4
        case content5
        case createdAt
        case creator
        case files
        case likes
        case likes2
        case hashTags
        case comments
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.post_id = try container.decode(String.self, forKey: .post_id)
        self.product_id = try container.decodeIfPresent(String.self, forKey: .product_id) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.content1 = try container.decodeIfPresent(String.self, forKey: .content1) ?? ""
        self.content2 = try container.decodeIfPresent(String.self, forKey: .content2) ?? ""
        self.content3 = try container.decodeIfPresent(String.self, forKey: .content3) ?? ""
        self.content4 = try container.decodeIfPresent(String.self, forKey: .content4) ?? ""
        self.content5 = try container.decodeIfPresent(String.self, forKey: .content5) ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(UserModel.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.likes2 = try container.decode([String].self, forKey: .likes2)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.comments = try container.decode([CommentModel].self, forKey: .comments)
    }
    
    init(post_id: String, product_id: String, title: String, content: String, content1: String, content2: String, content3: String, content4: String, content5: String, createdAt: String, creator: UserModel, files: [String], likes: [String], likes2: [String], hashTags: [String], comments: [CommentModel]) {
        self.post_id = post_id
        self.product_id = product_id
        self.title = title
        self.content = content
        self.content1 = content1
        self.content2 = content2
        self.content3 = content3
        self.content4 = content4
        self.content5 = content5
        self.createdAt = createdAt
        self.creator = creator
        self.files = files
        self.likes = likes
        self.likes2 = likes2
        self.hashTags = hashTags
        self.comments = comments
    }
    
    static var dummy: PostModel {
        return .init(post_id: "", product_id: "", title: "", content: "", content1: "", content2: "", content3: "", content4: "", content5: "", createdAt: "", creator: UserModel.dummy, files: [], likes: [], likes2: [], hashTags: [], comments: [])
    }

}


struct UserModel: Decodable, Hashable {
    let user_id: String
    let nick: String
    let profileImage: String
    
    init(user_id: String, nick: String, profileImage: String) {
        self.user_id = user_id
        self.nick = nick
        self.profileImage = profileImage
    }
    
    enum CodingKeys: CodingKey {
        case user_id
        case nick
        case profileImage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
    }
    
    static var dummy: UserModel {
        return .init(user_id: "", nick: "", profileImage: "")
    }
}
