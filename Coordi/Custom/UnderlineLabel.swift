//
//  UnderlineLabel.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit

final class UnderlineLabel: BaseView {
    let label = UILabel()
    let line = UIView()
    
    override func configureHierarchy() {
        addSubview(label)
        addSubview(line)
    }
    
    override func configureLayout() {
        label.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(28)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(label)
            make.height.equalTo(1)
        }
        
        line.backgroundColor = .pointColor
    }
}
