//
//  LogInViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LogInViewController: BaseViewController {
    private let viewModel: LogInViewModel
    
    private let logoImageView = UIImageView()
    private let emailLabel = UILabel()
    private let emailTextField = LineTextField()
    private let passwordLabel = UILabel()
    private let passwordTextField = LineTextField()
    private let logInButton = PointButton(text: "로그인")
    private let moveSignUpButton = UIButton()
    private let tapGesture = UITapGestureRecognizer()

    init(viewModel: LogInViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = LogInViewModel.Input(emailText: .init(),
                                         passwordText: .init(),
                                         logInButtonTap: .init(),
                                         moveSignUpButtonTap: .init())
        let output = viewModel.transform(input: input)
        
        emailTextField.textField.rx.text.orEmpty
            .bind(to: input.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.textField.rx.text.orEmpty
            .bind(to: input.passwordText)
            .disposed(by: disposeBag)
        
        logInButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.logInButton.configuration?.showsActivityIndicator = true
                input.logInButtonTap.accept(())
            }
            .disposed(by: disposeBag)
        
        moveSignUpButton.rx.tap
            .bind(to: input.moveSignUpButtonTap)
            .disposed(by: disposeBag)
        
        output.logInButtonStatus
            .drive(logInButton.rx.isEnabled)
            .disposed(by: disposeBag)
                
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
                owner.logInButton.configuration?.showsActivityIndicator = false
            }
            .disposed(by: disposeBag)
        
        output.successTrigger
            .drive(with: self) { owner, _ in
                owner.logInButton.configuration?.showsActivityIndicator = false
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(logoImageView)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(logInButton)
        view.addSubview(moveSignUpButton)
        view.addGestureRecognizer(tapGesture)
    }
    
    override func configureLayout() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(180)
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

        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(25)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(24)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(28)
        }
        
        logInButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view).inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        
        moveSignUpButton.snp.makeConstraints { make in
            make.bottom.equalTo(logInButton.snp.top).offset(-10)
            make.horizontalEdges.equalTo(view).inset(15)
        }
    }
    
    override func configureView() {
        logoImageView.image = .coordi
        logoImageView.contentMode = .scaleAspectFit
        
        emailLabel.text = "이메일"
        emailLabel.font = .title
        emailTextField.textField.placeholder = "ex) coordi@coordi.com"
        
        passwordLabel.text = "비밀번호"
        passwordTextField.textField.isSecureTextEntry = true
        
        var config = UIButton.Configuration.plain()
        var attr = AttributedString.init("아직 회원이 아니신가요?   이메일 가입")
        attr.font = UIFont.caption
        config.attributedSubtitle = attr
        config.baseForegroundColor = .LabelColor
        moveSignUpButton.configuration = config

        tapGesture.addTarget(self, action: #selector(tapGestureTapped))
    }
}

extension LogInViewController {
    @objc func tapGestureTapped() {
        view.endEditing(true)
    }
}
