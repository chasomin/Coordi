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
        let popGesture: PublishRelay<Void>
        let heartButtonTap: PublishRelay<PostModel>
        let imageDoubleTap: PublishRelay<PostModel>
        let profileTap: PublishRelay<Void>
        let commentButtonTap: PublishRelay<PostModel>
        let postEditAction: PublishRelay<PostModel>
        let postDeleteAction: PublishRelay<String>
    }
    
    struct Output {
        let backButtonTap: Driver<Void>
        let popGesture: Driver<Void>
        let heartButtonTap: Driver<PostModel>
        let imageDoubleTap: Driver<PostModel>
        let requestFailureTrigger: Driver<String>
        let refreshTokenFailure: Driver<Void>
        let profileTap: Driver<Void>
        let commentButtonTap: Driver<PostModel>
//        let postEditAction: Driver<PostModel>
        let postDeleteAction: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let heartButtonTap = PublishRelay<PostModel>()
        let imageDoubleTap = PublishRelay<PostModel>()
        let refreshTokenFailure = PublishRelay<Void>()
        let requestFailureTrigger = PublishRelay<String>()
        let postEditAction = PublishRelay<PostModel>()
        let postDeleteAction = PublishRelay<String>()


        input.heartButtonTap
            .flatMap { postModel in
                let likeStatus = postModel.likes.contains(UserDefaultsManager.userId)
                
                return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: !likeStatus)))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .accessTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            requestFailureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<LikeModel>.never()
                    }
            }
            .withLatestFrom(input.postId)
            .flatMap { postId in
                return NetworkManager.request(api: .fetchParticularPost(postId: postId))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .accessTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            requestFailureTrigger.accept(coordiError.errorMessage)
                        }
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
                        .catch { error in
                            let coordiError = error as! CoordiError
                            switch coordiError {
                            case .accessTokenExpired:
                                refreshTokenFailure.accept(())
                            default:
                                requestFailureTrigger.accept(coordiError.errorMessage)
                            }
                            return Single<LikeModel>.never()
                        }
                } else {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: true)))
                        .catch { error in
                            let coordiError = error as! CoordiError
                            switch coordiError {
                            case .accessTokenExpired:
                                refreshTokenFailure.accept(())
                            default:
                                requestFailureTrigger.accept(coordiError.errorMessage)
                            }
                            return Single<LikeModel>.never()
                        }
                }
            }
            .withLatestFrom(input.postId)
            .flatMap { postId in
                return NetworkManager.request(api: .fetchParticularPost(postId: postId))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .accessTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            requestFailureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<PostModel>.never()
                    }
            }
            .bind{ postModel in
                imageDoubleTap.accept(postModel)
            }
            .disposed(by: disposeBag)
        
        input.postDeleteAction
            .throttle(.seconds(5), scheduler: MainScheduler.instance)
            .flatMap { postId in
                let result = NetworkManager.request(api: .deletePost(postId: postId))
                    .catch { error in
                        return Single<Bool>.never()  //TODO: 삭제 두 번 요청됨
                    }
                print("삭제 Viewmodel", result.values)
                return result
            }
            .subscribe { value in
                postDeleteAction.accept("삭제 되었습니다.")
            }
            .disposed(by: disposeBag)
        
        return Output.init(backButtonTap: input.backButtonTap.asDriver(onErrorJustReturn: ()),
                           popGesture: input.popGesture.asDriver(onErrorJustReturn: ()),
                           heartButtonTap: heartButtonTap.asDriver(onErrorJustReturn: .dummy),
                           imageDoubleTap: imageDoubleTap.asDriver(onErrorJustReturn: .dummy),
                           requestFailureTrigger: requestFailureTrigger.asDriver(onErrorJustReturn: ""),
                           refreshTokenFailure: refreshTokenFailure.asDriver(onErrorJustReturn: ()),
                           profileTap: input.profileTap.asDriver(onErrorJustReturn: ()),
                           commentButtonTap: input.commentButtonTap.asDriver(onErrorJustReturn: .dummy),
//                           postEditAction: <#T##Driver<PostModel>#>,
                           postDeleteAction: postDeleteAction.asDriver(onErrorJustReturn: ""))
    }
}
