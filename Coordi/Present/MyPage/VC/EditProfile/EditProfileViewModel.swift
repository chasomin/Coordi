//
//  EditProfileViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    private var nick: BehaviorRelay<String>
    private var profileImage: String

    init(nick: BehaviorRelay<String>, profileImage: String) {
        self.nick = nick
        self.profileImage = profileImage
    }
    
    struct Input {
        let viewDidLoadTrigger: PublishRelay<Void>
        let imageTap: Observable<Void>
        let labelTap: Observable<Void>
        let imagePickerCancel: PublishRelay<Void>
        let imagePickerFinishPicking: PublishRelay<Data>
    }
    
    struct Output {
        let viewDidLoadTrigger: Driver<(String,String)>
        let imageTap: Driver<Void>
        let imagePickerFinishPicking: Driver<String>
        let failureTrigger: Driver<Void>
        let changeNick: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let viewDidLoadTrigger = PublishRelay<(String, String)>()
        let imagePickerFinishPicking = PublishRelay<String>()
        let failureTrigger = PublishRelay<Void>()
        let changeNick = PublishRelay<String>()
        
        input.viewDidLoadTrigger
            .withLatestFrom(nick)
            .bind(with: self) { owner, nick in
                viewDidLoadTrigger.accept((nick, owner.profileImage))
            }
            .disposed(by: disposeBag)

        input.imagePickerFinishPicking
            .map { image in
                return ProfileImageQuery(profile: image)
            }
            .flatMap { profileQuery in
                NetworkManager.upload(api: .editProfileImage(query: profileQuery))
                    .catch { error in
                        failureTrigger.accept(())
                        return Single<ProfileModel>.never()
                    }
            }
            .subscribe(with: self) { owner, profileModel in
                imagePickerFinishPicking.accept(profileModel.profileImage)
                owner.coordinator?.dismiss(animation: true)
            }
            .disposed(by: disposeBag)
        
        input.labelTap
            .withLatestFrom(nick)
            .bind(with: self) { owner, nick in
                let vm = EditNicknameViewModel(currentNickname: nick)
                vm.coordinator = owner.coordinator
                vm.changeNickname = { nick in
                    owner.nick.accept(nick)
                }
                let vc = EditNicknameViewController(viewModel: vm)
                owner.coordinator?.push(vc, animation: true)
            }
            .disposed(by: disposeBag)
        
        input.imagePickerCancel
            .bind(with: self) { owner, _ in
                owner.coordinator?.dismiss(animation: true)
            }
            .disposed(by: disposeBag)
        
        nick
            .bind { nick in
                changeNick.accept(nick)
            }
            .disposed(by: disposeBag)

        return Output.init(viewDidLoadTrigger: viewDidLoadTrigger.asDriver(onErrorJustReturn: ("", "")),
                           imageTap: input.imageTap.asDriver(onErrorJustReturn: ()),
                           imagePickerFinishPicking: imagePickerFinishPicking.asDriver(onErrorJustReturn: ""),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ()), 
                           changeNick: changeNick.asDriver(onErrorJustReturn: ""))
    }
}
