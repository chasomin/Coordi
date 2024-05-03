//
//  FeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FeedViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let searchButtonTap: Observable<Void>
        let temp: PublishRelay<Int>
    }
    
    struct Output {
        let tempText: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let tempText = PublishRelay<String>()

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
        
        return Output.init(tempText: tempText.asDriver(onErrorJustReturn: ""))
    }
}
