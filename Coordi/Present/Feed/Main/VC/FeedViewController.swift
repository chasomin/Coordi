//
//  FeedViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/25/24.
//
import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa

final class FeedViewController: TabmanViewController {
    private let viewModel = FeedViewModel()
    private let disposeBag = DisposeBag()
    
    private var viewControllers = [FollowFeedViewController(), UIViewController()]//
    private let searchButton = UIBarButtonItem()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setTopTabBar()
        configureView()
        bind()
        navigationItem.title = "현재 20℃"//
        navigationItem.rightBarButtonItem = searchButton
        
    }
    
    private func setTopTabBar() {
        self.dataSource = self
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .fit
        bar.buttons.customize { (button) in
            button.tintColor = .pointColor
            button.selectedTintColor = .pointColor
        }
        addBar(bar, dataSource: self, at: .top)
    }
    
    private func configureView() {
        searchButton.image = UIImage(systemName: "magnifyingglass")

    }
    
    private func bind() {
        let input = FeedViewModel.Input(searchButtonTap: searchButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.serarchButtonTap
            .drive(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SearchViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension FeedViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: any Tabman.TMBar, at index: Int) -> any Tabman.TMBarItemable {
        if index == 0 {
            return TMBarItem(title: "팔로잉")
        } else {
            return TMBarItem(title: "탐색")
        }
    }
    
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        viewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        nil
    }
}
