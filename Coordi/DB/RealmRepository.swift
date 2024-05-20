//
//  RealmRepository.swift
//  Coordi
//
//  Created by 차소민 on 5/20/24.
//

import Foundation
import RealmSwift

final class RealmRepository {
    let realm = try! Realm()
    
    // MARK: - Create
    func createChat(chat: RealmChatModel) {
        do {
            print(realm.configuration.fileURL ?? "")
            try realm.write {
                realm.add(chat)
            }
        } catch {
            print("⚠️ Realm Create 오류", error)
        }
    }

    // MARK: - Read
    func readChat() -> Results<RealmChatModel> {
        return realm.objects(RealmChatModel.self)
    }
}
