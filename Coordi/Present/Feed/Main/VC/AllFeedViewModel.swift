//
//  AllFeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class AllFeedViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let viewReloadTrigger: PublishRelay<Void>
        let itemSelected: PublishRelay<PostModel>
        let lastItemIndex: PublishRelay<Int?>
    }
    
    struct Output {
        let postData: Driver<[PostModel]>
        let failureTrigger: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let postData: BehaviorRelay<[PostModel]> = BehaviorRelay(value: [])
        let failureTrigger = PublishRelay<String>()
        var nextCursor = ""

        Observable.combineLatest(input.viewReloadTrigger, temp)
            .withUnretained(self)
            .flatMap { owner, _ in
                print("## 전체 피드 reload!!! \(temp)")
                return NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: "", limit: "10", product_id: Constants.productId, hashTag: String(temp.value))))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<PostListModel>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostListModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostListModel>.never()
                    }
            }
            .subscribe(onNext: { posts in
                nextCursor = posts.next_cursor
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
        
        input.lastItemIndex
            .withLatestFrom(temp)
            .map { String($0) }
            .withUnretained(self)
            .flatMap { owner, temp in
                return owner.callPaginationFeeds(nextCursor: nextCursor, temp: temp) { error in
                    guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return }
                    failureTrigger.accept(errorMessage)
                }
            }
            .subscribe(onNext: { posts in
                nextCursor = posts.next_cursor
                var data = postData.value
                data.append(contentsOf: posts.data)
                postData.accept(data)
            })
            .disposed(by: disposeBag)

        
        return Output.init(postData: postData.asDriver(onErrorJustReturn: []),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""))
    }
    
    private func callPaginationFeeds(nextCursor: String, temp: String, failCompletionHandler: @escaping (CoordiError) -> Void) -> Single<PostListModel> {
        guard nextCursor != "0" else { return Single<PostListModel>.never() }
        let posts: PrimitiveSequence<SingleTrait, PostListModel> = NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: nextCursor, limit: "10", product_id: Constants.productId, hashTag: temp)))
            .catch { error in
                guard let coordiError = error as? CoordiError else { return Single<PostListModel>.never() } ///
                failCompletionHandler(coordiError)
                return Single<PostListModel>.never()
            }
        return posts

    }
}
