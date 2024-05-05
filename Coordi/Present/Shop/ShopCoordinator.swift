//
//  ShopCoordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import UIKit

final class ShopCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showShopView()
    }
    
    private func showShopView() {
        let vm = ShopViewModel()
        vm.coordinator = self
        let vc = ShopViewController(vieWModel: vm)

        push(vc, animation: false)
    }
}
