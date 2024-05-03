//
//  EditNicknameViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EditNicknameViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    private let currentNickname: String
    var changeNickname: ((String) -> Void)?

    init(currentNickname: String) {
        self.currentNickname = currentNickname
    }
    struct Input {
        let viewDidLoadTrigger: PublishRelay<Void>
        let userInputNickname: Observable<String>
        let saveButtonTap: Observable<Void>
    }
    
    struct Output {
        let viewDidLoadTrigger: Driver<String>
        let failureTrigger: Driver<String>
        let nicknameValidation: Driver<Bool>
        let validationText: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let viewDidLoadTrigger = PublishRelay<String>()
        let validationText = PublishRelay<String>()
        let nicknameValidation = PublishRelay<Bool>()
        let failureTrigger = PublishRelay<String>()
        
        input.viewDidLoadTrigger
            .bind(with: self) { owner, _ in
                viewDidLoadTrigger.accept(owner.currentNickname)
            }
            .disposed(by: disposeBag)
        
        input.userInputNickname
            .withUnretained(self)
            .map { owner, userInputNickname in
                if owner.currentNickname == userInputNickname {
                    return "현재 닉네임과 같아요"
                } else if userInputNickname.count < 2 {
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
            .withUnretained(self)
            .flatMap { owner, nick in
                NetworkManager.upload(api: .editProfileNick(query: nick))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<ProfileModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<ProfileModel>.never()
                    }
            }
            .subscribe(with: self) { owner, profileModel in
                owner.changeNickname?(profileModel.nick) //FIXME: 전 화면 값 전달은 여기서?
                owner.coordinator?.pop(animation: true)
            }
            .disposed(by: disposeBag)
        
        return Output.init(viewDidLoadTrigger: viewDidLoadTrigger.asDriver(onErrorJustReturn: ""),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                           validationText: validationText.asDriver(onErrorJustReturn: ""))
    }
}
