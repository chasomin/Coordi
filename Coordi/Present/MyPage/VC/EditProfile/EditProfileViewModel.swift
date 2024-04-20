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
    
    struct Input {
        let imageTap: Observable<Void>
        let labelTap: Observable<Void>
        let imagePickerCancel: PublishRelay<Void>
        let imagePickerFinishPicking: PublishRelay<Data>
    }
    
    struct Output {
        let imageTap: Driver<Void>
        let labelTap: Driver<Void>
        let imagePickerCancel: Driver<Void>
        let imagePickerFinishPicking: Driver<String>
        let failureTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let imagePickerFinishPicking = PublishRelay<String>()
        let failureTrigger = PublishRelay<Void>()

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
            .subscribe { profileModel in
                imagePickerFinishPicking.accept(profileModel.element?.profileImage ?? "")
            }
            .disposed(by: disposeBag)

        return Output.init(imageTap: input.imageTap.asDriver(onErrorJustReturn: ()),
                           labelTap: input.labelTap.asDriver(onErrorJustReturn: ()),
                           imagePickerCancel: input.imagePickerCancel.asDriver(onErrorJustReturn: ()),
                           imagePickerFinishPicking: imagePickerFinishPicking.asDriver(onErrorJustReturn: ""),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ()))
    }
}
