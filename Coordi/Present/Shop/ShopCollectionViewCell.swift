//
//  ShopCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import UIKit
import SnapKit

final class ShopCollectionViewCell: BaseCollectionViewCell {
    private let imageView = UIImageView()
    private let brandLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let bookmark = UIImageView()
    private let bookmarkCount = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(brandLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(bookmark)
        contentView.addSubview(bookmarkCount)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(imageView)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom)
            make.horizontalEdges.equalTo(imageView)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(imageView)
        }
        bookmark.snp.makeConstraints { make in
            make.leading.equalTo(imageView)
            make.top.equalTo(priceLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview()
        }
        bookmarkCount.snp.makeConstraints { make in
            make.leading.equalTo(bookmark.snp.trailing)
            make.top.equalTo(bookmark)
            make.trailing.equalTo(imageView)
            make.bottom.equalToSuperview()
        }
        
    }
    
    override func configureView() {
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        brandLabel.font = .boldBody
        nameLabel.font = .body
        priceLabel.font = .boldBody
        bookmarkCount.font = .caption
        bookmarkCount.textColor = .gray
    }
    
    func configureCell(item: PostModel) {
        imageView.loadImage(from: item.files.first!)
        brandLabel.text = item.brand
        nameLabel.text = item.content1
        priceLabel.text = item.price
        bookmark.image = UIImage(systemName: item.likes.contains(UserDefaultsManager.userId) ? "bookmark.fill" : "bookmark")
        bookmarkCount.text = "\(item.likes.count)"
    }
}
