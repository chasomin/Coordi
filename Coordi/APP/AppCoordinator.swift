//
//  AppCoordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/1/24.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        checkConditionForRoot()
    }
}

extension AppCoordinator {
    private func connectLoginCoordinator() {
        let loginCoordinator = LoginCoordinator(navigationController)
        loginCoordinator.delegate = self
        loginCoordinator.start()
        addChild(loginCoordinator)
    }
    
    private func connectTabBarCoordinator() {
        let tabCoordinator = TabBarCoordinator(navigationController)
        tabCoordinator.delegate = self
        tabCoordinator.start()
        addChild(tabCoordinator)
    }
    
    private func checkConditionForRoot() {
        navigationController.viewControllers.removeAll()
        
        if !UserDefaultsManager.accessToken.isEmpty {
            connectTabBarCoordinator()
        } else {
            connectLoginCoordinator()
        }
    }
}

extension AppCoordinator: CoordinatorDelegate {
    func coordinatorDidEnd(_ childCoordinator: Coordinator) { 
        checkConditionForRoot()
    }
}
