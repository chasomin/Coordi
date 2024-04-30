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
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    struct Input {
        let dataReload: PublishRelay<Void>
        let editButtonTap: Observable<Void>
        let followButtonTap: Observable<Void>
        let plusButtonTap: Observable<Void>
        let itemSelected: Observable<PostModel>
        let settingButtonTap: Observable<Void>
    }
    
    struct Output {
        let profile: PublishRelay<ProfileModel>
        let posts: PublishRelay<PostListModel>
        let editButtonTap: PublishRelay<ProfileModel>
        let plusButtonTap: Driver<Void>
        let itemSelected: Driver<PostModel>
        let failureTrigger: Driver<String>
        let refreshTokenFailure: Driver<Void>
        let isMyFeed: Driver<(Bool, ProfileModel)>
        let followValue: Driver<FollowModel>
        let settingButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<PostListModel>()
        let editButtonTap = PublishRelay<ProfileModel>()
        let failureTrigger = PublishRelay<String>()
        let refreshTokenFailure = PublishRelay<Void>()
        let isMyFeed = PublishRelay<(Bool, ProfileModel)>()
        let followValue = PublishRelay<FollowModel>()


        input.dataReload
            .withUnretained(self)
            .flatMap { owner, _ in
                return NetworkManager.request(api: .fetchUserProfile(userId: owner.userId))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .refreshTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            failureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<ProfileModel>.never()
                    }
            }
            .flatMap { profile in
               let posts = NetworkManager.request(api: .fetchPostByUser(userId: profile.user_id, query: FetchPostQuery.init(next: "", limit: "", product_id: Constants.productId)))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .refreshTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            failureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<PostListModel>.never()
                    }
                let userProfile = Observable.just(profile).asSingle()
                return Single.zip(userProfile, posts)
            
            }
            .subscribe { response in
                let (profile, posts) = response
                myProfile.accept(profile)
                myPosts.accept(posts)
                if profile.user_id == UserDefaultsManager.userId {
                    isMyFeed.accept((true, profile))
                } else {
                    isMyFeed.accept((false, profile))
                }
            }
            .disposed(by: disposeBag)
                    
        input.editButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(myProfile)
            .subscribe { profileModel in
                editButtonTap.accept(profileModel)
            }
            .disposed(by: disposeBag)

        input.followButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMap { owner, _ in
                NetworkManager.request(api: .fetchUserProfile(userId: owner.userId))
                    .catch { error in
                        let coordiError = error as! CoordiError
                        switch coordiError {
                        case .refreshTokenExpired:
                            refreshTokenFailure.accept(())
                        default:
                            failureTrigger.accept(coordiError.errorMessage)
                        }
                        return Single<ProfileModel>.never()
                    }
            }
            .flatMap { profile in
                if profile.followers.map ({ $0.user_id == UserDefaultsManager.userId }).isEmpty {
                    NetworkManager.request(api: .follow(userId: profile.user_id))
                        .catch { error in
                            let coordiError = error as! CoordiError
                            switch coordiError {
                            case .refreshTokenExpired:
                                refreshTokenFailure.accept(())
                            default:
                                failureTrigger.accept(coordiError.errorMessage)
                            }
                            return Single<FollowModel>.never()
                        }
                } else {
                    NetworkManager.request(api: .deleteFollow(userId: profile.user_id))
                        .catch { error in
                            let coordiError = error as! CoordiError
                            switch coordiError {
                            case .refreshTokenExpired:
                                refreshTokenFailure.accept(())
                            default:
                                failureTrigger.accept(coordiError.errorMessage)
                            }
                            return Single<FollowModel>.never()
                        }
                }
            }
            .subscribe { follow in
                followValue.accept(follow)
            }
            .disposed(by: disposeBag)
        
        return Output.init(profile: myProfile,
                           posts: myPosts,
                           editButtonTap: editButtonTap,
                           plusButtonTap: input.plusButtonTap.throttle(.seconds(2), scheduler: MainScheduler.instance).asDriver(onErrorJustReturn: ()),
                           itemSelected:  input.itemSelected.asDriver(onErrorJustReturn: PostModel.dummy),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""), 
                           refreshTokenFailure: refreshTokenFailure.asDriver(onErrorJustReturn: ()),
                           isMyFeed: isMyFeed.asDriver(onErrorJustReturn: (true, .dummy)),
                           followValue: followValue.asDriver(onErrorJustReturn: .init(nick: "", opponent_nick: "", following_status: false)),
                           settingButtonTap: input.settingButtonTap.throttle(.seconds(2), scheduler: MainScheduler.instance).asDriver(onErrorJustReturn: ()))
    }
}
