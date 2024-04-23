//
//  FeedDetailImageCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit
import RxSwift

final class FeedDetailImageCollectionViewCell: BaseCollectionViewCell {
    var disposeBag = DisposeBag()

    let imageView = UIImageView()
    let tapGesture = UITapGestureRecognizer()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
        imageView.addGestureRecognizer(tapGesture)
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
        imageView.isUserInteractionEnabled = true
        
        tapGesture.numberOfTapsRequired = 2
    }
    
    func configureCell(item: String) {
        imageView.loadImage(from: item)
    }
}
