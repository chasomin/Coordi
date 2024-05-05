//
//  EditNicknameViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditNicknameViewController: BaseViewController {
    
    private let viewModel: EditNicknameViewModel
    
    private let viewDidLoadTrigger = PublishRelay<Void>()
    
    private let nicknameTitleLabel = UILabel()
    private let textField = LineTextField()
    private let statusLabel = UILabel()
    private let saveButton = PointButton(text: "저장")

    init(viewModel: EditNicknameViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = EditNicknameViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger,
                                                userInputNickname: textField.textField.rx.text.orEmpty.asObservable(),
                                                saveButtonTap: saveButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.viewDidLoadTrigger
            .drive(with: self) { owner, nick in
                owner.textField.textField.text = nick
            }
            .disposed(by: disposeBag)
        
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
            }
            .disposed(by: disposeBag)
        
        output.validationText
            .drive(with: self) { owner, text in
                owner.statusLabel.text = text
            }
            .disposed(by: disposeBag)
        
        output.nicknameValidation
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(nicknameTitleLabel)
        view.addSubview(textField)
        view.addSubview(saveButton)
        view.addSubview(statusLabel)
    }
    
    override func configureLayout() {
        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(24)
        }
        
        textField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(5)
            make.height.equalTo(24)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.top.equalTo(textField.snp.bottom).offset(15)
            make.height.equalTo(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(50)
        }
    }
    
    override func configureView() {
        navigationItem.title = Constants.NavigationTitle.editNickname.title
        nicknameTitleLabel.font = .boldBody
        nicknameTitleLabel.text = "닉네임"
        textField.textField.font = .body
        statusLabel.font = .caption
    }
}
