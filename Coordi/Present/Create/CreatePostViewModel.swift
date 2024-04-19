//
//  CreatePostViewModel.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CreatePostViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let imagePlusButtonTap: Observable<Void>
        let saveButtonTap: PublishRelay<[Data]>
        let imageSelectedButtonTap: Observable<Void>
        let temp: BehaviorRelay<String>
        let content: BehaviorRelay<String>
        let imageData: Observable<[Data]>
        let textViewDidBeginEditing: PublishRelay<Void>
        let textViewDidEndEditing: PublishRelay<Void>
    }
    
    struct Output {
        let imagePlusButtonTap: Driver<Void>
        let saveButtonTap: Driver<Void>
        let imageSelectedButtonTap: Driver<Void>
        let buttonEnable: Driver<Bool>
        let failureTrigger: Driver<Void>
        let textViewDidBeginEditing: Driver<Void>
        let textViewDidEndEditing: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let saveButtonTap = PublishRelay<Void>()
        let failureTrigger = PublishRelay<Void>()

        input.saveButtonTap
            .flatMap { data in
                NetworkManager.upload(api: .uploadImage, images: data)
                    .catch { _ in
                        failureTrigger.accept(())
                        return Single<ImageUploadModel>.never()
                    }
            }
            .map { imageModel in
                return PostQuery(title: "", content: "#\(input.temp.value)", content1: input.content.value, content2: "", product_id: Constants.productId.id.rawValue, files: imageModel.files)
            }
            .flatMap { postQuery in
                return NetworkManager.request(api: .uploadPost(query: postQuery))
                    .catch { error in
                        failureTrigger.accept(())
                        return Single<PostModel>.never()
                    }
            }
            .subscribe { postModel in
                saveButtonTap.accept(())
            }
            .disposed(by: disposeBag)
        
        
        let saveButtonEnable = BehaviorRelay(value: false)
        
        Observable.combineLatest(input.imageData, input.temp, input.content)
            .map { value in
                let (image, temp, content) = value
                return !image.isEmpty && !temp.isEmpty && !content.isEmpty
            }
            .subscribe { value in
                saveButtonEnable.accept(value)
            }
            .disposed(by: disposeBag)

        
        return Output.init(imagePlusButtonTap: input.imagePlusButtonTap.asDriver(onErrorJustReturn: ()),
                           saveButtonTap: saveButtonTap.asDriver(onErrorJustReturn: ()),
                           imageSelectedButtonTap: input.imageSelectedButtonTap.asDriver(onErrorJustReturn: ()),
                           buttonEnable: saveButtonEnable.asDriver(onErrorJustReturn: false),
                           failureTrigger: failureTrigger.asDriver(onErrorJustReturn: ()),
                           textViewDidBeginEditing: input.textViewDidBeginEditing.asDriver(onErrorJustReturn: ()),
                           textViewDidEndEditing: input.textViewDidEndEditing.asDriver(onErrorJustReturn: ()))
    }
}
