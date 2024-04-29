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
    case login //test
    
    var title: String {
        switch self {
        case .Feed:
            "피드 모아보기"
        case .MyPage:
            "마이페이지"
        case .login:
            "로그인"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .Feed:
            UIImage(systemName: "tshirt")
        case .MyPage:
            UIImage(systemName: "person")
        case .login:
             nil
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
            let myPageViewModel = MyPageViewModel(userId: Observable.just(UserDefaultsManager.userId))
            return MyPageViewController(viewModel: myPageViewModel)
        case .login:
            return LogInViewController()
        }
    }
    
    func setViewContollerWithTabBarItem() -> UIViewController {
        let vc = UINavigationController(rootViewController: root)
        vc.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image)
        return vc
    }
    
}

