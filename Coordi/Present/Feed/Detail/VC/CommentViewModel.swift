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
    
    private let post: BehaviorRelay<PostModel>
    var changeData: (([CommentModel]) -> Void)?

    init(post: BehaviorRelay<PostModel>) {
        self.post = post
    }
    
    struct Input {
        let commentUpload: PublishRelay<String>
        let commentDelete: PublishRelay<CommentModel>
    }
    
    struct Output {
        let comments: Driver<[CommentModel]>
        let failureTrigger: Driver<String>
        let refreshTokenFailure: Driver<Void>
        let commentDelete: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let failureTrigger = PublishRelay<String>()
        let refreshTokenFailure = PublishRelay<Void>()
        let commentDelete = PublishRelay<Void>()
        let comments: BehaviorRelay<[CommentModel]> = BehaviorRelay(value: [])
        
        input.commentUpload
            .withUnretained(self)
            .flatMap { owner, comment in
                return NetworkManager.request(api: .uploadComment(postId: owner.post.value.post_id, query: CommentQuery.init(content: comment)))
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
            }
            .subscribe(with: self) { owner, value in
                var data = comments.value
                data.insert(value, at: 0)
                comments.accept(data)
                owner.changeData?(data)
            }
            .disposed(by: disposeBag)
        
        
        post.map { $0.comments }
            .debug("댓글")
            .bind { value in
                comments.accept(value)
                print("댓글", value)
            }
            .disposed(by: disposeBag)
        
        
        input.commentDelete
            .withUnretained(self)
            .map { owner, comment in
                let remove = NetworkManager.request(api: .deleteComment(postId: owner.post.value.post_id, commentId: comment.comment_id))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .refreshTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            failureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<Bool>.never()
                    }
                print("댓글 삭제", remove.values, comment)
                return (remove, comment)
            }
            .subscribe(with: self) { owner, value in
                let (_, comment) = value
                var data = comments.value
                guard let index = data.firstIndex(of: comment) else { return }
                data.remove(at: index)
                comments.accept(data)
                owner.changeData?(data)
            }
            .disposed(by: disposeBag)
        
        return Output.init(comments: comments.asDriver(onErrorJustReturn: []),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           refreshTokenFailure: refreshTokenFailure.asDriver(onErrorJustReturn: ()),
                           commentDelete: commentDelete.asDriver(onErrorJustReturn: ()))
    }
}

