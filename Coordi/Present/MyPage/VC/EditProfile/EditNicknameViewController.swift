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
    let currentNickname: String
    var changeNickname: ((String) -> Void)?
    
    private let viewModel = EditNicknameViewModel()
    
    private let nicknameTitleLabel = UILabel()
    private let textField = LineTextField()
    private let statusLabel = UILabel()
    private let saveButton = PointButton(text: "저장")

    init(currentNickname: String) {
        self.currentNickname = currentNickname
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Constants.NavigationTitle.editNickname.title
    }
    
    override func bind() {
        let currentNickname = Observable.just(currentNickname)
        let input = EditNicknameViewModel.Input(currentNickname: currentNickname, userInputNickname: textField.textField.rx.text.orEmpty.asObservable(), saveButtonTap: saveButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.failureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast()
            }
            .disposed(by: disposeBag)
        
        output.successTrigger
            .drive(with: self) { owner, nick in
                owner.navigationController?.popViewController(animated: true)
                owner.changeNickname?(nick)
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
        nicknameTitleLabel.font = .boldBody
        nicknameTitleLabel.text = "닉네임"
        textField.textField.font = .body
        textField.textField.text = currentNickname
        statusLabel.font = .caption
    }
}
