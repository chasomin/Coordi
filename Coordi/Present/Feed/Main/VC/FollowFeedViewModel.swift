//
//  FeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FollowFeedViewModel: CoordinatorViewModelType {
    
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    struct Input {
        let dataReload: PublishRelay<Void>
        let itemSelected: PublishRelay<PostModel>
        let lastItemIndex: PublishRelay<Int?>
        let plusButtonTap: PublishRelay<Void>
    }
    
    struct Output {
        let postData: Driver<[PostModel]>
        let requestFailureTrigger: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let postData: BehaviorRelay<[PostModel]> = BehaviorRelay(value: [])
        let failureTrigger = PublishRelay<String>()
        var nextCursor = ""
        let postsFetchSuccess = PublishRelay<PostListModel>()
        let followingFetchSuccess = PublishRelay<[UserModel]>()
        
        Observable.combineLatest(input.dataReload, temp)
            .withUnretained(self)
            .flatMap { owner, value in
                return NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: "", limit: "10", product_id: Constants.productId, hashTag: String(temp.value))))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<PostListModel>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostListModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostListModel>.never()
                    }
            }
            .bind(to: postsFetchSuccess)
            .disposed(by: disposeBag)

        Observable.combineLatest(input.dataReload, temp)
            .withUnretained(self)
            .flatMap { owner, _ in
                let profile = owner.fetchMyProfile { error in
                    guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return }
                    failureTrigger.accept(errorMessage)
                }
                return profile.map { $0.following }
            }
            .bind(to: followingFetchSuccess)
            .disposed(by: disposeBag)
            
        
        Observable.combineLatest(postsFetchSuccess, followingFetchSuccess)
            .map({ value in
                let (posts, following) = value
                nextCursor = posts.next_cursor
                return posts.data.filter { post in
                    let followingId = following.map {
                        return $0.user_id
                    }
                    return followingId.contains(post.creator.user_id)
                }
            })
            .bind(onNext: { posts in
                postData.accept(posts)
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
                owner.callPaginationFeeds(nextCursor: nextCursor, temp: temp) { error in
                    guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return }
                    failureTrigger.accept(errorMessage)
                }
            }
            .bind(with: self, onNext: { owner, posts in
                nextCursor = posts.next_cursor
                var data = postData.value
                data.append(contentsOf: posts.data)
                postData.accept(data)
            })
            .disposed(by: disposeBag)
        
        input.plusButtonTap
            .bind(with: self) { owner, _ in
                let vm = CreatePostViewModel()
                vm.coordinator = owner.coordinator
                let vc = CreatePostViewController(viewModel: vm)
                owner.coordinator?.push(vc, animation: true)
            }
            .disposed(by: disposeBag)
        
        return Output.init(postData: postData.asDriver(onErrorJustReturn: []),
                           requestFailureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""))
    }
}

extension FollowFeedViewModel {
    private func callPaginationFeeds(nextCursor: String, temp: String, failCompletionHandler: @escaping (CoordiError) -> Void) -> Single<PostListModel> {
        guard nextCursor != "0" else { return Single<PostListModel>.never() }
        return NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: nextCursor, limit: "10", product_id: Constants.productId, hashTag: temp)))
            .catch { error in
                let coordiError = error as! CoordiError
                failCompletionHandler(coordiError)
                return Single<PostListModel>.never()
            }
    }
    
    private func fetchMyProfile(failCompletionHandler: @escaping (CoordiError) -> Void) -> Single<ProfileModel> {
        let profile = NetworkManager.request(api: .fetchMyProfile)
            .catch { error in
                guard let error = error as? CoordiError else { return Single<ProfileModel>.never() }
                failCompletionHandler(error)
                return Single<ProfileModel>.never()
            }
        return profile
    }
}
