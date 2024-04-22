//
//  RoundedTextFieldView.swift
//  Coordi
//
//  Created by 차소민 on 4/23/24.
//

import UIKit
import SnapKit

final class RoundedTextFieldView: BaseView {
    let textField = UITextField()
    
    override func configureHierarchy() {
        addSubview(textField)
    }
    
    override func configureLayout() {
        textField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview().inset(5)
        }
    }
    
    override func configureView() {
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.pointColor.cgColor
        clipsToBounds = true
    }
}
