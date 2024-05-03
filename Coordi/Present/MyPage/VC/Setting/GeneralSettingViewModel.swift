//
//  GeneralSettingViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class GeneralSettingViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let viewDidLoadTrigger: PublishRelay<Void>
        let withdrawTap: PublishRelay<Void>
        let withdrawAlertOKTap: PublishRelay<Void>
    }
    
    struct Output {
        let profile: Driver<ProfileModel>
        let withdrawTap: Driver<Void>
        let failureTrigger: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let profileModel = PublishRelay<ProfileModel>()
        let failureTrigger = PublishRelay<String>()
        
        input.viewDidLoadTrigger
            .withUnretained(self)
            .flatMap { owner, _ in
                NetworkManager.request(api: .fetchMyProfile)
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<ProfileModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<ProfileModel>.never()
                    }
            }
            .bind(with: self) { owner, profile in
                profileModel.accept(profile)
            }
            .disposed(by: disposeBag)
                
        input.withdrawAlertOKTap
            .withUnretained(self)
            .flatMap { owner, _ in
                NetworkManager.request(api: .withdraw)
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<WithdrawModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<WithdrawModel>.never()
                    }
            }
            .bind(with: self) { owner, _ in
                UserDefaultsManager.accessToken = ""
                UserDefaultsManager.refreshToken = ""
                UserDefaultsManager.userId = ""
                owner.coordinator?.end()
            }
            .disposed(by: disposeBag)
        
        return Output.init(profile: profileModel.asDriver(onErrorJustReturn: .dummy),
                           withdrawTap: input.withdrawTap.asDriver(onErrorJustReturn: ()),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""))
    }
}
