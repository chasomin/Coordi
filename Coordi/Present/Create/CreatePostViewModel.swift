//
//  CreatePostViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CreatePostViewModel: CoordinatorViewModelType {
    let disposeBag = DisposeBag()
    
    private let postModel: PostModel?
    
    weak var coordinator: Coordinator?
    
    init(postModel: PostModel? = nil) {
        self.postModel = postModel
    }
    
    struct Input {
        let imagePlusButtonTap: Observable<Void>
        let saveButtonTap: PublishRelay<[Data]>
        let imageSelectedButtonTap: Observable<Void>
        let temp: BehaviorRelay<Int>
        let content: BehaviorRelay<String>
        let imageData: Observable<[Data]>
        let textViewDidBeginEditing: PublishRelay<String>
        let textViewDidEndEditing: PublishRelay<String>
        let popTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let editPost: Driver<PostModel?>
        let imagePlusButtonTap: Driver<Void>
        let saveButtonTap: Driver<Void>
        let buttonEnable: Driver<Bool>
        let failureTrigger: Driver<String>
        let textViewDidBeginEditing: Driver<Bool>
        let textViewDidEndEditing: Driver<Bool>
        let textViewPlaceholder: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let saveButtonTap = PublishRelay<Void>()
        let failureTrigger = PublishRelay<String>()
        let textViewPlaceholder = PublishRelay<String>()
        
        input.saveButtonTap
            .map { data in
                return ImageUploadQuery(files: data)
            }
            .withUnretained(self)
            .flatMap { owner, data in
                NetworkManager.upload(api: .uploadImage(query: data))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<ImageUploadModel>.never() }
                        failureTrigger.accept(errorMessage)
                        return Single<ImageUploadModel>.never()
                    }
            }
            .map { imageModel in
                let tempHashTag = (input.temp.value - 2...input.temp.value + 2)
                    .map { String($0) }
                    .map { "#" + $0 }
                    .joined(separator: " ")
                return PostQuery(title: "", content: tempHashTag, content1: input.content.value, content2: "", product_id: Constants.productId, files: imageModel.files)
            }
            .withUnretained(self)
            .flatMap { owner, postQuery in
                return NetworkManager.request(api: .uploadPost(query: postQuery))
                    .catch { error in
                        guard let error = error as? CoordiError, let errorMessage = owner.choiceLoginOrMessage(error: error) else { return Single<PostModel>.never() }
                        failureTrigger.accept(errorMessage)

                        return Single<PostModel>.never()
                    }
            }
            .bind(with: self) { owner, postModel in
                saveButtonTap.accept(())
            }
            .disposed(by: disposeBag)
        
        
        let saveButtonEnable = BehaviorRelay(value: false)
        
        Observable.combineLatest(input.imageData, input.temp, input.content)
            .map { value in
                let (image, _, content) = value
                return !image.isEmpty && !content.isEmpty
            }
            .subscribe { value in
                saveButtonEnable.accept(value)
            }
            .disposed(by: disposeBag)
        
        let textViewDidBeginEditing = input.textViewDidBeginEditing
            .map { _ in
                return true
            }
        let textViewDidEndEditing = input.textViewDidEndEditing
            .map { _ in
                return false
            }

        input.textViewDidBeginEditing
            .map { text in
                if text == Constants.TextViewPlaceholder.createPost.rawValue {
                    return ""
                } else {
                    return text
                }
            }
            .bind { text in
                textViewPlaceholder.accept(text)
            }
            .disposed(by: disposeBag)

            
        
        input.textViewDidEndEditing
            .map { text in
                if text.isEmpty {
                    return Constants.TextViewPlaceholder.createPost.rawValue
                } else {
                    return text
                }
            }
            .bind { text in
                textViewPlaceholder.accept(text)
            }
            .disposed(by: disposeBag)

        
        input.popTrigger
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.coordinator?.pop(animation: true)
            }
            .disposed(by: disposeBag)

        input.imageSelectedButtonTap
            .bind(with: self) { owner, _ in
                owner.coordinator?.dismiss(animation: true)
            }
            .disposed(by: disposeBag)
        

        
        return Output.init(editPost: Observable.just(postModel).asDriver(onErrorJustReturn: .dummy),
                           imagePlusButtonTap: input.imagePlusButtonTap.asDriver(onErrorJustReturn: ()),
                           saveButtonTap: saveButtonTap.asDriver(onErrorJustReturn: ()),
                           buttonEnable: saveButtonEnable.asDriver(onErrorJustReturn: false),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ""),
                           textViewDidBeginEditing: textViewDidBeginEditing.asDriver(onErrorJustReturn: true),
                           textViewDidEndEditing: textViewDidEndEditing.asDriver(onErrorJustReturn: false),
                           textViewPlaceholder: textViewPlaceholder.asDriver(onErrorJustReturn: ""))
    }
}
