//
//  EditNicknameViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EditNicknameViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let currentNickname: Observable<String>
        let userInputNickname: Observable<String>
        let saveButtonTap: Observable<Void>
    }
    
    struct Output {
        let failureTrigger: Driver<Void>
        let successTrigger: Driver<String>
        let nicknameValidation: Driver<Bool>
        let validationText: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let validationText = PublishRelay<String>()
        let nicknameValidation = PublishRelay<Bool>()
        let failureTrigger = PublishRelay<Void>()
        let successTrigger = PublishRelay<String>()

        Observable.combineLatest(input.currentNickname, input.userInputNickname)
            .map { nick in
                let (current, userInput) = nick
                if current == userInput {
                    return "현재 닉네임과 같아요"
                } else if userInput.count < 2 {
                    return "2자 이상으로 입력해주세요"
                } else {
                    return ""
                }
            }
            .subscribe { text in
                validationText.accept(text)
                if text.isEmpty {
                    nicknameValidation.accept(true)
                } else {
                    nicknameValidation.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(input.userInputNickname)
            .map { nick in
                return ProfileNickQuery(nick: nick)
            }
            .flatMap { nick in
                NetworkManager.upload(api: .editProfileNick(query: nick))
                    .catch { _ in
                        failureTrigger.accept(())
                        return Single<ProfileModel>.never()
                    }
            }
            .subscribe { profileModel in
                successTrigger.accept(profileModel.element?.nick ?? "")
            }
            .disposed(by: disposeBag)
        
        return Output.init(failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ()),
                           successTrigger: successTrigger.asDriver(onErrorJustReturn: ""),
                           nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                           validationText: validationText.asDriver(onErrorJustReturn: ""))
    }
}
