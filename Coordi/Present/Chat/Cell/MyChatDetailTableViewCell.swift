//
//  MyChatDetailTableViewCell.swift
//  Coordi
//
//  Created by 차소민 on 5/20/24.
//

import UIKit
import SnapKit

final class MyChatDetailTableViewCell: BaseTableViewCell {
    let contentBubble = ChatBubble(isMyBubble: true)
    let date = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(contentBubble)
        contentView.addSubview(date)
    }
    
    override func configureLayout() {
        contentBubble.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalTo(contentView).inset(15)
        }
        
        date.snp.makeConstraints { make in
            make.trailing.equalTo(contentBubble.snp.leading)
            make.bottom.equalTo(contentBubble)
        }
    }
    
    override func configureView() {
        date.font = .caption
        date.textColor = .lightGray
        
    }
}
