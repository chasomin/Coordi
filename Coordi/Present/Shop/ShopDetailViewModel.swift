//
//  ShopDetailViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShopDetailViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    private let product: PostModel
    
    init(product: PostModel) {
        self.product = product
    }
    
    struct Input {
        let reloadData: PublishRelay<Void>
    }
    
    struct Output {
        let product: Driver<PostModel>
    }
    
    func transform(input: Input) -> Output {
        let product = PublishRelay<PostModel>()
        
        input.reloadData
            .bind(with: self) { owner, _ in
                product.accept(owner.product)
            }
            .disposed(by: disposeBag)
        
        return Output.init(product: product.asDriver(onErrorJustReturn: .dummy))
    }
}
