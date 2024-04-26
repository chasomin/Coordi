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
    private let viewModel = FeedDetailViewModel()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let bottomView = UIView()
    private let commentTextfield = RoundedTextFieldView()
    private let commentButton = UIButton()
    private let panGesture = UIPanGestureRecognizer()

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()

    var postModel: PostModel
    
    private let backButtonTap = PublishRelay<Void>()
    private let commentButtonTap = PublishRelay<String>()
    private let popGesture = PublishRelay<Void>()
    private let imageDoubleTapGesture = PublishRelay<PostModel>()
    private let heartButtonTap = PublishRelay<PostModel>()

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
        commentButton.rx.tap
            .withLatestFrom(commentTextfield.textField.rx.text.orEmpty)
            .subscribe(with: self) { owner, comment in
                owner.commentButtonTap.accept(comment)
            }
            .disposed(by: disposeBag)

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
        
        let input = FeedDetailViewModel.Input(postId: Observable.just(postModel.post_id), backButtonTap: backButtonTap, commentButtonTap: commentButtonTap, popGesture: popGesture, heartButtonTap: heartButtonTap, imageDoubleTap: imageDoubleTapGesture)
        let output = viewModel.transform(input: input)
        
        output.backButtonTap
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.commentUploadSuccessTrigger
            .drive(with: self) { owner, commentModel in
                owner.snapshot.appendItems([commentModel], toSection: .comment)
                owner.dataSource.apply(owner.snapshot)

                let indexPath = IndexPath(item: owner.collectionView.numberOfItems(inSection: owner.collectionView.numberOfSections - 1) - 1, section: owner.collectionView.numberOfSections - 1)
                owner.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
            .disposed(by: disposeBag)
        
//        output.commentUploadFailureTrigger
//            .drive(with: self) { owner, _ in
//                owner.showErrorToast()
//            }
//            .disposed(by: disposeBag)
//        
        output.popGesture
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.heartButtonTap
            .drive(with: self) { owner, postModel in
                owner.postModel = postModel
                owner.snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()  //???: cell 추가하지 않고 cell 내부만 변경된다면 snapshot 초기화 방법밖에 없는지
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
        output.imageDoubleTap
            .drive(with: self) { owner, postModel in
                owner.postModel = postModel
                owner.snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
        output.requestFailureTrigger
            .drive(with: self) { owner, errorText in
                owner.showErrorToast(errorText)
            }
            .disposed(by: disposeBag)
        
        output.refreshTokenFailure
            .drive(with: self) { owner, _ in
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                sceneDelegate?.window?.rootViewController = LogInViewController()
                sceneDelegate?.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)

//        output.heartFailureTrigger
//            .drive(with: self) { owner, _ in
//                owner.showErrorToast()
//            }
//            .disposed(by: disposeBag)
    }
    // TODO: 내 댓글만 밀어서 삭제
    
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
        view.addSubview(bottomView)
        bottomView.addSubview(commentTextfield)
        bottomView.addSubview(commentButton)
        view.addGestureRecognizer(panGesture)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        bottomView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.top.equalTo(collectionView.snp.bottom)
        }
        
        commentTextfield.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview()
            make.height.equalTo(40)
        }
        commentButton.snp.makeConstraints { make in
            make.leading.equalTo(commentTextfield.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview()
            make.size.equalTo(40)
        }
    }
    
    override func configureView() {
        bottomView.backgroundColor = .backgroundColor
        commentTextfield.textField.placeholder = "댓글"
        let image = UIImage(systemName: "arrow.up.circle.fill")?.setConfiguration(font: .boldSystemFont(ofSize: 30))
        commentButton.setImage(image, for: .normal)
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
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([postModel.creator], toSection: .profile)
        snapshot.appendItems(postModel.files, toSection: .image)
        snapshot.appendItems([postModel], toSection: .content)
        snapshot.appendItems(postModel.comments.reversed(), toSection: .comment)
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
            case .comment:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))//
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.interGroupSpacing = 10
                layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 15, trailing: 15)

                return layoutSection
            }

        }
        return layout
    }
    
    private func profileCellRegistration() -> UICollectionView.CellRegistration<ProfileNavigationCollectionViewCell, UserModel> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.backButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.backButtonTap.accept(())
                }
                .disposed(by: cell.disposeBag)
            cell.configureCell(item: itemIdentifier)
        }
    }
    
    private func imageCellRegistration() -> UICollectionView.CellRegistration<FeedDetailImageCollectionViewCell, String> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.tapGesture.rx.event
                .bind(with: self) { owner, _ in
                    owner.imageDoubleTapGesture.accept(owner.postModel)
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
                    owner.heartButtonTap.accept(owner.postModel)
                }
                .disposed(by: cell.disposeBag)

            cell.configureCell(item: itemIdentifier)
        }
    }
    
    private func commentCellRegistration() -> UICollectionView.CellRegistration<CommentCollectionViewCell, CommentModel> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.configureCell(item: itemIdentifier)
        }
    }
}


extension UICollectionView {
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: self.frame.height)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
}
