//
//  CapsuleButton.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit

final class CapsuleButton: UIButton {
    private let text: String
    private let textColor: UIColor
    private let backColor: UIColor
    private let isPointButton: Bool?

    lazy var config = isPointButton! ? UIButton.Configuration.filled() : UIButton.Configuration.tinted()

    
    
    init(text: String, textColor: UIColor, backColor: UIColor, font: UIFont, isPointButton: Bool? = true) {
        self.text = text
        self.textColor = textColor
        self.backColor = backColor
        self.isPointButton = isPointButton
        
        super.init(frame: .zero)
        
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
    
    func setTitle(text: String, font: UIFont) {
        var attr = AttributedString.init(text)
        attr.font = font
        config.attributedSubtitle = attr
        self.configuration = config
    }
}
