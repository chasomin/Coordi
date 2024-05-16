//
//  ShopViewController.swift
//  Coordi
//
//  Created by 차소민 on 5/5/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShopViewController: BaseViewController {
    private let vieWModel: ShopViewModel
    
    private let reloadData = PublishRelay<Void>()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let searchBar = UISearchBar()
    
    init(vieWModel: ShopViewModel) {
        self.vieWModel = vieWModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData.accept(())
    }
    
    override func bind() {
        let input = ShopViewModel.Input(reloadData: .init(), 
                                        selectItem: .init(),
                                        keyboardDismissGesture: .init())
        let output = vieWModel.transform(input: input)
        
        reloadData
            .bind(to: input.reloadData)
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(PostModel.self)
            .bind(to: input.selectItem)
            .disposed(by: disposeBag)
        
        collectionView.rx.didScroll
            .bind(to: input.keyboardDismissGesture)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .bind(to: input.keyboardDismissGesture)
            .disposed(by: disposeBag)
            

        output.product
            .drive(collectionView.rx.items(cellIdentifier: ShopCollectionViewCell.id, cellType: ShopCollectionViewCell.self)) { index, element, cell in
                cell.configureCell(item: element)
            }
            .disposed(by: disposeBag)
                
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
            }
            .disposed(by: disposeBag)
        
        output.searchDone
            .drive(with: self) { owner, _ in
                owner.searchBar.endEditing(true)
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
        collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.id)
        
        navigationItem.titleView = searchBar
        searchBar.placeholder = Constants.Placeholder.shopSearch.rawValue
        searchBar.searchTextField.font = .caption
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 15
        layout.itemSize = CGSize(width: (view.frame.width - spacing * 3) / 2 , height: ((view.frame.width - spacing * 3) / 2) * 1.6)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        return layout
    }


}
