//
//  SettingViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/30/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let selectedItem: PublishRelay<Setting>
    }
    
    struct Output {
        let settingList: Driver<[Setting]>
    }
    
    func transform(input: Input) -> Output {
        let settingList = PublishRelay<[Setting]>()
        let setting = input.viewDidLoad
            .map { _ in
                return Setting.allCases
            }
        let settingTap = PublishRelay<Void>()
        
        setting
            .debug("여기")
            .bind(onNext: { value in
                settingList.accept(value)
            })
            .disposed(by: disposeBag)
        
        input.selectedItem
            .bind(with: self, onNext: { owner, value in
                if value == .setting {
                    settingTap.accept(())
                    owner.coordinator?.dismiss(animation: true)
                    let vm = GeneralSettingViewModel()
                    vm.coordinator = owner.coordinator
                    owner.coordinator?.push(GeneralSettingViewController(viewModel: vm), animation: true)
                    
                } else if value == .like {
                    owner.coordinator?.dismiss(animation: true)
                    let vm = LikeAllFeedViewModel()
                    vm.coordinator = owner.coordinator
                    owner.coordinator?.push(LikeAllFeedViewController(viewModel: vm), animation: true)
                } else {
                    UserDefaultsManager.accessToken = ""
                    UserDefaultsManager.refreshToken = ""
                    UserDefaultsManager.userId = ""
                    print("여기", UserDefaultsManager.accessToken, UserDefaultsManager.refreshToken, UserDefaultsManager.userId)
                    
                    owner.coordinator?.end()
                }
            })
            .disposed(by: disposeBag)
        
        return Output.init(settingList: settingList.asDriver(onErrorJustReturn: []))
    }
    
    enum Setting: CaseIterable {
        case setting
        case like
        case logOut
        var title: String {
            switch self {
            case .setting:
                "일반 설정"
            case .like:
                "좋아요한 게시글"
            case .logOut:
                "로그아웃"
            }
        }
        
        var icon: String {
            switch self {
            case .setting:
                "gearshape"
            case .like:
                "heart"
            case .logOut:
                "door.left.hand.open"
            }
        }
        
    
    }

}
