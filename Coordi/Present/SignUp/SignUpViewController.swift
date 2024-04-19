//
//  SignUpViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController {
    let viewModel = SignUpViewModel()
    
    let logoImageView = UIImageView()
    
    let dismissButton = UIButton()
    
    let emailLabel = UILabel()
    let emailTextField = LineTextField()
    let emailStatusLabel = UILabel()
    
    let passwordLabel = UILabel()
    let passwordTextField = LineTextField()
    let passwordStatusLabel = UILabel()
    
    let nicknameLabel = UILabel()
    let nicknameTextField = LineTextField()
    let nicknameStatusLabel = UILabel()
    
    let signUpButton = PointButton(text: "회원가입")
    
    let tapGesture = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func bind() {
        let input = SignUpViewModel.Input(emailText: emailTextField.textField.rx.text.orEmpty.asObservable(), passwordText: passwordTextField.textField.rx.text.orEmpty.asObservable(), nicknameText: nicknameTextField.textField.rx.text.orEmpty.asObservable(), signUpButtonTap: signUpButton.rx.tap.asObservable(), dismissButtonTap: dismissButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.emailValid
            .drive(emailStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.passwordValid
            .drive(passwordStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)

        output.nicknameValid
            .drive(nicknameStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)

        output.allValid
            .drive(signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.failureTrigger
            .drive(with: self) { owner, valid in
                owner.showErrorToast()
            }
            .disposed(by: disposeBag)

        output.successTrigger
            .drive(with: self) { owner, valid in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.dismissButtonTap
            .drive(with: self) { owner, valid in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(dismissButton)
        view.addSubview(logoImageView)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailStatusLabel)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordStatusLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameStatusLabel)
        
        view.addSubview(signUpButton)
        
        view.addGestureRecognizer(tapGesture)
    }
    
    override func configureLayout() {
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(100)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(24)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(28)
        }
        emailStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)
        }

        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailStatusLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(24)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(28)
        }
        passwordStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)

        }

        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordStatusLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(24)
        }
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(28)
        }
        nicknameStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view).inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
    }
    
    override func configureView() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.buttonSize = .large
        config.baseForegroundColor = .pointColor
        dismissButton.configuration = config
        
        logoImageView.image = .coordi
        logoImageView.contentMode = .scaleAspectFit
        
        emailLabel.text = "이메일"
        emailLabel.font = .title
        emailTextField.textField.placeholder = "ex) coordi@coordi.com"
        emailStatusLabel.text = "이메일 형식으로 작성해주세요"
        emailStatusLabel.font = .caption
        emailStatusLabel.textColor = .pointColor
        
        passwordLabel.text = "비밀번호"
        passwordTextField.textField.isSecureTextEntry = true
        passwordStatusLabel.text = "영문, 숫자, 특수기호 포함 8자 이상으로 작성해주세요"
        passwordStatusLabel.font = .caption
        passwordStatusLabel.textColor = .pointColor


        nicknameLabel.text = "닉네임"
        nicknameStatusLabel.text = "2자 이상으로 작성해주세요"
        nicknameStatusLabel.font = .caption
        nicknameStatusLabel.textColor = .pointColor

        tapGesture.addTarget(self, action: #selector(tapGestureTapped))
    }
}

extension SignUpViewController {
    @objc func tapGestureTapped() {
        view.endEditing(true)
    }
}
