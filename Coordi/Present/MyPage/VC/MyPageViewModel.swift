//
//  MyPageViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let editButtonTap: PublishRelay<Void>
        let barButtonTap: Observable<Void>
        let itemSelected: Observable<PostModel>
    }
    
    struct Output {
        let profile: PublishRelay<ProfileModel>
        let posts: PublishRelay<PostListModel>
        let editButtonTap: PublishRelay<ProfileModel>
        let barButtonTap: Driver<Void>
        let itemSelected: Driver<PostModel>
        let profileFetchFailureTrigger: Driver<Void>
        let postsFetchFailureTrigger: Driver<Void>
        let itemFetchFailureTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let userId = UserDefaultsManager.userId
        let postQuery = Observable.just(FetchPostQuery(next: "", limit: "7", product_id: ""))//test

        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<PostListModel>()
        let editButtonTap = PublishRelay<ProfileModel>()
        let itemSelected = PublishRelay<PostModel>()

        let profileFetchFailureTrigger = PublishRelay<Void>()
        let postsFetchFailureTrigger = PublishRelay<Void>()
        let itemFetchFailureTrigger = PublishRelay<Void>()

        input.viewDidLoad
            .withLatestFrom(postQuery)
            .flatMap { postQuery in
                NetworkManager.request(api: .fetchPostByUser(userId: userId, query: postQuery))
                    .catch { _ in
                        postsFetchFailureTrigger.accept(())
                        return Single<PostListModel>.never()
                    }
            }
            .flatMap { postListModel in
                let profileModel = NetworkManager.request(api: .fetchMyProfile)
                    .catch { _ in
                        profileFetchFailureTrigger.accept(())
                        return Single<ProfileModel>.never()
                    }
                let postListModel = Observable.just(postListModel).asSingle()
                
                return Single.zip(postListModel, profileModel)
            }
            .subscribe(with: self) { owner, response in
                let (post, profile) = response
                myProfile.accept(profile)
                myPosts.accept(post)
            }
            .disposed(by: disposeBag)
                    
        input.editButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(myProfile)
            .subscribe { profileModel in
                editButtonTap.accept(profileModel)
            }
            .disposed(by: disposeBag)

        return Output.init(profile: myProfile,
                           posts: myPosts,
                           editButtonTap: editButtonTap,
                           barButtonTap: input.barButtonTap.throttle(.seconds(2), scheduler: MainScheduler.instance).asDriver(onErrorJustReturn: ()),
                           itemSelected:  input.itemSelected.asDriver(onErrorJustReturn: PostModel.dummy),
                           profileFetchFailureTrigger: profileFetchFailureTrigger.asDriver(onErrorJustReturn: ()),
                           postsFetchFailureTrigger: postsFetchFailureTrigger.asDriver(onErrorJustReturn: ()),
                           itemFetchFailureTrigger: itemFetchFailureTrigger.asDriver(onErrorJustReturn: ()))
    }
}
