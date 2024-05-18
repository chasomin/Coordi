//
//  ChatBubble.swift
//  Coordi
//
//  Created by 차소민 on 5/20/24.
//

import UIKit
import SnapKit

final class ChatBubble: UIView {
    let isMyBubble: Bool
    let content = UILabel()
    
    init(isMyBubble: Bool) {
        self.isMyBubble = isMyBubble
        super.init()
        
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide).inset(15)
        }
        
        backgroundColor = isMyBubble ? .pointColor : .systemGray6
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
