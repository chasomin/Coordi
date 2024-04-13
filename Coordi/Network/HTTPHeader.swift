//
//  HTTPHeader.swift
//  Coordi
//
//  Created by 차소민 on 4/14/24.
//

import Foundation

enum HTTPHeader: String {
    case authorization = "Authorization"
    case sesacKey = "SesacKey"
    case refresh = "Refresh"
    case contentType = "Content-Type"
    case json = "application/json"
    case multi = "multipart/form-data"
}
