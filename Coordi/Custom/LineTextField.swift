//
//  LineTextField.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import UIKit
import SnapKit

final class LineTextField: BaseView {
    let textField = UITextField()
    let line = UIView()
    
    override func configureHierarchy() {
        addSubview(textField)
        addSubview(line)
        
        
    }
    
    override func configureLayout() {
        textField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(28)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(textField)
            make.height.equalTo(1)
        }
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        line.backgroundColor = .pointColor
    }
}
