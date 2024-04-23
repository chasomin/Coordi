//
//  ProfileNavigationView.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit
final class ProfileNavigationCollectionViewCell: BaseCollectionViewCell {
    let profileImage = CirCleImageView()
    let nicknameLabel = UILabel()
    let backButton = UIButton()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImage)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(backButton)
    }
    
    override func configureLayout() {
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10)
        }
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(35)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    override func configureView() {
        let config = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 22))
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(image,for: .normal)
        backButton.scalesLargeContentImage = true
        
        profileImage.backgroundColor = .pointColor
        nicknameLabel.font = .caption
    }
    
    func configureCell(item: UserModel) {
        nicknameLabel.text = item.nick
        profileImage.loadImage(from: item.profileImage)
    }
}
