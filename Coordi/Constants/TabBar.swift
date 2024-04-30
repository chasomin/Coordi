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
    case MyPage
    
    var title: String {
        switch self {
        case .Feed:
            "피드 모아보기"
        case .MyPage:
            "내 피드"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .Feed:
            UIImage(systemName: "tshirt")
        case .MyPage:
            UIImage(systemName: "person")
        }
    }
    
    var root: UIViewController {
        switch self {
        case .Feed:
            let feedViewModel = FeedViewModel()
            let followFeedViewModel = FollowFeedViewModel()
            let allFeedViewModel = AllFeedViewModel()
            
            return FeedViewController(viewModel: feedViewModel,
                               followFeedViewModel: followFeedViewModel,
                               allFeedViewModel: allFeedViewModel)
        case .MyPage:
            let myPageViewModel = MyPageViewModel(userId: UserDefaultsManager.userId)
            print("여기", UserDefaultsManager.userId)
            return MyPageViewController(viewModel: myPageViewModel)
        }
    }
    
    func setViewContollerWithTabBarItem() -> UIViewController {
        let vc = UINavigationController(rootViewController: root)
        vc.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image)
        return vc
    }
    
}

