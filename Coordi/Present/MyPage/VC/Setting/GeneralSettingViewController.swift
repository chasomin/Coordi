//
//  GeneralSettingViewController.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class GeneralSettingViewController: BaseViewController {
    private let viewModel: GeneralSettingViewModel
    
    private let viewDidLoadTrigger = PublishRelay<Void>()
    private let withdrawTrigger = PublishRelay<Void>()
    
    private let emailTitleLabel = UILabel()
    private let emailLabel = UnderlineLabel()
    private let withdrawButton = UIButton()
    
    init(viewModel: GeneralSettingViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = GeneralSettingViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger,
                                                  withdrawTap: .init(),
                                                  withdrawAlertOKTap: withdrawTrigger)
        let output = viewModel.transform(input: input)
        
        withdrawButton.rx.tap
            .bind(to: input.withdrawTap)
            .disposed(by: disposeBag)
        
        output.profile
            .drive(with: self) { owner, profile in
                owner.emailLabel.label.text = profile.email
            }
            .disposed(by: disposeBag)
        
        output.withdrawTap
            .drive(with: self) { owner, _ in
                owner.showAlert(title: "회원탈퇴", message: "탈퇴하시겠습니까?\n이 과정을 되돌릴 수 없습니다.") {
                    owner.withdrawTrigger.accept(())
                }
            }
            .disposed(by: disposeBag)
            
    }
    
    override func configureHierarchy() {
        view.addSubview(emailTitleLabel)
        view.addSubview(emailLabel)
        view.addSubview(withdrawButton)
    }
    
    override func configureLayout() {
        emailTitleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        emailLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.top.equalTo(emailTitleLabel.snp.bottom).offset(10)
        }
        withdrawButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.top.equalTo(emailLabel.line.snp.bottom).offset(40)
        }
    }
    
    override func configureView() {
        navigationItem.title = Constants.NavigationTitle.loginInformation.title
        
        emailTitleLabel.text = "가입 이메일"
        emailTitleLabel.font = .caption
        emailLabel.label.font = .caption
        
        var config = UIButton.Configuration.tinted()
        var attr = AttributedString("회원탈퇴")
        attr.font = .body
        config.attributedTitle = attr
        withdrawButton.configuration = config
    }
}
