//
//  CreateImageCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import UIKit
import SnapKit

final class CreateImageCollectionViewCell: BaseCollectionViewCell {
    let imageView = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureView() {
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = UIColor.pointColor.cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
}
