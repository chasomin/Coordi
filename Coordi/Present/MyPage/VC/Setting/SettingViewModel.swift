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
        
        setting
            .debug("여기")
            .bind(onNext: { value in
                settingList.accept(value)
            })
            .disposed(by: disposeBag)
        
        return Output.init(settingList: settingList.asDriver(onErrorJustReturn: []))
    }
    
    enum Setting: CaseIterable {
        case setting
        case like
        
        var title: String {
            switch self {
            case .setting:
                "설정"
            case .like:
                "좋아요한 게시글"
            }
        }
        
        var icon: String {
            switch self {
            case .setting:
                "gearshape"
            case .like:
                "heart"
            }
        }
        
    
    }

}
