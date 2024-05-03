//
//  ViewModelType.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import Foundation
import RxSwift

protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get }
    
    func transform(input: Input) -> Output
}

protocol CoordinatorViewModelType: ViewModelType {
    var coordinator: Coordinator? { get }
}

extension CoordinatorViewModelType {
    func choiceLoginOrMessage(error: CoordiError) -> String? {
        switch error {
        case .accessTokenExpired, .unauthenticatedToken:
            UserDefaultsManager.accessToken = ""
            UserDefaultsManager.refreshToken = ""
            UserDefaultsManager.userId = ""
            coordinator?.end()
            print("😇")
            return nil
        default:
            return error.errorMessage
        }
    }
}

