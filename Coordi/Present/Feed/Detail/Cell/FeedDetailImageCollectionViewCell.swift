//
//  FeedDetailImageCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit

final class FeedDetailImageCollectionViewCell: BaseCollectionViewCell {
    let imageView = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(400)
            make.width.equalTo(300)
        }
    }
    
    override func configureView() {
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
}
