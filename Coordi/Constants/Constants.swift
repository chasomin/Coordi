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
        case create
        case editProfile
        case editNickname
        case loginInformation
        case likeFeeds
        case editPost
        case chat

        var title: String {
            switch self {
            case .feed:
                ""
            case .myPage(let value, let nick):
                value ? "내 피드 모아보기" : nick
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
            case .chat:
                "1:1 문의하기"
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
    
    enum Placeholder: String {
        case createPost = "아이템 정보와 코디에 대해 알려주세요!"
        case feedSearch = "코디가 궁금한 기온을 검색해보세요 :)"
        case shopSearch = "상의, 하의 등 카테고리 또는 브랜드명을 검색해보세요"
        case chat = "문의 내용을 입력해주세요"
    }
}
