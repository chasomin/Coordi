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
    weak var coordinator: Coordinator?
    
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
        let failureTrigger: Driver<String>
        let refreshTokenFailure: Driver<Void>
        let isMyFeed: Driver<(Bool, ProfileModel)>
        let followValue: Driver<FollowModel>
    }
    
    func transform(input: Input) -> Output {
        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<PostListModel>()
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
            .bind(with: self, onNext: { owner, profile in
                let vm = EditProfileViewModel(nick: BehaviorRelay(value: profile.nick), profileImage: profile.profileImage)
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(EditProfileViewController(viewModel: vm), animation: true)
            })
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
        
        input.settingButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let vm = SettingViewModel()
                vm.coordinator = owner.coordinator
                let vc = SettingViewController(viewModel: vm)
                vc.sheetPresentationController?.detents = [.custom(resolver: { _ in 200 })]
                vc.sheetPresentationController?.prefersGrabberVisible = true
                owner.coordinator?.present(vc)
            }
            .disposed(by: disposeBag)
        
        input.itemSelected
            .bind(with: self) { owner, postModel in
                let vm = FeedDetailViewModel(postModel: BehaviorRelay(value: postModel))
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(FeedDetailViewController(viewModel: vm), animation: true)
            }
            .disposed(by: disposeBag)
        
        input.plusButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let vm = CreatePostViewModel()
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(CreatePostViewController(viewModel: vm), animation: true)
            }
            .disposed(by: disposeBag)
        
        return Output.init(profile: myProfile,
                           posts: myPosts,
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           refreshTokenFailure: refreshTokenFailure.asDriver(onErrorJustReturn: ()),
                           isMyFeed: isMyFeed.asDriver(onErrorJustReturn: (true, .dummy)),
                           followValue: followValue.asDriver(onErrorJustReturn: .init(nick: "", opponent_nick: "", following_status: false)))
    }
}
