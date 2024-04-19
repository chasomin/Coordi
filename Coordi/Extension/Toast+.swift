//
//  Toast+.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import UIKit
import Toast

extension BaseViewController {
    func showErrorToast() {
        var style = ToastStyle.init()
        style.backgroundColor = .pointColor
        style.titleColor = .backgroundColor
        view.makeToast(nil, duration: 2, position: .top, title: "⚠️오류가 발생했습니다\n잠시후에 다시 시도해주세요", style: style) //TODO: 오류 처리
    }
    
    func showDoneToast() {
        var style = ToastStyle.init()
        style.backgroundColor = .pointColor
        style.titleColor = .backgroundColor
        style.cornerRadius = 15
        view.makeToast(nil, duration: 1, position: .center, image: .check, style: style)
    }
}
