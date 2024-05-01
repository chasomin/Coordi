//
//  SearchViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    weak var coordinator: Coordinator?
    
    struct Input {
        let searchText: Observable<String>
        let searchButtonTap: Observable<Void>
        let itemSelected: Observable<PostModel>
    }
    
    struct Output {
        let posts: Driver<[PostModel]>
    }
    
    func transform(input: Input) -> Output {
        let posts = PublishRelay<[PostModel]>()
        
        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText)
            .flatMap { text in
                NetworkManager.request(api: .hashtag(query: FetchPostQuery(next: "", limit: "10", product_id: Constants.productId, hashTag: text)))
                    .catch { error in
                        print(error)
                        return Single<PostListModel>.never()
                    }
            }
            .subscribe { postListModel in
                posts.accept(postListModel.element?.data ?? [])
            }
            .disposed(by: disposeBag)
        
        input.itemSelected
            .bind(with: self) { owner, postModel in
                let vm = FeedDetailViewModel(postModel: BehaviorRelay(value: postModel))
                vm.coordinator = owner.coordinator
                owner.coordinator?.push(FeedDetailViewController(viewModel: vm), animation: true)
            }
            .disposed(by: disposeBag)
        
        return Output.init(posts: posts.asDriver(onErrorJustReturn: []))
    }
}
