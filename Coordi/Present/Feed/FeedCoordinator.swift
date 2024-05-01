//
//  FeedCoordinator.swift
//  Coordi
//
//  Created by 차소민 on 5/1/24.
//

import UIKit

final class FeedCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    func start() {
        showFeedView()
    }
    
    private func showFeedView() {
        let vm = FeedViewModel()
        vm.coordinator = self
        let followFeedVM = FollowFeedViewModel()
        followFeedVM.coordinator = self
        let allFeedVM = AllFeedViewModel()
        allFeedVM.coordinator = self
        let vc = FeedViewController(viewModel: vm,
                                    followFeedViewModel: followFeedVM,
                                    allFeedViewModel: allFeedVM)
        
        push(vc, animation: false)
    }
}
