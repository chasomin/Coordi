//
//  Constants.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import Foundation

enum Constants {
    static var productId = "CoordiFeed"
    
    enum NavigationTitle {
        case feed
        case myPage(value: Bool, nick: String)
        case search
        case create
        case editProfile
        case editNickname
        case loginInformation
        
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
            }
        }
    }
    
    enum Temp: CaseIterable {
        
        
    }
    
    enum TextViewPlaceholder: String {
        case createPost = "아이템 정보와 코디에 대해 알려주세요!"
    }
}
