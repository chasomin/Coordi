//
//  CapsuleButton.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit

final class CapsuleButton: UIButton {
    let text: String
    let textColor: UIColor
    let backColor: UIColor
    
    init(text: String, textColor: UIColor, backColor: UIColor, font: UIFont) {
        self.text = text
        self.textColor = textColor
        self.backColor = backColor
        
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = backColor
        config.baseForegroundColor = textColor
        var attr = AttributedString.init(text)
        attr.font = font
        config.attributedSubtitle = attr
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
