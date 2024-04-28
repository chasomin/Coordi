//
//  FeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FeedViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let searchButtonTap: Observable<Void>
    }
    
    struct Output {
        let serarchButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        return Output.init(serarchButtonTap: input.searchButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
