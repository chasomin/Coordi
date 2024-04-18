//
//  EditProfileViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let imageTap: Observable<Void>
        let labelTap: Observable<Void>
    }
    
    struct Output {
        let imageTap: Driver<Void>
        let labelTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output.init(imageTap: input.imageTap.asDriver(onErrorJustReturn: ()),
                           labelTap: input.labelTap.asDriver(onErrorJustReturn: ()))
    }
}
