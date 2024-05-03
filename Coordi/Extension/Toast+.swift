//
//  Toast+.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import UIKit
import Toast

extension BaseViewController {
    func showErrorToast(_ text: String) {
        var style = ToastStyle.init()
        style.backgroundColor = .pointColor
        style.titleColor = .backgroundColor
        style.cornerRadius = 15
        style.imageSize = CGSize(width: 50, height: 50)
        style.messageFont = .caption
        style.titleFont = .boldBody
        view.makeToast(text, duration: 2, position: .center, title: "오류", image: .error, style: style)
    }
    
    func showCheckToast(_ completionHandler: () -> Void) {
        var style = ToastStyle.init()
        style.backgroundColor = .pointColor
        style.titleColor = .backgroundColor
        style.cornerRadius = 15
        view.makeToast(nil, duration: 1, position: .center, image: .check, style: style)
        completionHandler()
    }
    
    func showToastActivity() {
        view.makeToastActivity(.center)
    }
    
    func hideToastActivity() {
        view.hideToastActivity()
    }
}
