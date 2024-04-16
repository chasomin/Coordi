//
//  CirCleImageView.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit

class CirCleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}
