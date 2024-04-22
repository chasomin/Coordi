//
//  MyPageCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/17/24.
//

import UIKit
import SnapKit

final class FeedCollectionViewCell: BaseCollectionViewCell {
    let image = UIImageView()
    let tempLabel = UILabel()

//    override func prepareForReuse() {
//        super.prepareForReuse()
////        contentView.frame.size.height = 0
////        image.frame.size.height = 0
////        print("!!", image.frame.height)
////        print("@@", contentView.frame.size.height)
//        print("!!", image.image?.size.height)
////        image.snp.makeConstraints { make in
////            make.top.equalTo(tempLabel.snp.bottom)//.offset(10)
////            make.bottom.width.equalToSuperview()
//////            make.height.greaterThanOrEqualTo(200)
//////            make.height.equalTo(image.frame.height)
////            make.height.equalTo(image.image?.size.height ?? 0)
////
////        }
//
//    }
    override func configureHierarchy() {
        contentView.addSubview(tempLabel)
        contentView.addSubview(image)
    }
    
//    func setImageHeight(height: CGFloat) {
//        image.snp.makeConstraints { make in
//            make.top.equalTo(tempLabel.snp.bottom)//.offset(10)
//            make.bottom.width.equalToSuperview()
////            make.height.greaterThanOrEqualTo(200)
//            make.height.equalTo(height)
//        }
//    }
    
    override func configureLayout() {
        tempLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()//.inset(15)
//            make.height.equalTo(24)
        }
        image.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom)//.offset(10)
            make.bottom.width.equalToSuperview()
//            make.height.greaterThanOrEqualTo(200)
//            make.height.equalTo(226)
        }
    }
    
    override func configureView() {
        tempLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.systemGray5.cgColor
        
        clipsToBounds = true
    }
}
