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
    
    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let selectedItem: PublishRelay<Setting>
    }
    
    struct Output {
        let settingList: Driver<[Setting]>
        let settingTap: Driver<Void>
        let likeTap: Driver<Void>
        let logOutTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let settingList = PublishRelay<[Setting]>()
        let setting = input.viewDidLoad
            .map { _ in
                return Setting.allCases
            }
        let settingTap = PublishRelay<Void>()
        let likeTap = PublishRelay<Void>()
        let logOutTap = PublishRelay<Void>()
        
        setting
            .debug("여기")
            .bind(onNext: { value in
                settingList.accept(value)
            })
            .disposed(by: disposeBag)
        
        input.selectedItem
            .bind(onNext: { value in
                if value == .setting {          ///
                    settingTap.accept(())
                } else if value == .like {
                    likeTap.accept(())
                } else {
                    UserDefaultsManager.accessToken = ""
                    UserDefaultsManager.refreshToken = ""
                    UserDefaultsManager.userId = ""
                    print("여기", UserDefaultsManager.accessToken, UserDefaultsManager.refreshToken, UserDefaultsManager.userId)
                    logOutTap.accept(())
                }
            })
            .disposed(by: disposeBag)
        


        
        return Output.init(settingList: settingList.asDriver(onErrorJustReturn: []),
                           settingTap: settingTap.asDriver(onErrorJustReturn: ()),
                           likeTap: likeTap.asDriver(onErrorJustReturn: ()),
                           logOutTap: logOutTap.asDriver(onErrorJustReturn: ()))
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
