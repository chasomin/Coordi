//
//  ShopDetailViewController.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShopDetailViewController: BaseViewController {
    private let viewModel: ShopDetailViewModel
    
    private let reloadData = PublishRelay<Void>()
    
    private lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let priceLabel = UILabel()
    private let productLabel = UILabel()
    private let purchaseStack = UIStackView()
    private let bookmarkButton = UIButton()
    private let purchaseButton = CapsuleButton(text: "구매하기", textColor: .white, backColor: .pointColor, font: .boldBody)
    private let shoppingBagButton = CapsuleButton(text: "장바구니", textColor: .pointColor, backColor: .pointColor, font: .boldBody, isPointButton: false)
    
    private var dataSource: UICollectionViewDiffableDataSource<String, String>!

    
    init(viewModel: ShopDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCellRegistration()
        reloadData.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func bind() {
        let input = ShopDetailViewModel.Input(reloadData: reloadData)
        let output = viewModel.transform(input: input)
        
        output.product
            .drive(with: self) { owner, product in
                owner.configure(item: product)
                owner.updateSnapshot(product: product)
            }
            .disposed(by: disposeBag)
        
        //
    }
    
    override func configureHierarchy() {
        view.addSubview(imageCollectionView)
        view.addSubview(priceLabel)
        view.addSubview(productLabel)
        view.addSubview(purchaseStack)
        purchaseStack.addArrangedSubview(bookmarkButton)
        purchaseStack.addArrangedSubview(shoppingBagButton)
        purchaseStack.addArrangedSubview(purchaseButton)
    }
    
    override func configureLayout() {
        imageCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.frame.width * 0.8 * 1.33)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        productLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        purchaseStack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
    }
    
    override func configureView() {
        imageCollectionView.isScrollEnabled = false
        
        purchaseStack.axis = .horizontal
        purchaseStack.spacing = 10
        purchaseStack.distribution = .fillProportionally
        
        priceLabel.font = .boldBody
        productLabel.font = .body
    }
    
    func configure(item: PostModel) {
        priceLabel.text = item.price
        productLabel.text = item.content1
        let unbooked = UIImage(systemName: "bookmark")?.setConfiguration(font: .largeTitle)
        let booked = UIImage(systemName: "bookmark.fill")?.setConfiguration(font: .largeTitle)
        item.likes.contains(UserDefaultsManager.userId) ? bookmarkButton.setImage(booked, for: .normal) : bookmarkButton.setImage(unbooked, for: .normal)
        navigationItem.title = item.brand
    }
    
    private func makeCellRegistration() {       
        let cellRegistration = cellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: imageCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }

    private func updateSnapshot(product: PostModel) {
        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        snapshot.appendSections([""])
        snapshot.appendItems(product.files, toSection: "")
        dataSource.apply(snapshot)
    }
}

// MARK: - Layout
extension ShopDetailViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(view.frame.width * 0.8 * 1.33))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 0, leading: view.frame.width * 0.1, bottom: 0, trailing: view.frame.width * 0.1)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func cellRegistration() -> UICollectionView.CellRegistration<FeedDetailImageCollectionViewCell, String> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.imageView.loadImage(from: itemIdentifier)
        }
    }
}
