//
//  PaymentViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa
import iamport_ios

final class PaymentViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    let payment: IamportPayment
    let product: PostModel
    
    init(payment: IamportPayment, product: PostModel) {
        self.payment = payment
        self.product = product
    }
    
    struct Input {
        let viewDidLoadTrigger: PublishRelay<Void>
        let paymentDone: PublishRelay<String?>
    }
    
    struct Output {
        let payment: Driver<IamportPayment>
    }
    
    func transform(input: Input) -> Output {
        let payment = PublishRelay<IamportPayment>()
        let failureTrigger = PublishRelay<String>()
        
        input.viewDidLoadTrigger
            .bind(with: self) { owner, _ in
                payment.accept(owner.payment)
            }
            .disposed(by: disposeBag)
        
        input.paymentDone
            .withUnretained(self)
            .flatMap { owner, uid in
                let query = PaymentValidQuery(imp_uid: uid ?? "",
                                              post_id: owner.product.post_id,
                                              productName: owner.product.content1,
                                              price: 100)//
                return NetworkManager.request(api: .paymentValid(query: query))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PaymentValidModel>.never() }
                        failureTrigger.accept(errorMessage)
                        print("📌결제 실패!!!")
                        return Single<PaymentValidModel>.never()
                    }
            }
            .bind(with: self, onNext: { owner, paymentValid in
                print("📌결제 성공!")
                owner.coordinator?.pop(animation: true)
            })
            .disposed(by: disposeBag)
        
        return Output.init(payment: payment.asDriver(onErrorJustReturn: .init(pg: "", merchant_uid: "", amount: "")))
    }
}
