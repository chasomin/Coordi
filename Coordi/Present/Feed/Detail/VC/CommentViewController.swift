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

//protocol TransferDelegate {
//    func transfer(value: BehaviorRelay<PostModel>)//
//}

final class CommentViewController: BaseViewController {
//    var postModel: BehaviorRelay<PostModel>
    
    let viewModel: CommentViewModel
    
//    var delegate: TransferDelegate?
    
    private let tableView = UITableView()
    private let bottomView = UIView()
    private let commentTextfield = RoundedTextFieldView()
    private let commentUploadButton = UIButton()

    private let commentText = PublishRelay<String>()
    
    init(viewModel: CommentViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        delegate?.transfer(value: postModel)
//    }
    
    override func bind() {
        
        commentUploadButton.rx.tap
            .withLatestFrom(commentTextfield.textField.rx.text.orEmpty)
            .bind(with: self) { owner, text in
                owner.commentText.accept(text)
            }
            .disposed(by: disposeBag)
        
        let input = CommentViewModel.Input(commentUpload: commentText,
                                           commentDelete: .init())
        let output = viewModel.transform(input: input)
        
        tableView.rx.modelDeleted(CommentModel.self)
            .bind(to: input.commentDelete)
            .disposed(by: disposeBag)
        
        
        output.comments
            .drive(tableView.rx.items(cellIdentifier: CommentTableViewCell.id, cellType: CommentTableViewCell.self)) { (index, element, cell) in
                cell.configureCell(item: element)
            }
            .disposed(by: disposeBag)
                
    }
    //TODO: 댓글 창 닫을 때 디테일화면 reload....

    override func viewDidLoad() {
        super.viewDidLoad()
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

//extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        postModel.comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.id, for: indexPath) as! CommentTableViewCell
//        cell.configureCell(item: postModel.comments[indexPath.row])
//        return cell
//    }
//}
