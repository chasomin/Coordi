//
//  ChatSendQuery.swift
//  Coordi
//
//  Created by 차소민 on 5/26/24.
//

import Foundation

struct ChatSendQuery: Encodable {
    let content: String?
    let files: [String]?
    
    init(content: String) {
        self.content = content
        self.files = nil
    }
    
    init(files: [String]) {
        self.content = nil
        self.files = files
    }
}
