//
//  ProfileNavigationView.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit
import RxSwift

final class ProfileNavigationCollectionViewCell: BaseCollectionViewCell {
    var disposeBag = DisposeBag()
    
    let profileImage = CirCleImageView()
    let nicknameLabel = UILabel()
    let backButton = UIButton()
    let tapGesture = UITapGestureRecognizer()
    let editButton = UIButton()
    
//    let editAction = UIAction(title: "삭제하기", handler: { _ in })//
//    let deleteAction = UIAction(title: "삭제하기", attributes: .destructive, handler: { _ in print("확인") })//

    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImage)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(backButton)
        profileImage.addGestureRecognizer(tapGesture)
        contentView.addSubview(editButton)
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
        editButton.snp.makeConstraints { make in
            make.top.equalTo(backButton)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    override func configureView() {
        let image = UIImage(systemName: "chevron.left")?.setConfiguration(font: .boldSystemFont(ofSize: 22))
        backButton.setImage(image,for: .normal)
        backButton.scalesLargeContentImage = true
        
        profileImage.backgroundColor = .pointColor
        profileImage.isUserInteractionEnabled = true
        nicknameLabel.font = .caption
        
        let editImage = UIImage(systemName: "ellipsis")?.setConfiguration(font: .boldSystemFont(ofSize: 22))
        editButton.setImage(editImage,for: .normal)
        editButton.showsMenuAsPrimaryAction = true
//        let buttonMenu = UIMenu(title: "", children: [edit, delete])
//        editButton.menu = buttonMenu
    }
    
    func configureCell(item: UserModel) {
        nicknameLabel.text = item.nick
        profileImage.loadImage(from: item.profileImage)
        
        if item.user_id != UserDefaultsManager.userId {
            editButton.isHidden = true
        }
    }
}
