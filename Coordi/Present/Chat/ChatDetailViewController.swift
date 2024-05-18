//
//  ChatDetailViewController.swift
//  Coordi
//
//  Created by 차소민 on 5/16/24.
//

import UIKit
import SnapKit

final class ChatDetailViewController: BaseViewController {
    let tableView = UITableView()
    let sendStack = UIStackView()
    let textField = RoundedTextFieldView()
    let sendButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func bind() {
        
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(sendStack)
        sendStack.addArrangedSubview(textField)
        sendStack.addArrangedSubview(sendButton)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        sendStack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(sendButton.snp.height)
        }
    }
    
    override func configureView() {
        navigationItem.title = Constants.NavigationTitle.chat.title
        
        tableView.separatorStyle = .none
        
        sendStack.axis = .horizontal
        sendStack.spacing = 10
        sendStack.distribution = .fill
        
        let image = UIImage(systemName: "arrow.up.circle.fill")?.setConfiguration(font: .boldSystemFont(ofSize: 30))
        sendButton.setImage(image, for: .normal)
        
        textField.textField.placeholder = Constants.Placeholder.chat.rawValue
    }

}
