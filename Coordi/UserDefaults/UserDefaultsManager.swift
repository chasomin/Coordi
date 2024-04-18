//
//  UserDefaultsManager.swift
//  Coordi
//
//  Created by 차소민 on 4/18/24.
//

import Foundation

enum UserDefaultsManager {
    enum Key: String {
        case user_id, accessToken, refreshToken
    }
    
    @CoordiUserDefaults(key: Key.user_id.rawValue, defaultValue: "")
    static var userId
    
    @CoordiUserDefaults(key: Key.accessToken.rawValue, defaultValue: "")
    static var accessToken
    
    @CoordiUserDefaults(key: Key.refreshToken.rawValue, defaultValue: "")
    static var refreshToken
}
