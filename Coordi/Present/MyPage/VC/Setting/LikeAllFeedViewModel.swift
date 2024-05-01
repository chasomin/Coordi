//
//  LikeAllFeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeAllFeedViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let dataReloadTrigger: PublishRelay<Void>
        let itemSelected: PublishRelay<PostModel>
    }
    
    struct Output {
        let likePosts: Driver<[PostModel]>
    }
    
    func transform(input: Input) -> Output {
        let likePosts = PublishRelay<[PostModel]>()
        
        input.dataReloadTrigger
            .flatMap { _ in
                let query = FetchPostQuery(next: "", limit: "10", product_id: Constants.productId)
                return NetworkManager.request(api: .fetchLikePost(query: query))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<PostListModel>.never()}
                        //
                        return Single<PostListModel>.never()
                    }
            }
            .bind(with: self) { owner, posts in
                likePosts.accept(posts.data)
            }
            .disposed(by: disposeBag)
        
        input.itemSelected
            .bind(with: self) { owner, postModel in
                let vm = FeedDetailViewModel(postModel: BehaviorRelay(value: postModel))
                vm.coordinator = owner.coordinator
                let vc = FeedDetailViewController(viewModel: vm)
                owner.coordinator?.push(vc, animation: true)
            }
            .disposed(by: disposeBag)
        
        return Output.init(likePosts: likePosts.asDriver(onErrorJustReturn: []))
    }
}
