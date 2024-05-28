//
//  ChatDetailViewModel.swift
//  Coordi
//
//  Created by 차소민 on 5/27/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatDetailViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        /// 1. 화면 진입 시 -> DB에서 마지막 Date 받아오기
        ///             date로 서버 요청
        ///             서버 리턴 값 DB에 저장
        ///             DB 데이터로 화면 그리기
        ///             소켓 연결
        /// 2. 전송 버튼 클릭 -> DB 저장
        ///              화면 그리기 ==> DB Output 동일하게
        /// 소켓으로 오는 데이터도 DB 저장!
        /// 3. Deinit -> 소켓 해제
        ///
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return .init()
    }
}
