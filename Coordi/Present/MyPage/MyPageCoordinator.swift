//
//  MyPageCoordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/1/24.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showMyPageView()
    }
    
    private func showMyPageView() {
        let vm = MyPageViewModel(userId: UserDefaultsManager.userId)
        vm.coordinator = self
        let vc = MyPageViewController(viewModel: vm)
        
        push(vc, animation: false)
    }
}
