//
//  SettingViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/30/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SettingViewController: BaseViewController {
    private let viewModel = SettingViewModel()
    
    private let viewDidLoadTrigger = PublishRelay<Void>()
    
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadTrigger.accept(())
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureView() {
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.id)
        tableView.rowHeight = 60
    }
    
    override func bind() {
        let input = SettingViewModel.Input(viewDidLoad: viewDidLoadTrigger,
                                           selectedItem: .init())
        let output = viewModel.transform(input: input)
        
        tableView.rx.modelSelected(SettingViewModel.Setting.self)
            .bind(to: input.selectedItem)
            .disposed(by: disposeBag)
        
        output.settingList
            .drive(tableView.rx.items(cellIdentifier: SettingTableViewCell.id, cellType: SettingTableViewCell.self)) { index, element, cell in
                cell.title.text = element.title
                cell.icon.image = UIImage(systemName: element.icon)
            }
            .disposed(by: disposeBag)
        
        output.settingTap
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
                
            }
            .disposed(by: disposeBag)
        
        output.likeTap
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        
        output.logOutTap
            .drive(with: self) { owner, _ in
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                sceneDelegate?.window?.rootViewController = LogInViewController()
                sceneDelegate?.window?.makeKeyAndVisible()

            }
            .disposed(by: disposeBag)
    }
}
