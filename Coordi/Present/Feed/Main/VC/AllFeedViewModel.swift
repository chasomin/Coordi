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
    
    struct Input {
        let dataReload: PublishRelay<Void>
        let itemSelected: PublishRelay<PostModel>
    }
    
    struct Output {
        let postData: Driver<[PostModel]>
        let requestFailureTrigger: Driver<String>
        let itemSelected: Driver<PostModel>
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
            
        

        
        return Output.init(postData: postData.asDriver(onErrorJustReturn: []),
                           requestFailureTrigger: requestFailureTrigger.asDriver(onErrorJustReturn: ""),
                           itemSelected: input.itemSelected.asDriver(onErrorJustReturn: .dummy))
    }
}
