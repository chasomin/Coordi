//
//  FeedContentView.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit

final class FeedContentCollectionViewCell: BaseCollectionViewCell {
    let tempLabel = UILabel()
    let heartButton = UIButton()
    let contentLabel = UILabel()
    let dateLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(tempLabel)
        contentView.addSubview(heartButton)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
    }
    override func configureLayout() {
        tempLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(24)
        }
        heartButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.height.equalTo(24)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.greaterThanOrEqualTo(24)

        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }
    override func configureView() {
        tempLabel.font = .body
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        contentLabel.font = .body
        contentLabel.numberOfLines = 0
        dateLabel.textColor = .gray
        dateLabel.font = .caption
    }
    
    func configureCell(item: PostModel) {
        contentLabel.text = item.content1
        dateLabel.text = item.createdAt
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        tempLabel.text = item.content
    }
}
