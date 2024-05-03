//
//  FollowFeedViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/29/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

import Alamofire

final class FollowFeedViewController: BaseViewController {
    private let viewModel: FollowFeedViewModel
    
    private let viewReloadTrigger = PublishRelay<Void>()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let plusButton = CircleButton(image: "plus")

    init(viewModel: FollowFeedViewModel) {
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
        let input = FollowFeedViewModel.Input(dataReload: .init(),
                                              itemSelected: .init(),
                                              lastItemIndex: .init(), 
                                              plusButtonTap: .init())
        let output = viewModel.transform(input: input)
        
        viewReloadTrigger
            .bind(with: self) { owner, _ in
                owner.showToastActivity()
                input.dataReload.accept(())
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.prefetchItems
            .map { $0.last?.item }
            .bind(to: input.lastItemIndex)
            .disposed(by: disposeBag)

        
        collectionView.rx.modelSelected(PostModel.self)
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(to: input.itemSelected)
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .bind(to: input.plusButtonTap)
            .disposed(by: disposeBag)
        
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
        
        output.requestFailureTrigger
            .drive(with: self) { owner, errorText in
                owner.showErrorToast(errorText)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(plusButton)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        plusButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.size.equalTo(60)
        }
    }
    
    override func configureView() {
        collectionView.register(FollowingFeedCollectionViewCell.self, forCellWithReuseIdentifier: FollowingFeedCollectionViewCell.id)
        plusButton.layer.shadowRadius = 3
        plusButton.layer.shadowOpacity = 0.5
        plusButton.layer.shadowOffset = .init(width: 1, height: 1)
        plusButton.layer.shadowColor = UIColor.gray.cgColor
        
    }
}

extension FollowFeedViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 15
        layout.itemSize = CGSize(width: (view.frame.width - spacing * 2) , height: ((view.frame.width - spacing * 2)) * 1.4)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        return layout
    }
}
