//
//  TabCoordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/1/24.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        setTabController()
    }
    
    func setTabController() {
        // 탭바 컨트롤러 생성
        let tabBar = UITabBarController()
        
        // 탭 페이지가 세팅된 네비게이션 컨트롤러 리스트 만들기
        let viewControllers = TabBar.allCases.map { $0.setViewContollerWithTabBarItem() }
        
        // 네비게이션 컨트롤러마다 코디네이터 연결하기
        TabBar.allCases.enumerated().forEach { index, page in
            서브코디네이터연결(page: page, navigationVC: viewControllers[index])
        }
        
        // 탭바 페이지 리스트에 네비게이션 리스트 할당하기
        tabBar.viewControllers = viewControllers
        
        // 푸시
        push(tabBar, animation: false)
    }
    
    private func 서브코디네이터연결(page: TabBar, navigationVC: UINavigationController) {
        
        switch page {
        case .Feed:
            let feedCoordinator = FeedCoordinator(navigationVC)
            feedCoordinator.delegate = self
            feedCoordinator.start()
            addChild(feedCoordinator)
            
        case .MyPage:
            let myPageCoordinator = MyPageCoordinator(navigationVC)
            myPageCoordinator.delegate = self
            myPageCoordinator.start()
            addChild(myPageCoordinator)
        }
    }
}

extension TabBarCoordinator: CoordinatorDelegate {
    func coordinatorDidEnd(_ childCoordinator: any Coordinator) {
        print("🥹")
        self.dismiss()
        self.end()
    }
}
