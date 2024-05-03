//
//  SearchViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let searchText: Observable<String>
        let searchButtonTap: Observable<Void>
        let itemSelected: Observable<PostModel>
        let lastItemIndex: PublishRelay<Int?>
    }
    
    struct Output {
        let posts: Driver<[PostModel]>
        let failureTrigger: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let posts: BehaviorRelay<[PostModel]> = BehaviorRelay(value: [])
        var nextCursor = ""
        let failureTrigger = PublishRelay<String>()

        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText)
            .withUnretained(self)
            .flatMap { owner, text in
                return NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: "", limit: "10", product_id: Constants.productId, hashTag: text)))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostListModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostListModel>.never()
                    }
            }
            .bind { postListModel in
                nextCursor = postListModel.next_cursor
                posts.accept(postListModel.data)
            }
            .disposed(by: disposeBag)
        
        input.itemSelected
            .bind(with: self) { owner, postModel in
                let vm = FeedDetailViewModel(postModel: BehaviorRelay(value: postModel))
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(FeedDetailViewController(viewModel: vm), animation: true)
            }
            .disposed(by: disposeBag)
        
        input.lastItemIndex
            .withLatestFrom(input.searchText)
            .withUnretained(self)
            .flatMap { owner, text in
                return owner.callPaginationFeeds(nextCursor: nextCursor, hashTag: text) { error in
                    guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return }
                    failureTrigger.accept(errorMessage)
                }
            }
            .subscribe(onNext: { post in
                nextCursor = post.next_cursor
                var data = posts.value
                data.append(contentsOf: post.data)
                posts.accept(data)
            })
            .disposed(by: disposeBag)

        
        return Output.init(posts: posts.asDriver(onErrorJustReturn: []),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""))
        
    }
    
}

extension SearchViewModel {
    private func callPaginationFeeds(nextCursor: String, hashTag: String, failCompletionHandler: @escaping (CoordiError) -> Void) -> Single<PostListModel> {
        guard nextCursor != "0" else { return Single<PostListModel>.never() }
        return NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: nextCursor, limit: "10", product_id: Constants.productId, hashTag: hashTag)))
            .catch { error in
                guard let error = error as? CoordiError else { return Single<PostListModel>.never() }
                failCompletionHandler(error)
                return Single<PostListModel>.never()
            }
    }
}
