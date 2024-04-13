//
//  PostQuery.swift
//  Coordi
//
//  Created by 차소민 on 4/12/24.
//

import Foundation

struct PostQuery: Encodable {
    let title: String
    let content: String     // 해시태그
    let content1: String    // 본문
    let content2: String    // 가격
    let product_id: String  // 피드인지 상품화면인지 구분
    let files: [String]     // 사진
}
