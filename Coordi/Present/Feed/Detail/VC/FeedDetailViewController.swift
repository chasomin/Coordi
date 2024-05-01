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
}

final class FeedDetailViewController: BaseViewController {
    
    private let viewModel: FeedDetailViewModel
    
    private let backButtonTap = PublishRelay<Void>()
    private let popGesture = PublishRelay<Void>()
    private let imageDoubleTapGesture = PublishRelay<Void>()
    private let heartButtonTap = PublishRelay<Void>()
    private let commentButtonTap = PublishRelay<Void>()
    private let profileTap = PublishRelay<Void>()
    private let postEditAction = PublishRelay<Void>()
    private let postDeleteAction = PublishRelay<Void>()
    private let popTrigger = PublishRelay<Void>()
    private let viewDidLoadTrigger = PublishRelay<Void>()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let panGesture = UIPanGestureRecognizer()

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()

    init(viewModel: FeedDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeCellRegistration()
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        panGesture.rx.event
            .withUnretained(self)
            .map { owner, gesture in
                let velocity = gesture.velocity(in: owner.view)
                let x = velocity.x
                let y = velocity.y
                return (x > 0.0 && y == 0.0)
            }
            .bind(with: self) { owner, value in
                if value {
                    owner.popGesture.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        
        let input = FeedDetailViewModel.Input(backButtonTap: backButtonTap,
                                              popGesture: popGesture,
                                              heartButtonTap: heartButtonTap,
                                              imageDoubleTap: imageDoubleTapGesture,
                                              profileTap: profileTap, 
                                              commentButtonTap: commentButtonTap,
                                              postEditAction: postEditAction,
                                              postDeleteAction: postDeleteAction,
                                              popTrigger: popTrigger, 
                                              viewDidLoad: viewDidLoadTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.viewDidLoadTrigger
            .drive(with: self) { owner, post in
                owner.updateSnapshot(post: post)
            }
            .disposed(by: disposeBag)
        
        output.heartButtonTap
            .drive(with: self) { owner, postModel in
                owner.snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()  //???: cell 추가하지 않고 cell 내부만 변경된다면 snapshot 초기화 방법밖에 없는지
                owner.updateSnapshot(post: postModel)
            }
            .disposed(by: disposeBag)
        
        output.imageDoubleTap
            .drive(with: self) { owner, postModel in
                owner.snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                owner.updateSnapshot(post: postModel)
            }
            .disposed(by: disposeBag)
        
        output.requestFailureTrigger
            .drive(with: self) { owner, errorText in
                owner.showErrorToast(errorText)
            }
            .disposed(by: disposeBag)
        
        output.refreshTokenFailure
            .drive(with: self) { owner, _ in
//                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//                let sceneDelegate = windowScene?.delegate as? SceneDelegate
//                sceneDelegate?.window?.rootViewController = LogInViewController()
//                sceneDelegate?.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)

        output.postDeleteAction
            .drive(with: self) { owner, text in
                owner.showCheckToast {
                    owner.popTrigger.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        output.changeComment
            .drive(with: self) { owner, post in
                owner.snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                owner.updateSnapshot(post: post)
            }
            .disposed(by: disposeBag)
    }
    
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
        view.addGestureRecognizer(panGesture)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func makeCellRegistration() {
        let profileCellRegistration = profileCellRegistration()
        let imageCellRegistration = imageCellRegistration()
        let contentCellRegistration = contentCellRegistration()
        
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
                }
            } else {
                return nil
            }
        })
    }
    private func updateSnapshot(post: PostModel) {
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([post.creator], toSection: .profile)
        snapshot.appendItems(post.files, toSection: .image)
        snapshot.appendItems([post], toSection: .content)
        dataSource.apply(snapshot)
    }
}

// MARK: - Layout
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
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(view.frame.width * 0.8 * 1.33))
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
            }

        }
        return layout
    }
    
    private func profileCellRegistration() -> UICollectionView.CellRegistration<ProfileNavigationCollectionViewCell, UserModel> {
        return UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            cell.backButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.backButtonTap.accept(())
                }
                .disposed(by: cell.disposeBag)
            cell.tapGesture.rx.event
                .bind(with: self) { owner, _ in
                    owner.profileTap.accept(())
                }
                .disposed(by: cell.disposeBag)
            cell.configureCell(item: itemIdentifier)
            let editAction = UIAction(title: "수정하기", handler: { _ in
                self.postEditAction.accept(())
            })
            let deleteAction = UIAction(title: "삭제하기", attributes: .destructive, handler: { _ in 
                self.postDeleteAction.accept(())
            })
            let buttonMenu = UIMenu(title: "", children: [editAction, deleteAction])
            cell.editButton.menu = buttonMenu
        }
    }
    
    private func imageCellRegistration() -> UICollectionView.CellRegistration<FeedDetailImageCollectionViewCell, String> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.tapGesture.rx.event
                .bind(with: self) { owner, _ in
                    owner.imageDoubleTapGesture.accept(())
                }
                .disposed(by: cell.disposeBag)
            cell.configureCell(item: itemIdentifier)

        }
    }
    
    private func contentCellRegistration() -> UICollectionView.CellRegistration<FeedContentCollectionViewCell, PostModel> {
        return UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            cell.heartButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.heartButtonTap.accept(())
                }
                .disposed(by: cell.disposeBag)
            
            cell.commentButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.commentButtonTap.accept(())
                }
                .disposed(by: cell.disposeBag)

            cell.configureCell(item: itemIdentifier)
        }
    }
    
}
