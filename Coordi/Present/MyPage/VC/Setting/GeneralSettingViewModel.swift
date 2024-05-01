//
//  GeneralSettingViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class GeneralSettingViewModel: ViewModelType {
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
    }
    
    func transform(input: Input) -> Output {
        let profileModel = PublishRelay<ProfileModel>()
        
        input.viewDidLoadTrigger
            .flatMap { _ in
                NetworkManager.request(api: .fetchMyProfile)
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<ProfileModel>.never()}
                        //
                        return Single<ProfileModel>.never()
                    }
            }
            .bind(with: self) { owner, profile in
                profileModel.accept(profile)
            }
            .disposed(by: disposeBag)
                
        input.withdrawAlertOKTap
            .flatMap { _ in
                NetworkManager.request(api: .withdraw)
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<WithdrawModel>.never()}
                        //
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
                           withdrawTap: input.withdrawTap.asDriver(onErrorJustReturn: ()))
    }
}
