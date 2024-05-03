//
//  LikeAllFeedViewController.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LikeAllFeedViewController: BaseViewController {
    private let viewModel: LikeAllFeedViewModel
    
    private let dataReloadTrigger = PublishRelay<Void>()
    private let itemSelected = PublishRelay<PostModel>()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

    init(viewModel: LikeAllFeedViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataReloadTrigger.accept(())
    }
    
    override func bind() {
        let input = LikeAllFeedViewModel.Input(dataReloadTrigger: dataReloadTrigger,
                                               itemSelected: itemSelected,
                                               lastItemIndex: .init())
        let output = viewModel.transform(input: input)
        
        
        collectionView.rx.modelSelected(PostModel.self)
            .bind(to: itemSelected)
            .disposed(by: disposeBag)
        
        collectionView.rx.prefetchItems
            .map { $0.last?.item }
            .bind(to: input.lastItemIndex)
            .disposed(by: disposeBag)
        
        output.likePosts
            .drive(collectionView.rx.items(cellIdentifier: FeedCollectionViewCell.id, cellType: FeedCollectionViewCell.self)) { index, element, cell in
                cell.configureCell(item: element)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        navigationItem.title = Constants.NavigationTitle.likeFeeds.title
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.id)
    }
    
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 15
        layout.itemSize = CGSize(width: (view.frame.width - spacing * 3) / 2 , height: ((view.frame.width - spacing * 3) / 2) * 1.33)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        return layout
    }
}
