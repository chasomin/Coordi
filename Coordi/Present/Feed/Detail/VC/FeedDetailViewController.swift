//
//  FeedDetailViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum Section: Int, CaseIterable {
    case profile
    case image
    case content
    case comment
}

final class FeedDetailViewController: BaseViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
    var postModel: PostModel
    
    private let backButtonTap = PublishRelay<Void>()
    
    init(postModel: PostModel) {
        self.postModel = postModel
        
        super.init()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        makeCellRegistration()
        updateSnapshot()
    }
    override func bind() {
        backButtonTap
            .subscribe(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    //TODO: toolbar 로 댓글 작성창, 제스처 왼->오른 pop, ViewModel
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
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
        
    }
    
    private func makeCellRegistration() {
        let profileCellRegistration = profileCellRegistration()
        let imageCellRegistration = imageCellRegistration()
        let contentCellRegistration = contentCellRegistration()
        let commentCellRegistration = commentCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if let section = Section(rawValue: indexPath.section) {
                switch section {
                case .profile:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: profileCellRegistration, for: indexPath, item: itemIdentifier as? UserModel)
                    return cell
                case .image:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: itemIdentifier as? String)
                    return cell
                case .content:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: contentCellRegistration, for: indexPath, item: itemIdentifier as? PostModel)
                    return cell
                case .comment:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: commentCellRegistration, for: indexPath, item: itemIdentifier as? CommentModel)
                    return cell
                }
            } else {
                return nil
            }
        })
    }
    
    private func updateSnapshot() {
        print("@@@", postModel)
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([postModel.creator], toSection: .profile)
        snapshot.appendItems(postModel.files, toSection: .image)
        snapshot.appendItems([postModel], toSection: .content)
        snapshot.appendItems(postModel.comments, toSection: .comment)
        dataSource.apply(snapshot)
    }

}

extension FeedDetailViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self else { return nil }
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .profile:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let layoutSection = NSCollectionLayoutSection(group: group)

                return layoutSection
            case .image:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(400))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging
                layoutSection.contentInsets = .init(top: 0, leading: view.frame.width * 0.1, bottom: 0, trailing: view.frame.width * 0.1)

                return layoutSection
            case .content:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.contentInsets = .init(top: 15, leading: 15, bottom: 15, trailing: 15)

                return layoutSection
            case .comment:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])//
                
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 15, trailing: 15)

                return layoutSection
            }

        }
        return layout
    }
    
    private func profileCellRegistration() -> UICollectionView.CellRegistration<ProfileNavigationCollectionViewCell, UserModel> {//
        return UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            cell.backButton.rx.tap.bind(to: backButtonTap).disposed(by: disposeBag)
            cell.nicknameLabel.text = itemIdentifier.nick
            cell.profileImage.loadImage(from: itemIdentifier.profileImage)
            print("@@@", itemIdentifier.nick)
        }
    }
    
    private func imageCellRegistration() -> UICollectionView.CellRegistration<FeedDetailImageCollectionViewCell, String> {//
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.imageView.loadImage(from: itemIdentifier)
            
        }
    }
    
    private func contentCellRegistration() -> UICollectionView.CellRegistration<FeedContentCollectionViewCell, PostModel> {//
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.contentLabel.text = itemIdentifier.content1
            cell.dateLabel.text = itemIdentifier.createdAt
            cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.tempLabel.text = itemIdentifier.content
        }
    }
    
    private func commentCellRegistration() -> UICollectionView.CellRegistration<CommentCollectionViewCell, CommentModel> {//
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.commentLabel.text = itemIdentifier.content
            cell.nicknameLabel.text = itemIdentifier.creator.nick
            cell.profileImageView.loadImage(from: itemIdentifier.creator.profileImage)
        }
    }

    
    
}


