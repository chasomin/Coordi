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
    private let viewModel: SettingViewModel
    
    private let viewDidLoadTrigger = PublishRelay<Void>()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadTrigger.accept(())
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
}
