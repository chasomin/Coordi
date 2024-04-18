//
//  LogInViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LogInViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let logInButtonTap: Observable<Void>
        let moveSignUpButtonTap: Observable<Void>
    }
    
    struct Output {
        let logInButtonStatus: Driver<Bool>
        let successTrigger: Driver<Void>
        let failureTrigger: Driver<Void>
        let moveSignUp: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let logInButtonStatus = BehaviorRelay(value: false)
        let successTrigger = PublishRelay<Void>()
        let failureTrigger = PublishRelay<Void>()
        
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
            .flatMap { logInQuery in
                NetworkManager.request(api: .logIn(query: logInQuery))
                    .catch { _ in
                        failureTrigger.accept(())
                        return Single<LogInModel>.never()
                    }
            }
            .subscribe { loginModel in
                successTrigger.accept(())
                UserDefaultsManager.accessToken = loginModel.element?.accessToken ?? ""
                UserDefaultsManager.refreshToken = loginModel.element?.refreshToken ?? ""
                UserDefaultsManager.userId = loginModel.element?.user_id ?? ""
            }
            .disposed(by: disposeBag)

        
        return Output.init(logInButtonStatus: logInButtonStatus.asDriver(onErrorJustReturn: false), successTrigger: successTrigger.asDriver(onErrorJustReturn: ()), failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ()), moveSignUp: input.moveSignUpButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
