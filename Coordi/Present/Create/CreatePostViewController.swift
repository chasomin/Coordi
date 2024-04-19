//
//  CreatePostViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PhotosUI

final class CreatePostViewController: BaseViewController {
    
    private let viewModel = CreatePostViewModel()
    private var imageContainer: [UIImage] = [] {
        didSet {
            images.accept(imageContainer)
        }
    }
    private var images: BehaviorRelay<[UIImage]> = .init(value: [])
    private var imageSelectedButtonTap = PublishRelay<Void>()
    private var textViewDidBeginEditing = PublishRelay<Void>()
    private var textViewDidEndEditing = PublishRelay<Void>()
    
    private let imagePlusButton = UIButton()
    private lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let tempTitleLabel = UILabel()
    private let tempTextField = LineTextField()
    private let tempLabel = UILabel()
    private let contentTextView = UITextView()
    private let saveButton = PointButton(text: "등록하기")
    
    private var dataSource: UICollectionViewDiffableDataSource<String, UIImage>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeCellRegistration()
        
        navigationItem.title = "코디 올리기"
        contentTextView.delegate = self
    }
    
    override func bind() {
        let imageData = images.map { $0.compactMap { image in
            image.compressedJPEGData
        }}
        
        let data = PublishRelay<[Data]>()
        
        saveButton.rx.tap
            .withLatestFrom(imageData)
            .bind(with: self) { owner, value in
                owner.saveButton.configuration?.showsActivityIndicator = true
                data.accept(value)
            }
            .disposed(by: disposeBag)
        
        let input = CreatePostViewModel.Input(imagePlusButtonTap: imagePlusButton.rx.tap.asObservable(),
                                              saveButtonTap: data,
                                              imageSelectedButtonTap: imageSelectedButtonTap.asObservable(),
                                              temp: .init(value: ""),
                                              content: .init(value: ""),
                                              imageData: imageData,
                                              textViewDidBeginEditing: textViewDidBeginEditing,
                                              textViewDidEndEditing: textViewDidEndEditing)
        let output = viewModel.transform(input: input)
        
        tempTextField.textField.rx.text.orEmpty
            .bind(to: input.temp)
            .disposed(by: disposeBag)
        
        contentTextView.rx.text.orEmpty
            .bind(to: input.content)
            .disposed(by: disposeBag)
            

        output.imagePlusButtonTap
            .drive(with: self) { owner, _ in
                owner.imageContainer.removeAll()
                
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 5
                configuration.filter = .any(of: [.images, .livePhotos, .videos])
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                owner.present(picker, animated:  true)
            }
            .disposed(by: disposeBag)
        
        output.imageSelectedButtonTap
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.saveButtonTap
            .drive(with: self) { owner, _ in
                owner.showDoneToast()
                owner.saveButton.configuration?.showsActivityIndicator = false
                Observable.just(())
                    .delay(.seconds(1), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { _ in
                        owner.navigationController?.popViewController(animated: true)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.buttonEnable
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.failureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast()
            }
            .disposed(by: disposeBag)
        
        output.textViewDidBeginEditing
            .drive(with: self) { owner, _ in
                owner.imagePlusButton.isHidden = true
                owner.imageCollectionView.isHidden = true
                owner.tempTitleLabel.isHidden = true
                owner.tempTextField.isHidden = true
                owner.tempLabel.isHidden = true
            }
            .disposed(by: disposeBag)
        
        output.textViewDidEndEditing
            .drive(with: self) { owner, _ in
                owner.imagePlusButton.isHidden = false
                owner.imageCollectionView.isHidden = false
                owner.tempTitleLabel.isHidden = false
                owner.tempTextField.isHidden = false
                owner.tempLabel.isHidden = false
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(imagePlusButton)
        view.addSubview(imageCollectionView)
        view.addSubview(tempTitleLabel)
        view.addSubview(tempTextField)
        view.addSubview(tempLabel)
        view.addSubview(contentTextView)
        view.addSubview(saveButton)
    }
    
    override func configureLayout() {
        imagePlusButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.size.equalTo(80)
        }
        
        imageCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(imagePlusButton.snp.trailing).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(imagePlusButton)
            make.top.equalTo(imagePlusButton)
        }
        
        tempTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(imagePlusButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        tempTextField.snp.makeConstraints { make in
            make.top.equalTo(tempTitleLabel.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(28)
            make.width.equalTo(50)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(tempTitleLabel.snp.bottom)
            make.leading.equalTo(tempTextField.snp.trailing).offset(5)
            make.height.equalTo(tempTextField)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(tempTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(15)
            make.height.equalTo(50)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
    }
    
    override func configureView() {
        var config = UIButton.Configuration.tinted()
        config.image = UIImage(systemName: "plus")
        config.imagePlacement = .top
        config.baseForegroundColor = .backgroundColor
        config.baseBackgroundColor = .LabelColor
        config.background.cornerRadius = 15
        var attr = AttributedString.init("사진 추가")
        attr.font = UIFont.caption
        config.attributedSubtitle = attr
        imagePlusButton.configuration = config
        
        imageCollectionView.showsHorizontalScrollIndicator = false
                
        tempTitleLabel.text = "이 코디와 함께 한 날의 온도는 어땠나요?"
        tempTitleLabel.font = .boldBody
        tempTextField.textField.placeholder = "ex) 25"
        tempTextField.textField.font = .body
        tempTextField.textField.keyboardType = .numberPad
        tempLabel.text = "℃"
        tempLabel.font = .body
        
        contentTextView.text = "텍스트뷰"
        contentTextView.font = .body
        contentTextView.layer.cornerRadius = 15
        contentTextView.layer.borderColor = UIColor.pointColor.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.clipsToBounds = true
        contentTextView.textContainer.lineFragmentPadding = 10
    }
    
    private func makeCellRegistration() {
        let cellRegistration = cellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: imageCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
    
    private func updateSnapshot(data: [UIImage]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, UIImage>()
        snapshot.appendSections([""])
        snapshot.appendItems(data, toSection: "")
        dataSource.apply(snapshot)
    }
}

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDidBeginEditing.accept(())
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDidEndEditing.accept(())
    }
}

extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        results.forEach { results in
            let itemProvider = results.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                    guard let self else { return }
                    guard let image = result as? UIImage else { return }
                    imageContainer.append(image)
                    DispatchQueue.main.async {
                        self.updateSnapshot(data: self.imageContainer)
                    }
                }
            }
        }
        imageSelectedButtonTap.accept(())
    }
}

// MARK: - Layout
extension CreatePostViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }
    
    private func cellRegistration() -> UICollectionView.CellRegistration<CreateImageCollectionViewCell, UIImage> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.imageView.image = itemIdentifier
        }
    }
}
