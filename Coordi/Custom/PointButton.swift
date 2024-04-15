//
//  PointButton.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import UIKit

final class PointButton: UIButton {
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .pointColor
        config.baseForegroundColor = .backgroundColor
        var attr = AttributedString.init(text)
        attr.font = UIFont.boldSystemFont(ofSize: 18)
        config.attributedSubtitle = attr
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
