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
    }
    
    struct Output {
        let profile: PublishRelay<ProfileModel>
        let posts: PublishRelay<PostListModel>
        let editButtonTap: PublishRelay<ProfileModel>

    }
    
    func transform(input: Input) -> Output {
        let userId = UserDefaultsManager.userId
        let postQuery = Observable.just(FetchPostQuery(next: "", limit: "7", product_id: "", hashTag: nil))//test

        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<PostListModel>()
        let editButtonTap = PublishRelay<ProfileModel>()
        
        input.viewDidLoad
            .withLatestFrom(postQuery)
            .flatMap { postQuery in
                NetworkManager.request(api: .fetchPostByUser(userId: userId, query: postQuery))
                    .catch { _ in
                        return Single<PostListModel>.never()
                    }
            }
            .flatMap { postListModel in
                let profileModel = NetworkManager.request(api: .fetchMyProfile)
                    .catch { _ in
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
            .withLatestFrom(myProfile)
            .subscribe { profileModel in
                editButtonTap.accept(profileModel)
            }
            .disposed(by: disposeBag)
        
//        myProfile
//            .flatMap({ profileModel in
//                NetworkManager.request(api: .fetchImage(query: profileModel.profileImage))
//                    .catch { _ in
//                        return Single<Data>.never()
//                    }
//            })
//            .bind { data in
//                print("!!",data)
//            }
//            .disposed(by: disposeBag)
            
        return Output.init(profile: myProfile, posts: myPosts, editButtonTap: editButtonTap)
    }
}
