//
//  CreatePostViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/17/24.
//

import UIKit
import SnapKit

final class CreatePostViewController: BaseViewController {
    private let imagePlusButton = UIButton()
    private lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let tempTitleLabel = UILabel()
    private let tempTextField = LineTextField()
    private let tempLabel = UILabel()
    private let contentTextView = UITextView()
    private let saveButton = PointButton(text: "등록하기")
    
    private var dataSource: UICollectionViewDiffableDataSource<String, String>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeCellRegistration()
        updateSnapshot()
        navigationItem.title = "코디 올리기"
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
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.imagePlacement = .top
        config.baseForegroundColor = .LabelColor
        config.baseBackgroundColor = .pointColor
        var attr = AttributedString.init("사진 추가")
        attr.font = UIFont.body
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
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        snapshot.appendSections([""])
        snapshot.appendItems(ImageUploadModel.init(files: ["1","2","3","4","5"]).files, toSection: "")
        dataSource.apply(snapshot)
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
    
    private func cellRegistration() -> UICollectionView.CellRegistration<CreateImageCollectionViewCell, String> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.imageView.image = .coordi
        }
    }
}
