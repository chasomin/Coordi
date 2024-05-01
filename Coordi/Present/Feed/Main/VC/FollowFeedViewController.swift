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
    private let postData = BehaviorRelay<[PostModel]>(value: [])

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

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
        let input = FollowFeedViewModel.Input(dataReload: viewReloadTrigger,
                                              itemSelected: collectionView.rx.modelSelected(PostModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.postData
            .drive(collectionView.rx.items(cellIdentifier: FollowingFeedCollectionViewCell.id, cellType: FollowingFeedCollectionViewCell.self)) { index, element, cell in
                cell.configureCell(item: element)
                let imageView = UIImageView()
                imageView.loadImage(from: element.files.first!)
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
