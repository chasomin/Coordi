//
//  CommentViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let postId: Observable<String>
        let commentUpload: PublishRelay<String>
    }
    
    struct Output {
        let commentModel: Driver<CommentModel>
        let failureTrigger: Driver<String>
        let refreshTokenFailure: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let comment = PublishRelay<CommentModel>()
        let failureTrigger = PublishRelay<String>()
        let refreshTokenFailure = PublishRelay<Void>()
        
//        input.post
//            .debug("댓글")
//            .bind { postModel in
//                comment.accept(postModel.comments)
//            }
//            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.postId, input.commentUpload)
            .debug("댓글 작성")
            .flatMap { query in
                let (postId, text) = query
                return NetworkManager.request(api: .uploadComment(postId: postId, query: CommentQuery.init(content: text)))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .refreshTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            failureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<CommentModel>.never()
                    }
//                print("⚠️⚠️", text)

//                print("⚠️⚠️", commentModel)
//                return Observable.just(postId)
            }
//            .debug("댓글 작성 서버 요청")
//            .flatMap { postId in
//                return NetworkManager.request(api: .fetchParticularPost(postId: postId))
//                    .catch { error in
//                        let coordiError = error as! CoordiError
//                        switch coordiError {
//                        case .refreshTokenExpired:
//                            refreshTokenFailure.accept(())
//                        default:
//                            failureTrigger.accept(coordiError.errorMessage)
//                        }
//                        return Single<PostModel>.never()
//                    }
//            }
//            .debug("게시글 fetch")
            .subscribe { comments in
                comment.accept(comments)
            }
            .disposed(by: disposeBag)
        
        return Output.init(commentModel: comment.asDriver(onErrorJustReturn: .dummy),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           refreshTokenFailure: refreshTokenFailure.asDriver(onErrorJustReturn: ()))
    }
}
