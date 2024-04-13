//
//  SignUpModel.swift
//  Coordi
//
//  Created by 차소민 on 4/13/24.
//

import Foundation

struct SignUpModel: Decodable {
    let email: String
    let password: String
    let nick: String
}
