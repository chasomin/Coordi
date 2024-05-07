//
//  PaymentValidModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation

struct PaymentValidModel: Decodable {
    let payment_id: String
    let buyer_id: String
    let post_id: String
    let merchant_uid: String
    let productName: String
    let price: Int
    let paidAt: String
}
