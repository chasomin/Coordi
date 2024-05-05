//
//  CommentViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CommentViewController: BaseViewController {
    
    let viewModel: CommentViewModel
    
    private let commentText = PublishRelay<String>()

    private let tableView = UITableView()
    private let bottomView = UIView()
    private let commentTextfield = RoundedTextFieldView()
    private let commentUploadButton = UIButton()

    
    init(viewModel: CommentViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func bind() {
        let input = CommentViewModel.Input(commentUpload: .init(),
                                           commentText: .init(),
                                           commentDelete: .init())
        let output = viewModel.transform(input: input)
                
        commentUploadButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.commentTextfield.textField.text = ""
                input.commentUpload.accept(())
            }
            .disposed(by: disposeBag)
        
        commentTextfield.textField.rx.text.orEmpty
            .bind(to: input.commentText)
            .disposed(by: disposeBag)

        tableView.rx.modelDeleted(CommentModel.self)
            .filter { $0.creator.user_id == UserDefaultsManager.userId }
            .bind(to: input.commentDelete)
            .disposed(by: disposeBag)
        
        output.comments
            .drive(tableView.rx.items(cellIdentifier: CommentTableViewCell.id, cellType: CommentTableViewCell.self)) { (index, element, cell) in
                cell.configureCell(item: element)
            }
            .disposed(by: disposeBag)
                
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
            }
            .disposed(by: disposeBag)
    }

    override func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        bottomView.addSubview(commentTextfield)
        bottomView.addSubview(commentUploadButton)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        bottomView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(tableView.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        commentTextfield.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview()
            make.height.equalTo(40)
        }
        commentUploadButton.snp.makeConstraints { make in
            make.leading.equalTo(commentTextfield.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview()
            make.size.equalTo(40)
        }

    }
    
    override func configureView() {
        tableView.backgroundColor = .backgroundColor
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        bottomView.backgroundColor = .backgroundColor
        commentTextfield.textField.placeholder = "댓글"
        let image = UIImage(systemName: "arrow.up.circle.fill")?.setConfiguration(font: .boldSystemFont(ofSize: 30))
        commentUploadButton.setImage(image, for: .normal)
    }
}
