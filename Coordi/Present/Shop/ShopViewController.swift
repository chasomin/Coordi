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
    private let shoppingBagButton = UIButton()
    private let itemCountLabel = UILabel()
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
        
        output.shoppingBagItems
            .drive(with: self) { owner, items in
                owner.itemCountLabel.isHidden = items.count == 0 ? true : false
                owner.itemCountLabel.text = "\(items.count)"
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
        
        shoppingBagButton.addSubview(itemCountLabel)
        
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().offset(5)
            make.size.equalTo(16)
        }
        
    }
    
    override func configureView() {
        collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.id)
        itemCountLabel.layer.cornerRadius = 8
        itemCountLabel.clipsToBounds = true
        itemCountLabel.font = .caption
        itemCountLabel.backgroundColor = .pointColor
        itemCountLabel.textColor = .white
        itemCountLabel.textAlignment = .center
        let image = UIImage(systemName: "basket")?.setConfiguration(font: .systemFont(ofSize: 24))
        shoppingBagButton.setImage(image, for: .normal)
        
        
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shoppingBagButton)
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
