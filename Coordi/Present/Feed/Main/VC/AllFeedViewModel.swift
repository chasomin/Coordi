//
//  AllFeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class AllFeedViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let dataReload: PublishRelay<Void>
        let itemSelected: PublishRelay<PostModel>
    }
    
    struct Output {
        let postData: Driver<[PostModel]>
        let requestFailureTrigger: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let postData = PublishRelay<[PostModel]>()
        let requestFailureTrigger = PublishRelay<String>()

        input.dataReload
            .flatMap { _ in
                let posts: PrimitiveSequence<SingleTrait, PostListModel> = NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: "", limit: "", product_id: Constants.productId, hashTag: "24")))    //
                    .catch { error in
                        guard let coordiError = error as? CoordiError else { return Single<PostListModel>.never() } ///
                        requestFailureTrigger.accept(coordiError.errorMessage)
                        return Single<PostListModel>.never()
                    }
                return posts
            }
            .subscribe(onNext: { posts in
                postData.accept(posts.data)
            })
            .disposed(by: disposeBag)
            
        
        input.itemSelected
            .bind(with: self) { owner, postModel in
                let vm = FeedDetailViewModel(postModel: BehaviorRelay(value: postModel))
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(FeedDetailViewController(viewModel: vm), animation: true)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output.init(postData: postData.asDriver(onErrorJustReturn: []),
                           requestFailureTrigger: requestFailureTrigger.asDriver(onErrorJustReturn: ""))
    }
}
