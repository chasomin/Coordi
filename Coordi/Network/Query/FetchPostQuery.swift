//
//  FetchPostQuery.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import Foundation

struct FetchPostQuery {
    let next: String
    let limit: String
    let product_id: String
    let hashTag: String?
    
    init(next: String, limit: String, product_id: String, hashTag: String) {
        self.next = next
        self.limit = limit
        self.product_id = product_id
        self.hashTag = hashTag
    }
    
    init(next: String, limit: String, product_id: String) {
        self.next = next
        self.limit = limit
        self.product_id = product_id
        self.hashTag = ""
    }

}
