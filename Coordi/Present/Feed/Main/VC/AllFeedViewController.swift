//
//  AllFeedViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AllFeedViewController: BaseViewController {
    private let viewModel: AllFeedViewModel
    
    private let viewReloadTrigger = PublishRelay<Void>()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

    init(viewModel: AllFeedViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewReloadTrigger.accept(())
    }
    
    override func bind() {
        let input = AllFeedViewModel.Input(viewReloadTrigger: .init(),
                                           itemSelected: .init(),
                                           lastItemIndex: .init())
                
        viewReloadTrigger
            .bind(with: self) { owner, _ in
                owner.showToastActivity()
                input.viewReloadTrigger.accept(())
            }
            .disposed(by: disposeBag)

        
        collectionView.rx.modelSelected(PostModel.self)
            .bind(to: input.itemSelected)
            .disposed(by: disposeBag)
        
        collectionView.rx.prefetchItems
            .map { $0.last?.item }
            .bind(to: input.lastItemIndex)
            .disposed(by: disposeBag)        
        
        let output = viewModel.transform(input: input)

        output.postData
            .drive(collectionView.rx.items(cellIdentifier: FollowingFeedCollectionViewCell.id, cellType: FollowingFeedCollectionViewCell.self)) { index, element, cell in
            cell.configureCell(item: element)
        }
        .disposed(by: disposeBag)
        
        output.postData
            .drive(with: self) { owner, posts in
                owner.hideToastActivity()
            }
            .disposed(by: disposeBag)
        
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
            }
            .disposed(by: disposeBag)
        

    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        collectionView.register(FollowingFeedCollectionViewCell.self, forCellWithReuseIdentifier: FollowingFeedCollectionViewCell.id)
    }
}

extension AllFeedViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 15
        layout.itemSize = CGSize(width: (view.frame.width - spacing * 3)/2 , height: ((view.frame.width - spacing * 3)/2) * 1.5)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        return layout
    }
}
