//
//  MyPageCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/17/24.
//

import UIKit
import SnapKit

class MyPageCollectionViewCell: BaseCollectionViewCell {
    let image = UIImageView()
    let tempLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(tempLabel)
        contentView.addSubview(image)
    }
    
    override func configureLayout() {
        tempLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(15)
            make.height.equalTo(24)
        }
        image.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom).offset(10)
            make.bottom.horizontalEdges.equalToSuperview().inset(15)
        }
    }
    
    override func configureView() {
        image.contentMode = .scaleAspectFit
        layer.cornerRadius = 20
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
    }
}
