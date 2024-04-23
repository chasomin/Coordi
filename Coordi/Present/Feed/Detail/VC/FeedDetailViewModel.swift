//
//  FeedDetailViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FeedDetailViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let postId: Observable<String>
        let backButtonTap: PublishRelay<Void>
        let commentButtonTap: PublishRelay<String>
        let popGesture: PublishRelay<Void>
        let heartButtonTap: PublishRelay<PostModel>
        let imageDoubleTap: PublishRelay<PostModel>
    }
    
    struct Output {
        let backButtonTap: Driver<Void>
        let commentUploadSuccessTrigger: Driver<CommentModel>
        let commentUploadFailureTrigger: Driver<Void>
        let popGesture: Driver<Void>
        let heartButtonTap: Driver<PostModel>
        let heartFailureTrigger: Driver<Void>
        let imageDoubleTap: Driver<PostModel>
    }
    
    func transform(input: Input) -> Output {
        let commentUploadSuccessTrigger = PublishRelay<CommentModel>()
        let commentUploadFailureTrigger = PublishRelay<Void>()
        let heartButtonTap = PublishRelay<PostModel>()
        let imageDoubleTap = PublishRelay<PostModel>()
        let heartFailureTrigger = PublishRelay<Void>()

        Observable.combineLatest(input.postId, input.commentButtonTap)
            .flatMap { value in
                let (postId, comment) = value
                return NetworkManager.request(api: .uploadComment(postId: postId, query: CommentQuery(content: comment)))
                    .catch { _ in
                        commentUploadFailureTrigger.accept(())
                        return Single<CommentModel>.never()
                    }
            }
            .subscribe { commentModel in
                commentUploadSuccessTrigger.accept(commentModel)
            }
            .disposed(by: disposeBag)
        
        input.heartButtonTap
            .flatMap { postModel in
                if postModel.likes.contains(UserDefaultsManager.userId) {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: false)))
                        .catch { _ in
                            heartFailureTrigger.accept(())
                            return Single<LikeModel>.never()
                        }
                } else {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: true)))
                        .catch { _ in
                            heartFailureTrigger.accept(())
                            return Single<LikeModel>.never()
                        }
                }
            }
            .withLatestFrom(input.postId)
            .flatMap { postId in
                return NetworkManager.request(api: .fetchParticularPost(postId: postId))
                    .catch { _ in
                        //
                        return Single<PostModel>.never()
                    }
            }
            .bind{ postModel in
                heartButtonTap.accept(postModel)
            }
            .disposed(by: disposeBag)
        
        
        input.imageDoubleTap
            .flatMap { postModel in
                if postModel.likes.contains(UserDefaultsManager.userId) {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: false)))
                        .catch { _ in
                            heartFailureTrigger.accept(())
                            return Single<LikeModel>.never()
                        }
                } else {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: true)))
                        .catch { _ in
                            heartFailureTrigger.accept(())
                            return Single<LikeModel>.never()
                        }
                }
            }
            .withLatestFrom(input.postId)
            .flatMap { postId in
                return NetworkManager.request(api: .fetchParticularPost(postId: postId))
                    .catch { _ in
                        //
                        return Single<PostModel>.never()
                    }
            }
            .bind{ postModel in
                imageDoubleTap.accept(postModel)
            }
            .disposed(by: disposeBag)

        
        
        return Output.init(backButtonTap: input.backButtonTap.asDriver(onErrorJustReturn: ()),
                           commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: CommentModel.dummy),
                           commentUploadFailureTrigger: commentUploadFailureTrigger.asDriver(onErrorJustReturn: ()),
                           popGesture: input.popGesture.asDriver(onErrorJustReturn: ()),
                           heartButtonTap: heartButtonTap.asDriver(onErrorJustReturn: .dummy),
                           heartFailureTrigger: heartFailureTrigger.asDriver(onErrorJustReturn: ()),
                           imageDoubleTap: imageDoubleTap.asDriver(onErrorJustReturn: .dummy))
    }
}
