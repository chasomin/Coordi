//
//  MyProfileView.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyProfileView: BaseView {
    static let id = MyProfileView.description()

    private let profileImageView = CirCleImageView()
    private let infoStack = UIStackView()
    private let nicknameLabel = UILabel()
    private let followStack = UIStackView()
    private let postLabel = UILabel()
    private let postCount = UILabel()
    private let followerLabel = UILabel()
    let followerCount = UILabel()
    private let followingLabel = UILabel()
    private let followingCount = UILabel()
    let editButton = CapsuleButton(text: "프로필 관리", textColor: .backgroundColor, backColor: .LabelColor, font: .boldBody)
    let followButton = CapsuleButton(text: "", textColor: .backgroundColor, backColor: .LabelColor, font: .boldBody)
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(infoStack)
        infoStack.addArrangedSubview(nicknameLabel)
        infoStack.addArrangedSubview(followStack)
        followStack.addArrangedSubview(postLabel)
        followStack.addArrangedSubview(postCount)
        followStack.addArrangedSubview(followerLabel)
        followStack.addArrangedSubview(followerCount)
        followStack.addArrangedSubview(followingLabel)
        followStack.addArrangedSubview(followingCount)
        addSubview(editButton)
        addSubview(followButton)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(70)
        }
        infoStack.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.height.equalTo(40)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualToSuperview().inset(5)
        }
        editButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(15)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        followButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(15)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    override func configureView() {
        infoStack.axis = .vertical
        infoStack.spacing = 10
        
        followStack.axis = .horizontal
        followStack.spacing = 5
        followStack.alignment = .leading
        followerLabel.font = .caption
        followerCount.font = .caption
        followingLabel.font = .caption
        followingCount.font = .caption
        postCount.font = .caption
        postLabel.font = .caption
        nicknameLabel.font = .body

        profileImageView.backgroundColor = .pointColor
        followerLabel.text = "팔로워"
        followingLabel.text = "팔로잉"
        postLabel.text = "게시글"
    }
    
    func configure(profile: ProfileModel) {
        profileImageView.loadImage(from: profile.profileImage)
        nicknameLabel.text = profile.nick
        followerCount.text = "\(profile.followers.count)"
        followingCount.text = "\(profile.following.count)"
        postCount.text = "\(profile.posts.count)"
        if profile.followers.map({ $0.user_id == UserDefaultsManager.userId }).isEmpty {
            followButton.setTitle(text: "팔로우", font: .boldBody)
        } else {
            followButton.setTitle(text: "팔로우 취소", font: .boldBody)
        }

    }
}

