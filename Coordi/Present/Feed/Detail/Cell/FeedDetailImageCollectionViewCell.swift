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
            make.width.equalTo(frame.width).multipliedBy(0.8)
            make.height.equalTo(imageView.snp.width).multipliedBy(1.33)
        }
    }
    
    override func configureView() {
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    func configureCell(item: String) {
        imageView.loadImage(from: item)
    }
}
