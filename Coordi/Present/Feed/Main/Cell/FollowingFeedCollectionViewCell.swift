//
//  FollowingFeedCollectionViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/26/24.
//

import UIKit
import SnapKit

final class FollowingFeedCollectionViewCell: BaseCollectionViewCell {
    
    private let profileImageView = CirCleImageView()
    private let nicknameLabel = UILabel()
    private let contentImageView = UIImageView()
    private let contentLabel = UILabel()
    private let commentCountLabel = UILabel()
    private let commentImageView = UIImageView()
    private let heartCountLabel = UILabel()
    private let heartImageView = UIImageView()

    override func configureHierarchy() {
        contentView.addSubview(contentImageView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(commentImageView)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(heartImageView)
        contentView.addSubview(heartCountLabel)

    }
    
    override func configureLayout() {
        contentImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(contentImageView.snp.width).multipliedBy(1.1)
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentImageView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.size.equalTo(30)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.verticalEdges.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
        }
        
        heartCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.verticalEdges.equalTo(profileImageView)
        }
        heartImageView.snp.makeConstraints { make in
            make.trailing.equalTo(heartCountLabel.snp.leading)
            make.verticalEdges.equalTo(profileImageView).inset(5)
            make.width.equalTo(heartImageView.snp.height)
        }
        commentCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(heartImageView.snp.leading).inset(-5)
            make.verticalEdges.equalTo(profileImageView)
        }
        commentImageView.snp.makeConstraints { make in
            make.trailing.equalTo(commentCountLabel.snp.leading)
            make.verticalEdges.equalTo(profileImageView).inset(5)
            make.leading.greaterThanOrEqualTo(nicknameLabel.snp.trailing).offset(10)
            make.width.equalTo(commentImageView.snp.height)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
        }
    }
    
    override func configureView() {
        profileImageView.backgroundColor = .pointColor
        nicknameLabel.font = .caption
        contentLabel.font = .caption
        commentCountLabel.font = .caption
        heartCountLabel.font = .caption
        commentImageView.image = UIImage(systemName: "ellipsis.bubble")
        contentImageView.layer.cornerRadius = 15
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
    }
    
    func configureCell(item: PostModel) {
        profileImageView.loadImage(from: item.creator.profileImage)
        nicknameLabel.text = item.creator.nick
        contentImageView.loadImage(from: item.files.first!)
        contentLabel.text = item.content1
        contentLabel.numberOfLines = 2
        commentCountLabel.text = "\(item.comments.count)"
        heartCountLabel.text = "\(item.likes.count)"
        heartImageView.image = item.likes.contains(UserDefaultsManager.userId) ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
    }
}
