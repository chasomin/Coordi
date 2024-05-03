//
//  LikeAllFeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeAllFeedViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let dataReloadTrigger: PublishRelay<Void>
        let itemSelected: PublishRelay<PostModel>
        let lastItemIndex: PublishRelay<Int?>
    }
    
    struct Output {
        let likePosts: Driver<[PostModel]>
        let failureTrigger: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let likePosts: BehaviorRelay<[PostModel]> = BehaviorRelay(value: [])
        var nextCursor = ""
        let failureTrigger = PublishRelay<String>()

        input.dataReloadTrigger
            .withUnretained(self)
            .flatMap { owner, _ in
                let query = FetchPostQuery(next: "", limit: "10", product_id: Constants.productId)
                return NetworkManager.request(api: .fetchLikePost(query: query))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostListModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostListModel>.never()
                    }
            }
            .bind(with: self) { owner, posts in
                nextCursor = posts.next_cursor
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
        
        input.lastItemIndex
            .withUnretained(self)
            .flatMap { owner, _ in
                return owner.callPaginationFeeds(nextCursor: nextCursor) { error in
                    guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return }
                    failureTrigger.accept(errorMessage)
                }
            }
            .subscribe(onNext: { posts in
                nextCursor = posts.next_cursor
                var data = likePosts.value
                data.append(contentsOf: posts.data)
                likePosts.accept(data)
            })
            .disposed(by: disposeBag)
        
        return Output.init(likePosts: likePosts.asDriver(onErrorJustReturn: []), 
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""))
    }
}

extension LikeAllFeedViewModel {
    private func callPaginationFeeds(nextCursor: String, failCompletionHandler: @escaping (CoordiError) -> Void) -> Single<PostListModel> {
        guard nextCursor != "0" else { return Single<PostListModel>.never() }
        let query = FetchPostQuery(next: nextCursor, limit: "10", product_id: Constants.productId)
        return NetworkManager.request(api: .fetchLikePost(query: query))
            .catch { error in
                guard let error = error as? CoordiError else { return Single<PostListModel>.never()}
                failCompletionHandler(error)
                return Single<PostListModel>.never()
            }
    }
}
