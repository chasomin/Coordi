//
//  CommentCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit

final class CommentTableViewCell: BaseTableViewCell {    
    let profileImageView = CirCleImageView()
    let nicknameLabel = UILabel()
    let commentLabel = UILabel()
    let dateLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(dateLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.size.equalTo(40)
            make.top.equalToSuperview().inset(15)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.height.equalTo(24)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(nicknameLabel.snp.trailing).offset(5)
            make.verticalEdges.equalTo(nicknameLabel)
            make.trailing.equalToSuperview().inset(15)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom)
            make.leading.equalTo(nicknameLabel)
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    override func configureView() {
        nicknameLabel.font = .caption
        nicknameLabel.textColor = .gray
        commentLabel.numberOfLines = 0
        commentLabel.font = .caption
        dateLabel.font = .caption
        dateLabel.textColor = .gray
        profileImageView.backgroundColor = .pointColor
        
    }
    
    func configureCell(item: CommentModel) {
        commentLabel.text = item.content
        nicknameLabel.text = item.creator.nick
        profileImageView.loadImage(from: item.creator.profileImage)
        dateLabel.text = item.createdAt.timeFormatString()
    }
}
