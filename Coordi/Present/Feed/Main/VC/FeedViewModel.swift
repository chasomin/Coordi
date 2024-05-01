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
    
    weak var coordinator: FeedCoordinator?
    
    struct Input {
        let searchButtonTap: Observable<Void>
        let temp: PublishRelay<Double>
    }
    
    struct Output {
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
        
        input.searchButtonTap
            .bind(with: self) { owner, _ in
                let vm = SearchViewModel()
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(SearchViewController(viewModel: vm))
            }
            .disposed(by: disposeBag)
        
        return Output.init(temp: temp.asDriver(onErrorJustReturn: 0),
                           tempText: tempText.asDriver(onErrorJustReturn: ""))
    }
}
