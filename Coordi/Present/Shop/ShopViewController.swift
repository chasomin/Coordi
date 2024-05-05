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
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    
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
                                        selectItem: .init())
        let output = vieWModel.transform(input: input)
        
        reloadData
            .bind(to: input.reloadData)
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(PostModel.self)
            .bind(to: input.selectItem)
            .disposed(by: disposeBag)
        
        output.product
            .drive(collectionView.rx.items(cellIdentifier: ShopCollectionViewCell.id, cellType: ShopCollectionViewCell.self)) { index, element, cell in
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
        collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.id)
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
