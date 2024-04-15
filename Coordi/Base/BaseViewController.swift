//
//  BaseViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        bind()
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func bind() { }
    func configureHierarchy() { }
    func configureLayout() { }
    func configureView() { }
    
    func showToast() {
        var style = ToastStyle.init()
        style.backgroundColor = .pointColor
        style.titleColor = .backgroundColor
        view.makeToast(nil, duration: 2, position: .top, title: "⚠️오류가 발생했습니다\n잠시후에 다시 시도해주세요", style: style) //TODO: 오류 처리
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
