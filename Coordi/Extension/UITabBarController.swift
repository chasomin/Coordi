//
//  UITabBarController.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import UIKit

extension UITabBarController {
    func setTabBar() {
        let viewControllers = TabBar.allCases.map { $0.setViewContollerWithTabBarItem() }
        self.viewControllers = viewControllers
    }
}
