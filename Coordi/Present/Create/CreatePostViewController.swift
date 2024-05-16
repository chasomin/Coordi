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
    private let viewModel: CreatePostViewModel
    
    private let selectTemp = PublishRelay<Int>()
    private var imageSelectedButtonTap = PublishRelay<Void>()
    private var textViewDidBeginEditing = PublishRelay<String>()
    private var textViewDidEndEditing = PublishRelay<String>()
    private let popTrigger = PublishRelay<Void>()
    private var images: BehaviorRelay<[UIImage]> = .init(value: [])

    private var imageContainer: [UIImage] = [] {
        didSet {
            images.accept(imageContainer)
        }
    }
    private let imagePlusButton = UIButton()
    private lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let tempTitleLabel = UILabel()
    private let tempPicker = UIPickerView()
    private let tempLabel = UILabel()
    private let contentTextView = UITextView()
    private let saveButton = PointButton(text: "등록하기")
    
    private var temp: [Int] = Array(-20...30)
    
    private var dataSource: UICollectionViewDiffableDataSource<String, UIImage>!
    
    init(viewModel: CreatePostViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeCellRegistration()
        
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
                                              temp: .init(value: 0),
                                              content: .init(value: ""),
                                              imageData: imageData,
                                              textViewDidBeginEditing: textViewDidBeginEditing,
                                              textViewDidEndEditing: textViewDidEndEditing, 
                                              popTrigger: popTrigger)
        let output = viewModel.transform(input: input)
        
        selectTemp
            .bind(to: input.temp)
            .disposed(by: disposeBag)
        
        contentTextView.rx.text.orEmpty
            .map {
                return $0 == Constants.Placeholder.createPost.rawValue ? "" : $0
            }
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
                owner.present(picker, animated: true)   // FIXME: image picker 띄우는 것도 viewModel???
            }
            .disposed(by: disposeBag)
                
        output.saveButtonTap
            .drive(with: self) { owner, _ in
                owner.showCheckToast {
                    owner.popTrigger.accept(())
                }
                owner.saveButton.configuration?.showsActivityIndicator = false
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        output.buttonEnable
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
            }
            .disposed(by: disposeBag)
        
        output.textViewDidBeginEditing
            .drive(imagePlusButton.rx.isHidden, imageCollectionView.rx.isHidden, tempTitleLabel.rx.isHidden, tempPicker.rx.isHidden, tempLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.textViewDidEndEditing
            .drive(imagePlusButton.rx.isHidden, imageCollectionView.rx.isHidden, tempTitleLabel.rx.isHidden, tempPicker.rx.isHidden, tempLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.textViewPlaceholder
            .drive(contentTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.textViewPlaceholder
            .drive(with: self, onNext: { owner, text in
                if text == Constants.Placeholder.createPost.rawValue {
                    owner.contentTextView.textColor = .gray
                } else {
                    owner.contentTextView.textColor = .LabelColor
                }
            })
            .disposed(by: disposeBag)
        
        output.editPost
            .drive(with: self) { owner, post in
//                guard let post else { return }
//                let tempValue = post.tempNum
//                owner.tempPicker.selectRow(owner.temp.firstIndex(of: tempValue) ?? 0, inComponent: 0, animated: true)
//                owner.contentTextView.text = post.content1
//                owner.navigationItem.title = Constants.NavigationTitle.editPost.title
//                
//                post.files.forEach { image in
//                    guard let url = URL(string: BaseURL.baseURL.rawValue + BaseURL.version.rawValue + "/" + image) else { return }
//                    KingfisherManager.shared.retrieveImage(with: url) { result in
//                        let image = try? result.get().image
//                        if let image = image {
//                            owner.imageContainer.append(image)
//                            DispatchQueue.main.async {
//                                owner.updateSnapshot(data: owner.imageContainer)
//                            }
//                        }
//                    }
//                    
//                }
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(imagePlusButton)
        view.addSubview(imageCollectionView)
        view.addSubview(tempTitleLabel)
        view.addSubview(tempPicker)
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
        
        tempPicker.snp.makeConstraints { make in
            make.top.equalTo(tempTitleLabel.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(100)
            make.width.equalTo(80)
        }
        
        
        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(tempTitleLabel.snp.bottom)
            make.leading.equalTo(tempPicker.snp.trailing).offset(5)
            make.height.equalTo(tempPicker)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(tempPicker.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(15)
            make.height.equalTo(50)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
    }
    
    override func configureView() {
        navigationItem.title = Constants.NavigationTitle.create.title

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
                
        tempTitleLabel.text = Constants.TitleLabel.createTemp.title
        tempTitleLabel.font = .boldBody

        tempLabel.text = "℃"
        tempLabel.font = .body
        
        tempPicker.delegate = self
        tempPicker.dataSource = self
        tempPicker.selectRow(temp.firstIndex(of: 0) ?? 0, inComponent: 0, animated: true)
        
        contentTextView.delegate = self
        contentTextView.text = Constants.Placeholder.createPost.rawValue
        contentTextView.font = .body
        contentTextView.textColor = .gray
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
        textViewDidBeginEditing.accept(textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDidEndEditing.accept(textView.text)
    }
}

extension CreatePostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        temp.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectTemp.accept(temp[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = temp[row].description
        label.font = .body
        label.textAlignment = .center
        return label
    }
}

extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        results.forEach { result in
            let itemProvider = result.itemProvider
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
