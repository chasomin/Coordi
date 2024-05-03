//
//  FeedDetailViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FeedDetailViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    var postModel: BehaviorRelay<PostModel>

    weak var coordinator: Coordinator?
    
    init(postModel: BehaviorRelay<PostModel>) {
        self.postModel = postModel
    }
    
    struct Input {
        let backButtonTap: PublishRelay<Void>
        let popGesture: PublishRelay<Void>
        let heartButtonTap: PublishRelay<Void>
        let imageDoubleTap: PublishRelay<Void>
        let profileTap: PublishRelay<Void>
        let commentButtonTap: PublishRelay<Void>
        let postEditAction: PublishRelay<Void>
        let postDeleteAction: PublishRelay<Void>
        let popTrigger: PublishRelay<Void>
        let viewDidLoad: PublishRelay<Void>
    }
    
    struct Output {
        let heartButtonTap: Driver<PostModel>
        let imageDoubleTap: Driver<PostModel>
        let failureTrigger: Driver<String>
//        let postEditAction: Driver<PostModel>
        let postDeleteAction: Driver<String>
        let viewDidLoadTrigger: Driver<PostModel>
        let changeComment: Driver<PostModel>
    }
    
    func transform(input: Input) -> Output {
        let heartButtonTap = PublishRelay<PostModel>()
        let imageDoubleTap = PublishRelay<PostModel>()
        let failureTrigger = PublishRelay<String>()
        let postEditAction = PublishRelay<PostModel>()
        let postDeleteAction = PublishRelay<String>()
        let viewDidLoad = PublishRelay<PostModel>()
        let changeComment = PublishRelay<PostModel>()

        input.viewDidLoad
            .withLatestFrom(postModel)
            .bind { postModel in
                viewDidLoad.accept(postModel)
            }
            .disposed(by: disposeBag)

        input.heartButtonTap
            .withLatestFrom(postModel)
            .withUnretained(self)
            .flatMap { owner, postModel in
                let likeStatus = postModel.likes.contains(UserDefaultsManager.userId)
                
                return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: !likeStatus)))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<LikeModel>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<LikeModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<LikeModel>.never()
                    }
            }
            .withLatestFrom(postModel)
            .withUnretained(self)
            .flatMap { owner, postModel in
                return NetworkManager.request(api: .fetchParticularPost(postId: postModel.post_id))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<PostModel>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostModel>.never()
                    }
            }
            .bind(with: self){ owner, postModel in
                heartButtonTap.accept(postModel)
                owner.postModel.accept(postModel)

            }
            .disposed(by: disposeBag)
        
        
        input.imageDoubleTap
            .withLatestFrom(postModel)
            .withUnretained(self)
            .flatMap { owner, postModel in
                if postModel.likes.contains(UserDefaultsManager.userId) {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: false)))
                        .catch { error in
                            guard let error = error as? CoordiError else { return Single<LikeModel>.never() }
                            guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<LikeModel>.never() }
                            failureTrigger.accept(errorMessage)
                            return Single<LikeModel>.never()
                        }
                } else {
                    return NetworkManager.request(api: .like(postId: postModel.post_id, query: LikeQuery.init(like_status: true)))
                        .catch { error in
                            let coordiError = error as! CoordiError
                            guard let error = error as? CoordiError else { return Single<LikeModel>.never() }
                            guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<LikeModel>.never() }
                            failureTrigger.accept(errorMessage)
                            return Single<LikeModel>.never()
                        }
                }
            }
            .withLatestFrom(postModel)
            .withUnretained(self)
            .flatMap { owner, postModel in
                return NetworkManager.request(api: .fetchParticularPost(postId: postModel.post_id))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<PostModel>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<PostModel>.never()
                    }
            }
            .bind(with: self) { owner, postModel in
                owner.postModel.accept(postModel)
                imageDoubleTap.accept(postModel)
            }
            .disposed(by: disposeBag)
        
        input.postDeleteAction
            .throttle(.seconds(5), scheduler: MainScheduler.instance)
            .withLatestFrom(postModel)
            .withUnretained(self)
            .flatMap { owner, post in
                let result = NetworkManager.request(api: .deletePost(postId: post.post_id))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<Bool>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<Bool>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<Bool>.never()  //TODO: 삭제 두 번 요청됨
                    }
                print("삭제 Viewmodel", result.values)
                return result
            }
            .subscribe { value in
                postDeleteAction.accept("삭제 되었습니다.")
            }
            .disposed(by: disposeBag)
        
        input.backButtonTap
            .bind(with: self) { owner, _ in
                owner.coordinator?.pop(animation: true)
            }
            .disposed(by: disposeBag)
        
        input.popGesture
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.coordinator?.pop(animation: true)
            }
            .disposed(by: disposeBag)
        
        input.profileTap
            .bind(with: self) { owner, _ in
                let vm = MyPageViewModel(userId: owner.postModel.value.creator.user_id)
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(MyPageViewController(viewModel: vm), animation: true)
            }
            .disposed(by: disposeBag)
        
        input.commentButtonTap
            .bind(with: self) { owner, _ in
                let commentViewModel = CommentViewModel(post: owner.postModel)
                commentViewModel.changeData = { comments in
                    var post = owner.postModel.value
                    post.comments = comments
                    owner.postModel.accept(post)
                }
                let vc = CommentViewController(viewModel: commentViewModel)
                vc.sheetPresentationController?.detents = [.medium(), .large()]
                vc.sheetPresentationController?.prefersGrabberVisible = true
                vc.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
                owner.coordinator?.present(vc)
            }
            .disposed(by: disposeBag)
        
        input.popTrigger
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.coordinator?.pop(animation: true)
            }
            .disposed(by: disposeBag)
        
        postModel
            .bind(with: self) { owner, post in
                changeComment.accept(post)
            }
            .disposed(by: disposeBag)
        
        return Output.init(heartButtonTap: heartButtonTap.asDriver(onErrorJustReturn: .dummy),
                           imageDoubleTap: imageDoubleTap.asDriver(onErrorJustReturn: .dummy),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
//                           postEditAction: <#T##Driver<PostModel>#>,
                           postDeleteAction: postDeleteAction.asDriver(onErrorJustReturn: ""),
                           viewDidLoadTrigger: viewDidLoad.asDriver(onErrorJustReturn: .dummy), 
                           changeComment: changeComment.asDriver(onErrorJustReturn: .dummy))
    }
}
