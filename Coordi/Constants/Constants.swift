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
        case myPage
        case search
        case create
        case editProfile
        case editNickname
        
        var title: String {
            switch self {
            case .feed:
                ""
            case .myPage:
                "내 피드 모아보기"
            case .search:
                ""
            case .create:
                "코디 올리기"
            case .editProfile:
                "프로필 관리"
            case .editNickname:
                "닉네임 수정"
            }
        }
    }
    
    enum Temp: CaseIterable {
        
        
    }
    
    enum TextViewPlaceholder: String {
        case createPost = "아이템 정보와 코디에 대해 알려주세요!"
    }
}
