//
//  TabBar.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import UIKit
import RxSwift

enum TabBar: CaseIterable {
    case Feed
    case Shop
    case MyPage
    
    var title: String {
        switch self {
        case .Feed:
            "피드 모아보기"
        case .Shop:
            "쇼핑"
        case .MyPage:
            "내 피드"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .Feed:
            UIImage(systemName: "tshirt")
        case.Shop:
            UIImage(systemName: "tag")
        case .MyPage:
            UIImage(systemName: "person")
        }
    }
    
    func setViewContollerWithTabBarItem() -> UINavigationController {
        let vc = UINavigationController()
        vc.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image)
        return vc
    }
    
}

