//
//  CircleButton.swift
//  Coordi
//
//  Created by 차소민 on 5/3/24.
//

import UIKit

final class CircleButton: UIButton {
    private let image: String
    
    init(image: String) {
        self.image = image
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .pointColor
        config.baseForegroundColor = .white
        let image = UIImage(systemName: image)?.setConfiguration(font: .boldTitle)
        config.image = image
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
