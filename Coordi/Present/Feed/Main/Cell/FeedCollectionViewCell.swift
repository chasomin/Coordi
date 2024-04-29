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
    let heartCountLabel = UILabel()
    let heartImageView = UIImageView()
    let commentCountLabel = UILabel()
    let commentImageView = UIImageView()

    let colors: [CGColor] = [
        .init(red: 0, green: 0, blue: 0, alpha: 0.7),
        .init(red: 0, green: 0, blue: 0, alpha: 0.5),
        .init(red: 0, green: 0, blue: 0, alpha: 0.3),
        .init(red: 0, green: 0, blue: 0, alpha: 0)
    ]
    let gradientLayer = CAGradientLayer()

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
        contentView.addSubview(image)
        image.layer.addSublayer(gradientLayer)
        image.addSubview(tempLabel)
        image.addSubview(heartCountLabel)
        image.addSubview(heartImageView)
        image.addSubview(commentCountLabel)
        image.addSubview(commentImageView)

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

        image.snp.makeConstraints { make in
            make.verticalEdges.width.equalToSuperview()
//            make.height.greaterThanOrEqualTo(200)
//            make.height.equalTo(226)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
//            make.height.equalTo(24)
        }
        
        commentImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(tempLabel.snp.trailing).offset(10)
            make.size.equalTo(17)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(commentImageView.snp.trailing)
            make.height.equalTo(17)
        }
        
        heartImageView.snp.makeConstraints { make in
            make.leading.equalTo(commentCountLabel.snp.trailing).offset(5)
            make.bottom.equalToSuperview().inset(10)
            make.size.equalTo(17)
        }
        heartCountLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(heartImageView.snp.trailing)
            make.height.equalTo(17)
        }
        
    }
    
    override func configureView() {
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.8)
        
        tempLabel.font = .boldBody
        tempLabel.textColor = .white
        
        image.contentMode = .scaleAspectFill
//        image.layer.cornerRadius = 20
//        image.clipsToBounds = true
//        image.layer.borderWidth = 1
//        image.layer.borderColor = UIColor.systemGray5.cgColor
        
        heartCountLabel.font = .caption
        heartCountLabel.textColor = .white
        heartImageView.tintColor = .white
        
        commentCountLabel.font = .caption
        commentCountLabel.textColor = .white
        commentImageView.tintColor = .white
        commentImageView.image = UIImage(systemName: "ellipses.bubble")
        
        clipsToBounds = true
    }
    
    func configureCell(item: PostModel) {
        image.loadImage(from: item.files.first!)
        tempLabel.text = item.temp
        heartCountLabel.text = item.likes.count.description
        heartImageView.image = item.likes.contains(UserDefaultsManager.userId) ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        commentCountLabel.text = item.comments.count.description
    }
}


