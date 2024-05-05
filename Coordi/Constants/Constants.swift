//
//  Constants.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import Foundation

enum Constants {
    static var productId = "CoordiFeed"
    static var shopProductId = "CoordiShop"
    static var appScheme = "coordi"
    static var payUserCode = "imp57573124"
    
    enum NavigationTitle {
        case feed
        case myPage(value: Bool, nick: String)
        case search
        case create
        case editProfile
        case editNickname
        case loginInformation
        case likeFeeds
        case editPost

        var title: String {
            switch self {
            case .feed:
                ""
            case .myPage(let value, let nick):
                value ? "내 피드 모아보기" : nick
            case .search:
                ""
            case .create:
                "코디 올리기"
            case .editProfile:
                "프로필 관리"
            case .editNickname:
                "닉네임 수정"
            case .loginInformation:
                "로그인 정보"
            case .likeFeeds:
                "좋아요한 게시글"
            case .editPost:
                "수정하기"
            }
        }
    }
    
    enum TitleLabel: String {
        case createTemp
        
        var title: String {
            switch self {
            case .createTemp:
                "이 코디와 함께한 날의 온도는 어땠나요?"
            }
        }
        
    }
    
    enum TextViewPlaceholder: String {
        case createPost = "아이템 정보와 코디에 대해 알려주세요!"
    }
}
