//
//  BaseViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
        
        bind()
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func bind() { }
    func configureHierarchy() { }
    func configureLayout() { }
    func configureView() { }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
