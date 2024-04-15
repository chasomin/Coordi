//
//  BaseView.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configureHierarchy() { }
    func configureLayout() { }
    func configureView() { }
}
