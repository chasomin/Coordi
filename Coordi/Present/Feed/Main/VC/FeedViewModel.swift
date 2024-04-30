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
        let temp: PublishRelay<Double>
    }
    
    struct Output {
        let serarchButtonTap: Driver<Void>
        let temp: Driver<Int>
        let tempText: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let temp = PublishRelay<Int>()
        let tempText = PublishRelay<String>()

        input.temp
            .map { Int($0) }
            .bind(to: temp)
            .disposed(by: disposeBag)
        
        input.temp
            .map { "현재 \(Int($0))℃" }
            .bind(to: tempText)
            .disposed(by: disposeBag)
        
        return Output.init(serarchButtonTap: input.searchButtonTap.asDriver(onErrorJustReturn: ()),
                           temp: temp.asDriver(onErrorJustReturn: 0),
                           tempText: tempText.asDriver(onErrorJustReturn: ""))
    }
}
