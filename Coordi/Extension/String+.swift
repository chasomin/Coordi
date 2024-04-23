//
//  String+.swift
//  Coordi
//
//  Created by 차소민 on 4/23/24.
//

import Foundation

extension String {
    func dateFormatString() -> Self {
        let formatToDate = DateFormatter()
        formatToDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatToDate.date(from: self) else { return "" }
        let format = DateFormatter()
        format.dateFormat = "yyyy년 M월 d일"
        return format.string(from: date)
    }
}
