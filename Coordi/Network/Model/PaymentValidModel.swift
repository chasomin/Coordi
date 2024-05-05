//
//  PaymentValidModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation

struct PaymentValidModel: Decodable {
    let imp_uid: String
    let post_id: String
    let productName: String
    let price: Int
}
