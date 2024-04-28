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
    let viewModel = LogInViewModel()
    
    let logoImageView = UIImageView()
        
    let emailLabel = UILabel()
    let emailTextField = LineTextField()
    
    let passwordLabel = UILabel()
    let passwordTextField = LineTextField()
        
    let logInButton = PointButton(text: "로그인")
    
    let moveSignUpButton = UIButton()
    
    let tapGesture = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = LogInViewModel.Input(emailText: emailTextField.textField.rx.text.orEmpty.asObservable(), passwordText: passwordTextField.textField.rx.text.orEmpty.asObservable(), logInButtonTap: logInButton.rx.tap.asObservable(), moveSignUpButtonTap: moveSignUpButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.logInButtonStatus
            .drive(logInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.successTrigger
            .drive(with: self) { owner, _ in
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                
                let firstVC = UINavigationController(rootViewController: FeedViewController())
                firstVC.tabBarItem = UITabBarItem(title: "피드", image: nil, selectedImage: nil)
                let secondVC = UINavigationController(rootViewController: LogInViewController())
                secondVC.tabBarItem = UITabBarItem(title: "로그인", image: nil, selectedImage: nil)
                let thirdVC = UINavigationController(rootViewController: MyPageViewController(userId: UserDefaultsManager.userId))
                thirdVC.tabBarItem = UITabBarItem(title: "마이페이지", image: nil, selectedImage: nil )
                let tabBar = UITabBarController()
                tabBar.viewControllers = [firstVC, secondVC, thirdVC]
                
                sceneDelegate?.window?.rootViewController = tabBar
                sceneDelegate?.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
        
        output.failureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast("⚠️")
            }
            .disposed(by: disposeBag)
        
        output.moveSignUp
            .drive(with: self) { owner, _ in
                let vc = SignUpViewController()
                vc.modalPresentationStyle = .fullScreen
                owner.present(vc, animated: true)
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
