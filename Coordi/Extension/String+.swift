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
    
    func timeFormatString() -> Self {
        let formatToDate = DateFormatter()
        formatToDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatToDate.date(from: self) else { return "" }
        
        
        let offsetComps = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: Date())
        
        guard let second = offsetComps.second else { return ""}
        guard let minute = offsetComps.minute else { return "" }
        guard let hour = offsetComps.hour else { return "" }
        guard let day = offsetComps.day else { return "" }
        
        if day != 0 {
            return "\(day)일 전"
        } else if hour != 0 {
            return "\(hour)시간 전"
        } else if minute != 0 {
            return "\(minute)분 전"
        } else {
            return "\(second)초 전"
        }
    }

}
