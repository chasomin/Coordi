//
//  PaymentListModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation

struct PaymentListModel: Decodable {
    let data: [PaymentProductModel]
}

struct PaymentProductModel: Decodable {
    let payment_id: String
    let buyer_id: String
    let post_id: String
    let merchant_uid: String
    let productName: String
    let price: Int
    let paidAt: String
}
