//
//  SearchViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    private let viewModel: SearchViewModel
        
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let searchBar = UISearchBar()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = SearchViewModel.Input(searchText: searchBar.rx.text.orEmpty.asObservable(), 
                                          searchButtonTap: searchBar.rx.searchButtonClicked.asObservable(),
                                          itemSelected: collectionView.rx.modelSelected(PostModel.self).asObservable(),
                                          lastItemIndex: .init())
        let output = viewModel.transform(input: input)
        
        collectionView.rx.prefetchItems
            .map { $0.last?.item }
            .bind(to: input.lastItemIndex)
            .disposed(by: disposeBag)
        
        output.posts
            .drive(collectionView.rx.items(cellIdentifier: FeedCollectionViewCell.id, cellType: FeedCollectionViewCell.self)) { index, element, cell in
                cell.configureCell(item: element)
            }
            .disposed(by: disposeBag)
        
        output.posts
            .drive(with: self) { owner, _ in
                owner.searchBar.endEditing(true)
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
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        navigationItem.titleView = searchBar
        searchBar.placeholder = Constants.Placeholder.feedSearch.rawValue
        searchBar.keyboardType = .numbersAndPunctuation
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.id)
    }
}

extension SearchViewController {
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
