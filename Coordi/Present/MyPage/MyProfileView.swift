//
//  MyProfileView.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit
import SnapKit

final class MyProfileView: UICollectionReusableView {
    static let id = MyProfileView.description()
    
    let profileImageView = CirCleImageView()
    let infoStack = UIStackView()
    let nicknameLabel = UILabel()
    let followStack = UIStackView()
    let followerLabel = UILabel()
    let followerCount = UILabel()
    let followingLabel = UILabel()
    let followingCount = UILabel()
    let editButton = CapsuleButton(text: "프로필 관리", textColor: .backgroundColor, backColor: .LabelColor, font: .boldBody)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(infoStack)
        infoStack.addArrangedSubview(nicknameLabel)
        infoStack.addArrangedSubview(followStack)
        followStack.addArrangedSubview(followerLabel)
        followStack.addArrangedSubview(followerCount)
        followStack.addArrangedSubview(followingLabel)
        followStack.addArrangedSubview(followingCount)
        addSubview(editButton)
    }
    
    func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(5)
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
            make.horizontalEdges.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(15)
            make.height.equalTo(30)
        }
    }
    
    func configureView() {
        infoStack.axis = .vertical
        infoStack.spacing = 10
        
        followStack.axis = .horizontal
        followStack.spacing = 5
        followStack.alignment = .leading
        followerLabel.font = .caption
        followerCount.font = .caption
        followingLabel.font = .caption
        followingCount.font = .caption

        profileImageView.backgroundColor = .pointColor
        nicknameLabel.text = "닉네임"
        nicknameLabel.font = .body
        followerLabel.text = "팔로워"
        followingLabel.text = "팔로잉"
        followerCount.text = "0"
        followingCount.text = "0"
    }
}
