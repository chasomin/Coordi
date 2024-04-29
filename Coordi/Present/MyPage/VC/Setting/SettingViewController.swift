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
        let input = SettingViewModel.Input(viewDidLoad: viewDidLoadTrigger)
        let output = viewModel.transform(input: input)
        
        output.settingList
            .debug("여기 VC")
            .drive(tableView.rx.items(cellIdentifier: SettingTableViewCell.id, cellType: SettingTableViewCell.self)) { index, element, cell in
                cell.title.text = element.title
                cell.icon.image = UIImage(systemName: element.icon)
                print("여기",element.title)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
    }
}
