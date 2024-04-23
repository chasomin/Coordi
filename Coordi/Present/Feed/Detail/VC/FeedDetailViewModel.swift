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
    }
    
    struct Output {
        let backButtonTap: Driver<Void>
        let commentUploadSuccessTrigger: Driver<CommentModel>
        let commentUploadFailureTrigger: Driver<Void>
        let popGesture: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let commentUploadSuccessTrigger = PublishRelay<CommentModel>()
        let commentUploadFailureTrigger = PublishRelay<Void>()

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
        
        return Output.init(backButtonTap: input.backButtonTap.asDriver(onErrorJustReturn: ()),
                           commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: CommentModel.dummy),
                           commentUploadFailureTrigger: commentUploadFailureTrigger.asDriver(onErrorJustReturn: ()),
                           popGesture: input.popGesture.asDriver(onErrorJustReturn: ()))
    }
}
