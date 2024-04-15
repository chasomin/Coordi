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
