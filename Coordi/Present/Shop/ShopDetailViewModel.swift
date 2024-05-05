//
//  ShopDetailViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa
import iamport_ios

final class ShopDetailViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    private let product: PostModel
    
    init(product: PostModel) {
        self.product = product
    }
    
    struct Input {
        let reloadData: PublishRelay<Void>
        let purchaseButtonTap: PublishRelay<Void>
        let shoppingBagButtonTap: PublishRelay<Void>
        let bookmarkTap: PublishRelay<Void>
    }
    
    struct Output {
        let product: Driver<PostModel>
        let failureTrigger: Driver<String>
        let putItInSuccessTrigger: Driver<Void>
        let bookmarkSuccessTrigger: Driver<LikeModel>

    }
    
    func transform(input: Input) -> Output {
        let product = PublishRelay<PostModel>()
        let failureTrigger = PublishRelay<String>()
        let putItInSuccessTrigger = PublishRelay<Void>()
        let bookmarkSuccessTrigger = PublishRelay<LikeModel>()

        input.reloadData
            .bind(with: self) { owner, _ in
                product.accept(owner.product)
            }
            .disposed(by: disposeBag)
        
        input.purchaseButtonTap
            .withUnretained(self)
            .map { owner, _ in
                let payment =  IamportPayment(pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                                              merchant_uid: "ios_\(APIKey.key.rawValue)_\(Int(Date().timeIntervalSince1970))",
                                              amount: "100").then {
                    $0.pay_method = PayMethod.card.rawValue
                    $0.name = owner.product.content1
                    $0.buyer_name = "차소민"
                    $0.app_scheme = Constants.appScheme
                }
                return payment
            }
            .bind(with: self) { owner, payment in
                let vm = PaymentViewModel(payment: payment, product: owner.product)
                let vc = PaymentViewController(viewModel: vm)
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(vc, animation: true)
            }
            .disposed(by: disposeBag)
        
        input.shoppingBagButtonTap
            .withUnretained(self)
            .flatMap { owner, _ in
                NetworkManager.request(api: .like2(postId: owner.product.post_id, query: .init(like_status: true)))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<LikeModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<LikeModel>.never()
                    }
            }
            .bind(with: self) { owner, _ in
                putItInSuccessTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.bookmarkTap
            .withUnretained(self)
            .flatMap { owner, _ in
                let likeStatus = owner.product.likes.contains(UserDefaultsManager.userId)

                return NetworkManager.request(api: .like(postId: owner.product.post_id, query: .init(like_status: likeStatus ? false : true)))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<LikeModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<LikeModel>.never()
                    }
            }
            .bind(with: self) { owner, like in
                bookmarkSuccessTrigger.accept(like)
            }
            .disposed(by: disposeBag)

        
        return Output.init(product: product.asDriver(onErrorJustReturn: .dummy),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           putItInSuccessTrigger: putItInSuccessTrigger.asDriver(onErrorJustReturn: ()),
                           bookmarkSuccessTrigger: bookmarkSuccessTrigger.asDriver(onErrorJustReturn: .init(like_status: false)))
    }
}
