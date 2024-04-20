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
    case editProfileNick(query: ProfileNickQuery)
    case editProfileImage(query: ProfileImageQuery)
    case fetchUserProfile(userId: String)
    case hashtag(query: FetchPostQuery)
    case fetchImage(query: String)
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
        case .editProfileNick:
            return .put
        case .editProfileImage:
            return .put
        case .fetchUserProfile:
            return .get
        case .hashtag:
            return .get
        case .fetchImage:
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
        case .editProfileNick:
            "/users/me/profile"
        case .editProfileImage:
            "/users/me/profile"
        case .fetchUserProfile(let id):
            "/users/\(id)/profile"
        case .hashtag:
            "/posts/hashtags"
        case .fetchImage(let query):
            "/\(query)"
        }
    }
    
    var header: [String: String] {
        switch self {
        case .logIn, .signUp, .emailValidation:
            return [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
        case .refreshToken:
            return [
                HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue,
                HTTPHeader.refresh.rawValue: UserDefaultsManager.refreshToken
            ]
        case .withdraw, .fetchPost, .fetchParticularPost, .deletePost, .fetchPostByUser, .deleteComment, .like, .fetchLikePost, .follow, .deleteFollow, .fetchMyProfile, .fetchUserProfile, .hashtag, .fetchImage:
            return [
                HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
            
        case .uploadImage, .editProfileNick, .editProfileImage:
            return [
                HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue
            ]
            
        case .editPost, .uploadComment, .editComment, .uploadPost:
            return [
                HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
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
                "hashTag": query.hashTag ?? ""
            ]
        case .editProfileNick(let query):
            [
                "nick": query.nick
            ]
        case .editProfileImage(let query):
            [
                "profile": query.profile
            ]
        case .uploadImage(let query):
            [
                "files":query.files
            ]
        default:
            nil
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        switch self {
        case .logIn(let query):
            return try? encoder.encode(query)
        case .signUp(let query):
            return try? encoder.encode(query)
        case .emailValidation(let query):
            return try? encoder.encode(query)
        case .uploadPost(let query):
            return try? encoder.encode(query)
        case .editPost(_, let query):
            return try? encoder.encode(query)
        case .uploadComment(_, let query):
            return try? encoder.encode(query)
        case .editComment(_, _, let query):
            return try? encoder.encode(query)
        case .like(_, let query):
            return try? encoder.encode(query)
        case .refreshToken, .withdraw, .fetchPost, .fetchParticularPost, .deletePost, .fetchPostByUser, .deleteComment, .fetchLikePost, .follow, .deleteFollow, .fetchMyProfile, .fetchUserProfile, .hashtag, .fetchImage, .uploadImage, .editProfileNick, .editProfileImage:
            return nil
        }
    }
}
