//
//  SignUpViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let nicknameText: Observable<String>
        let signUpButtonTap: Observable<Void>
        let dismissButtonTap: Observable<Void>
    }
    
    struct Output {
        let emailValid: Driver<Bool>
        let passwordValid: Driver<Bool>
        let nicknameValid: Driver<Bool>
        let allValid: Driver<Bool>
        let successTrigger: Driver<Void>
        let failureTrigger: Driver<Void>
        let dismissButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let emailValid = PublishRelay<Bool>()
        let passwordValid = PublishRelay<Bool>()
        let nicknameValid = PublishRelay<Bool>()
        let allValid = BehaviorRelay(value: false)
        let successTrigger = PublishRelay<Void>()
        let failureTrigger = PublishRelay<Void>()

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
        
        input.emailText
            .map {
                let vaild = $0.range(of: emailRegex, options: .regularExpression) != nil
                return vaild
            }
            .bind(to: emailValid)
            .disposed(by: disposeBag)
        
        input.passwordText
            .map {
                let valid = $0.range(of: passwordRegex, options: .regularExpression) != nil
                return valid
            }
            .bind(to: passwordValid)
            .disposed(by: disposeBag)
        
        input.nicknameText
            .map {
                $0.count > 1
            }
            .bind(to: nicknameValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailValid, passwordValid, nicknameValid)
            .map {
                $0.0 == true && $0.1 == true && $0.2 == true
            }
            .subscribe { valid in
                allValid.accept(valid)
            }
            .disposed(by: disposeBag)
        
        let signUpQuery = Observable.combineLatest(input.emailText, input.passwordText, input.nicknameText)
            .map { email, password, nick in
                return SignUpQuery(email: email, password: password, nick: nick)
            }
        
        input.signUpButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(signUpQuery)
            .flatMap { signUpQuery in
                return NetworkManager.request(api: .signUp(query: signUpQuery))
                    .catch { error in
                        failureTrigger.accept(())
                        return Single<SignUpModel>.never()
                    }
            }
            .subscribe { signUpModel in
                successTrigger.accept(())
            }
            .disposed(by: disposeBag)

        return Output.init(emailValid: emailValid.asDriver(onErrorJustReturn: false), passwordValid: passwordValid.asDriver(onErrorJustReturn: false), nicknameValid: nicknameValid.asDriver(onErrorJustReturn: false), allValid: allValid.asDriver(onErrorJustReturn: false), successTrigger: successTrigger.asDriver(onErrorJustReturn: ()), failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ()), dismissButtonTap: input.dismissButtonTap.asDriver(onErrorJustReturn: ()))
    }

}
