//
//  MyPageViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyPageViewController: BaseViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var dataSource: UICollectionViewDiffableDataSource<ProfileModel, PostModel>!
    
    private let viewModel = MyPageViewModel()
    
    private let editButtonTap = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCellRegistration()
        navigationItem.title = "내 피드 모아보기"
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func bind() {
        let input = MyPageViewModel.Input(viewDidLoad: Observable.just(Void()), editButtonTap: editButtonTap)
        let output = viewModel.transform(input: input)
        
        var snapshot = NSDiffableDataSourceSnapshot<ProfileModel, PostModel>()
                
        output.profile
            .bind(with: self, onNext: { owner, profile in
                snapshot.appendSections([profile])
                owner.dataSource.apply(snapshot)
            })
            .disposed(by: disposeBag)
        
        output.posts
            .bind(with: self, onNext: { owner, posts in
                snapshot.appendItems(posts.data)
                owner.dataSource.apply(snapshot)
            })
            .disposed(by: disposeBag)
        
        output.editButtonTap
            .bind(with: self) { owner, profile in
                print("!!클릭")
                owner.navigationController?.pushViewController(EditProfileViewController(nick: profile.nick, profileImage: profile.profileImage), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func makeCellRegistration() {
        let cellRegistration = cellRegistration()
        let headerRegistration = headerRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
        
        dataSource.supplementaryViewProvider = { view, kind, index in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
    }
}

// MARK: - Layout
extension MyPageViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = .init(top: 0, leading: 10, bottom: 15, trailing: 10)
        section.interGroupSpacing = 20

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(100))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: MyProfileView.id, alignment: .topLeading)
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func cellRegistration() -> UICollectionView.CellRegistration<MyPageCollectionViewCell, PostModel> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
//            cell.image.image = itemIdentifier.files.first!
            cell.tempLabel.text = itemIdentifier.content
        }
    }
    
    private func headerRegistration() -> UICollectionView.SupplementaryRegistration<MyProfileView> {
        return UICollectionView.SupplementaryRegistration(elementKind: MyProfileView.id, handler: { [weak self] profileView, elementKind, indexPath in
            guard let self else { return }
            guard let model = dataSource.itemIdentifier(for: indexPath), let profileData = dataSource.snapshot().sectionIdentifier(containingItem: model) else { return }
            profileView.profileImageView//
            
            profileView.nicknameLabel.text = profileData.nick
            profileView.followerCount.text = profileData.followers.count.description
            profileView.followingCount.text = profileData.following.count.description
            
            profileView.editButton.rx.tap
                .bind(to: editButtonTap)
                .disposed(by: profileView.disposeBag)
        })
    }
}
