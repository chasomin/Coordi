//
//  ProfileQuery.swift
//  Coordi
//
//  Created by 차소민 on 4/13/24.
//

import Foundation

struct ProfileImageQuery: Encodable {
    let profile: Data
}

struct ProfileNickQuery: Encodable {
    let nick: String
}
