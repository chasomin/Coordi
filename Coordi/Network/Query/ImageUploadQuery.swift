//
//  ImageUploadQuery.swift
//  Coordi
//
//  Created by 차소민 on 4/12/24.
//

import Foundation

/// - 확장자 제한: jpg, png, jpeg, gif, pdf
/// - 용량 제한:   5MB
/// - 파일 개수:   최대 5개
struct ImageUploadQuery: Encodable {
    let files: Data
}
