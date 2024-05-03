//
//  LogInViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LogInViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    struct Input {
        let emailText: PublishRelay<String>
        let passwordText: PublishRelay<String>
        let logInButtonTap: PublishRelay<Void>
        let moveSignUpButtonTap: PublishRelay<Void>
    }
    
    struct Output {
        let logInButtonStatus: Driver<Bool>
        let failureTrigger: Driver<String>
        let successTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let logInButtonStatus = BehaviorRelay(value: false)
        let failureTrigger = PublishRelay<String>()
        let sucessTrigger = PublishRelay<Void>()

        Observable.combineLatest(input.emailText, input.passwordText)
            .map {
                !$0.0.isEmpty && !$0.1.isEmpty
            }
            .subscribe { valid in
                logInButtonStatus.accept(valid)
            }
            .disposed(by: disposeBag)
        
        let logInQuery = Observable.combineLatest(input.emailText, input.passwordText)
            .map { email, password in
                return LogInQuery(email: email, password: password)
            }
        
        input.logInButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(logInQuery)
            .withUnretained(self)
            .flatMap { owner, logInQuery in
                NetworkManager.request(api: .logIn(query: logInQuery))
                    .catch { error in
                        guard let error = error as? CoordiError else { return Single<LogInModel>.never() }
                        guard let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<LogInModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<LogInModel>.never()
                    }
            }
            .bind(with: self) { owner, loginModel in
                UserDefaultsManager.accessToken = loginModel.accessToken
                UserDefaultsManager.refreshToken = loginModel.refreshToken
                UserDefaultsManager.userId = loginModel.user_id
                sucessTrigger.accept(())
                owner.coordinator?.end()
            }
            .disposed(by: disposeBag)
            

        input.moveSignUpButtonTap
            .bind(with: self) { owner, _ in
                owner.coordinator?.present(SignUpViewController())
            }
            .disposed(by: disposeBag)

        return Output.init(logInButtonStatus: logInButtonStatus.asDriver(onErrorJustReturn: false),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           successTrigger: sucessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
