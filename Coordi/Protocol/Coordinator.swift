//
//  Coordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/1/24.
//

import UIKit

protocol CoordinatorDelegate: AnyObject {
    
    func coordinatorDidEnd(_ childCoordinator: Coordinator)
}

protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get set }
    var delegate: CoordinatorDelegate? { get set }
    var childCoordinators: [Coordinator] { get set }
    
    
    init(_ navigationController: UINavigationController)
    
    
    func start()
    func end()
    func push(_ viewController: UIViewController, animation: Bool)
    func pop(animation: Bool)
    func popToRoot(animation: Bool)
    func dismiss(animation: Bool)
    func emptyOut()
}

extension Coordinator {
    
    func end() {
        self.emptyOut()
        self.delegate?.coordinatorDidEnd(self)
    }
    
    func push(_ viewController: UIViewController, animation: Bool = true) {
        self.navigationController.pushViewController(viewController, animated: animation)
    }
    
    func pop(animation: Bool = true) {
        self.navigationController.popViewController(animated: animation)
    }
    
    func popToRoot(animation: Bool = true) {
        self.navigationController.popToRootViewController(animated: animation)
    }
    
    func present(_ viewController: UIViewController, style: UIModalPresentationStyle = .automatic, animation: Bool = true) {
        viewController.modalPresentationStyle = style
        self.navigationController.present(viewController, animated: animation)
    }
    
    func dismiss(animation: Bool = true) {
        self.navigationController.dismiss(animated: animation)
    }
    
    func emptyOut() {
        self.childCoordinators.removeAll()
    }
    
    func addChild(_ childCoordinator: Coordinator) {
        self.childCoordinators.append(childCoordinator)
    }
}
