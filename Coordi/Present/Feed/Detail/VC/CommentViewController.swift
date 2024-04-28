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
    var postModel: PostModel
    
    let viewModel = CommentViewModel()
    
    private let tableView = UITableView()
    private let bottomView = UIView()
    private let commentTextfield = RoundedTextFieldView()
    private let commentUploadButton = UIButton()

    private let commentText = PublishRelay<String>()
    
    init(postModel: PostModel) {
        self.postModel = postModel
        super.init()
    }
    
    override func bind() {
        commentUploadButton.rx.tap
            .withLatestFrom(commentTextfield.textField.rx.text.orEmpty)
            .bind(with: self) { owner, text in
                owner.commentText.accept(text)
            }
            .disposed(by: disposeBag)
        
        let input = CommentViewModel.Input(postId: Observable.just(postModel.post_id), commentUpload: commentText)
        let output = viewModel.transform(input: input)
        
        
        let comments = BehaviorRelay(value: postModel.comments)
        //TODO: 댓글 순서 뒤집어야됨, 밀어서 delete, 
        
        comments
            .bind(to: tableView.rx.items(cellIdentifier: CommentTableViewCell.id, cellType: CommentTableViewCell.self)) { (index, element, cell) in
                cell.configureCell(item: element)
            }
            .disposed(by: disposeBag)
        
        output.commentModel
            .drive(with: self) { owner, comment in
                var commentValue = comments.value
                commentValue.append(comment)
                comments.accept(commentValue)
                owner.tableView.reloadData()
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
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.top.equalTo(tableView.snp.bottom)
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
//        tableView.delegate = self
//        tableView.dataSource = self
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
