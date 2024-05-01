//
//  FeedViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FollowFeedViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    struct Input {
        let dataReload: PublishRelay<Void> // 넘길 때 next랑, hashtag 넘기면 되나..?
        let itemSelected: Observable<PostModel>
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
                let posts: PrimitiveSequence<SingleTrait, PostListModel> = NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: "", limit: "", product_id: Constants.productId, hashTag: "20")))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        requestFailureTrigger.accept(coordiError.errorMessage)
                        print("!@!@!@", coordiError.errorMessage)
                        return Single<PostListModel>.never()
                    }
                return posts
            }
            //TODO: 팔로워 게시글만 ..
//            .flatMap { posts in
//                let profile: PrimitiveSequence<SingleTrait, ProfileModel> = NetworkManager.request(api: .fetchMyProfile)
//                    .catch { error in
//                        
//                        return Single<ProfileModel>.never()
//                    }
//                return posts.data.map { post in
//                    profile.map { profile in
//                        profile.following.map {
//                            $0.user_id == post.creator.user_id
//                        }
//                        }
//                }
//                
////                let followPosts: PostListModel = posts.data.map { post in
////                    profile.map { profile in
////                        profile.following.map { $0.user_id == post.creator.user_id}
////                    }
////                }
//                
//
//            }
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
