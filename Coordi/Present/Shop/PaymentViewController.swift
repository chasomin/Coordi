//
//  PaymentViewController.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import UIKit
import WebKit
import SnapKit
import RxSwift
import RxCocoa
import iamport_ios

final class PaymentViewController: BaseViewController {
    private let viewModel: PaymentViewModel
    
    private let viewDidLoadTrigger = PublishRelay<Void>()
    private let paymentDone = PublishRelay<String?>()
    
    private let webView = WKWebView()
    
    init(viewModel: PaymentViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = PaymentViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger,
                                           paymentDone: paymentDone)
        let output = viewModel.transform(input: input)
        
        output.payment
            .drive(with: self) { owner, payment in
                Iamport.shared.paymentWebView(webViewMode: owner.webView,
                                              userCode: Constants.payUserCode,
                                              payment: payment) { iamportResponse in
                    owner.paymentDone.accept(iamportResponse?.imp_uid)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    override func configureHierarchy() {
        view.addSubview(webView)
    }
    
    override func configureLayout() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        webView.backgroundColor = UIColor.clear
    }
}
