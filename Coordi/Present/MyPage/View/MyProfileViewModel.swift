//
//  MyProfileViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyProfileViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let editButtonTap: Observable<Void>
    }
    
    struct Output {
        let editButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output.init(editButtonTap: input.editButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
