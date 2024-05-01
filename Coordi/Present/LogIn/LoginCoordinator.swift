//
//  LoginCoordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/1/24.
//

import UIKit

final class LoginCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showLoginView()
    }
    
    private func showLoginView() {
        let vm = LogInViewModel()
        vm.coordinator = self
        
        let vc = LogInViewController(viewModel: vm)
        
        push(vc, animation: false)
    }
}
