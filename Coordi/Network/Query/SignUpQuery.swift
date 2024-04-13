//
//  SignUpQuery.swift
//  Coordi
//
//  Created by 차소민 on 4/12/24.
//

import Foundation

struct SignUpQuery: Encodable {
    let email: String
    let password: String
    let nick: String
}
