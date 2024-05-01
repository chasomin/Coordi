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
        view.makeToast(nil, duration: 1, position: .top, title: text, style: style) //TODO: 오류 처리
    }
    
    func showCheckToast(_ completionHandler: () -> Void) {
        var style = ToastStyle.init()
        style.backgroundColor = .pointColor
        style.titleColor = .backgroundColor
        style.cornerRadius = 15
        view.makeToast(nil, duration: 1, position: .center, image: .check, style: style)
        completionHandler()
    }
}
