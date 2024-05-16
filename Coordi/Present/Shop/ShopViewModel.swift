//
//  ShopViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShopViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    struct Input {
        let reloadData: PublishRelay<Void>
        let selectItem: PublishRelay<PostModel>
        let keyboardDismissGesture: PublishRelay<Void>
    }
    
    struct Output {
        let product: Driver<[PostModel]>
        let failureTrigger: Driver<String>
        let searchDone: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let products = PublishRelay<[PostModel]>()
        let failureTrigger = PublishRelay<String>()
        let shoppingBagItems = PublishRelay<[PostModel]>()
        
        input.reloadData
            .withUnretained(self)
            .flatMap { owner, _ in
                NetworkManager.request(api: .fetchPost(query: .init(next: "", limit: "10", product_id: Constants.shopProductId)))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostListModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostListModel>.never()
                    }
            }
            .bind(with: self) { owner, items in
                products.accept(items.data)
            }
            .disposed(by: disposeBag)
        
        input.reloadData
            .withUnretained(self)
            .flatMap { owner, _ in
                NetworkManager.request(api: .fetchLike2Post(query: .init(next: "", limit: "10", product_id: Constants.productId)))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostListModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostListModel>.never()
                    }
            }
            .bind { value in
                shoppingBagItems.accept(value.data)
            }
            .disposed(by: disposeBag)
        
        input.selectItem
            .bind(with: self) { owner, product in
                let vm = ShopDetailViewModel(product: product)
                vm.coordinator = owner.coordinator
                let vc = ShopDetailViewController(viewModel: vm)
                owner.coordinator?.push(vc, animation: true)
            }
            .disposed(by: disposeBag)
        
        return Output.init(product: products.asDriver(onErrorJustReturn: []),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           searchDone: input.keyboardDismissGesture.asDriver(onErrorJustReturn: ()))
    }
}
