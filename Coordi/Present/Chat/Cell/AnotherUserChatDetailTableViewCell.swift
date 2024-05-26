//
//  AnotherUserChatDetailTableViewCell.swift
//  Coordi
//
//  Created by 차소민 on 5/20/24.
//

import UIKit
import SnapKit

final class AnotherUserChatDetailTableViewCell: BaseTableViewCell {
    let image = CirCleImageView()
    let nickname = UILabel()
    let contentBubble = ChatBubble(isMyBubble: false)
    let date = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(image)
        contentView.addSubview(nickname)
        contentView.addSubview(contentBubble)
        contentView.addSubview(date)
    }
    
    override func configureLayout() {
        image.snp.makeConstraints { make in
            make.top.leading.top.equalTo(contentView.safeAreaLayoutGuide).inset(15)
            make.size.equalTo(40)
        }
        
        nickname.snp.makeConstraints { make in
            make.top.equalTo(image)
            make.leading.equalTo(image.snp.trailing).offset(5)
        }
        
        contentBubble.snp.makeConstraints { make in
            make.leading.equalTo(nickname)
            make.top.equalTo(nickname.snp.bottom).offset(5)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(15)
        }
        
        date.snp.makeConstraints { make in
            make.bottom.equalTo(contentBubble)
            make.leading.equalTo(contentBubble.snp.trailing).offset(5)
        }
    }
    
    override func configureView() {
        nickname.font = .caption
        date.font = .caption
        date.textColor = .lightGray
    }

}

