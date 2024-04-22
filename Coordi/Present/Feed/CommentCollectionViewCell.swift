//
//  CommentCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit

final class CommentCollectionViewCell: BaseCollectionViewCell {
    let profileImageView = CirCleImageView()
    let nicknameLabel = UILabel()
    let commentLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(commentLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(50)
            make.top.equalTo(contentView.snp.top)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(15)
            make.height.equalTo(24)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(15)
            make.height.greaterThanOrEqualTo(30)
        }
    }
    
    override func configureView() {
        commentLabel.numberOfLines = 0
        
        commentLabel.setContentHuggingPriority(.required, for: .vertical)
    }
}
