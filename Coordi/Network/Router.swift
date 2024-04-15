//
//  Router.swift
//  Coordi
//
//  Created by 차소민 on 4/14/24.
//

import Foundation
import Alamofire

enum Router {
    case signUp(query: SignUpQuery)
    case emailValidation(query: SignUpQuery)
    case logIn(query: LogInQuery)
    case refreshToken
    case withdraw
    case uploadImage(query: ImageUploadQuery)
    case uploadPost(query: PostQuery)
    case fetchPost(query: FetchPostQuery)
    case fetchParticularPost(postId: String)
    case editPost(postId: String, query: PostQuery)
    case deletePost(postId: String)
    case fetchPostByUser(userId: String, query: FetchPostQuery)
    case uploadComment(postId: String, query: CommentQuery)
    case editComment(postId: String, commentId: String, query: CommentQuery)
    case deleteComment(postId: String, commentId: String)
    case like(postId: String, query: LikeQuery)
    case fetchLikePost(query: FetchPostQuery)
    case follow(userId: String)
    case deleteFollow(userId: String)
    case fetchMyProfile
    case editProfile(query: ProfileQuery)
    case fetchUserProfile(userId: String)
    case hashtag(query: FetchPostQuery)
}

extension Router: TargetType {
    var baseURL: String {
        BaseURL.baseURL.rawValue + BaseURL.version.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .logIn:
            return .post
        case .signUp:
            return .post
        case .emailValidation:
            return .post
        case .refreshToken:
            return .get
        case .withdraw:
            return .get
        case .uploadImage:
            return .post
        case .uploadPost:
            return .post
        case .fetchPost:
            return .get
        case .fetchParticularPost:
            return .get
        case .editPost:
            return .put
        case .deletePost:
            return .delete
        case .fetchPostByUser:
            return .get
        case .uploadComment:
            return .post
        case .editComment:
            return .put
        case .deleteComment:
            return .delete
        case .like:
            return .post
        case .fetchLikePost:
            return .get
        case .follow:
            return .post
        case .deleteFollow:
            return .delete
        case .fetchMyProfile:
            return .get
        case .editProfile:
            return .put
        case .fetchUserProfile:
            return .get
        case .hashtag:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .logIn:
            "/users/login"
        case .signUp:
            "/users/join"
        case .emailValidation:
            "/validation/email"
        case .refreshToken:
            "/auth/refresh"
        case .withdraw:
            "/users/withdraw"
        case .uploadImage:
            "/posts/files"
        case .uploadPost:
            "/posts"
        case .fetchPost:
            "/posts"
        case .fetchParticularPost(let id):
            "/posts/\(id)"
        case .editPost(let id, _):
            "/posts/\(id)"
        case .deletePost(let id):
            "/posts/\(id)"
        case .fetchPostByUser(let id, _):
            "/posts/users/\(id)"
        case .uploadComment(let id, _):
            "/posts/\(id)/comments"
        case .editComment(let postId, let commentId, _):
            "/posts/\(postId)/comments/\(commentId)"
        case .deleteComment(let postId, let commentId):
            "/posts/\(postId)/comments/\(commentId)"
        case .like(let id, _):
            "/posts/\(id)/like"
        case .fetchLikePost:
            "/posts/likes/me"
        case .follow(let id):
            "/follow/\(id)"
        case .deleteFollow(let id):
            "/follow/\(id)"
        case .fetchMyProfile:
            "/users/me/profile"
        case .editProfile:
            "/users/me/profile"
        case .fetchUserProfile(let id):
            "/users/\(id)/profile"
        case .hashtag:
            "/posts/hashtags"
        }
    }
    
    var header: [String: String] {
        switch self {
        case .logIn:
            [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .signUp:
            [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .emailValidation:
            [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .refreshToken:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue,
                HTTPHeader.refresh.rawValue: UserDefaults.standard.string(forKey: "refreshToken") ?? ""
            ]
        case .withdraw:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .uploadImage:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .uploadPost:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .fetchPost:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .fetchParticularPost:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .editPost:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .deletePost:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .fetchPostByUser:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .uploadComment:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .editComment:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .deleteComment:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .like:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .fetchLikePost:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .follow:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .deleteFollow:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .fetchMyProfile:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .editProfile:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .fetchUserProfile:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .hashtag:
            [
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .fetchPost(let query):
            [
                "next": query.next,
                "limit": query.limit,
                "product_id": query.product_id
            ]
        case .fetchPostByUser(_, let query):
            [
                "next": query.next,
                "limit": query.limit,
                "product_id": query.product_id
            ]
        case .fetchLikePost(let query):
            [
                "next": query.next,
                "limit": query.limit
            ]
        case .hashtag(let query):
            [
                "next": query.next,
                "limit": query.limit,
                "product_id": query.product_id,
                "hashTag": query.hashTag
            ]
        default:
            nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var body: Data? {
        switch self {
        case .logIn(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .signUp(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .emailValidation(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .refreshToken:
            return nil
        case .withdraw:
            return nil
        case .uploadImage(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .uploadPost(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .fetchPost:
            return nil
        case .fetchParticularPost:
            return nil
        case .editPost(_, let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .deletePost:
            return nil
        case .fetchPostByUser:
            return nil
        case .uploadComment(_, let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .editComment(_, _, let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .deleteComment:
            return nil
        case .like(_, let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .fetchLikePost:
            return nil
        case .follow:
            return nil
        case .deleteFollow:
            return nil
        case .fetchMyProfile:
            return nil
        case .editProfile(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .fetchUserProfile:
            return nil
        case .hashtag:
            return nil
        }
    }
}
