//
//  CoordiUserDefaults.swift
//  Coordi
//
//  Created by 차소민 on 4/18/24.
//

import Foundation

@propertyWrapper
struct CoordiUserDefaults<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
