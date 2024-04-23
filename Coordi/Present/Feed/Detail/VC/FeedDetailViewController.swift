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
    private let commentTextfield = RoundedTextFieldView()
    private let commentButton = UIButton()
    private let panGesture = UIPanGestureRecognizer()

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()

    var postModel: PostModel
    
    private let backButtonTap = PublishRelay<Void>()
    private let commentButtonTap = PublishRelay<String>()
    private let popGesture = PublishRelay<Void>()

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
        
        let input = FeedDetailViewModel.Input(postId: Observable.just(postModel.post_id), backButtonTap: backButtonTap, commentButtonTap: commentButtonTap, popGesture: popGesture)
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
        
        output.commentUploadFailureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast()
            }
            .disposed(by: disposeBag)
        
        output.popGesture
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
                
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
        view.addSubview(commentTextfield)
        view.addSubview(commentButton)
        view.addGestureRecognizer(panGesture)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        commentTextfield.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }
        commentButton.snp.makeConstraints { make in
            make.leading.equalTo(commentTextfield.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(40)
        }
    }
    
    override func configureView() {
        commentTextfield.textField.placeholder = "댓글"
        let config = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 30))
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
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
        print("@@@", postModel)
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
                layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 60, trailing: 15)

                return layoutSection
            }

        }
        return layout
    }
    
    private func profileCellRegistration() -> UICollectionView.CellRegistration<ProfileNavigationCollectionViewCell, UserModel> {
        return UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            cell.backButton.rx.tap.bind(to: backButtonTap).disposed(by: disposeBag)
            cell.nicknameLabel.text = itemIdentifier.nick
            cell.profileImage.loadImage(from: itemIdentifier.profileImage)
        }
    }
    
    private func imageCellRegistration() -> UICollectionView.CellRegistration<FeedDetailImageCollectionViewCell, String> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.imageView.loadImage(from: itemIdentifier)
            
        }
    }
    
    private func contentCellRegistration() -> UICollectionView.CellRegistration<FeedContentCollectionViewCell, PostModel> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.contentLabel.text = itemIdentifier.content1
            cell.dateLabel.text = itemIdentifier.createdAt
            cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.tempLabel.text = itemIdentifier.content
        }
    }
    
    private func commentCellRegistration() -> UICollectionView.CellRegistration<CommentCollectionViewCell, CommentModel> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.commentLabel.text = itemIdentifier.content
            cell.nicknameLabel.text = itemIdentifier.creator.nick
            cell.profileImageView.loadImage(from: itemIdentifier.creator.profileImage)
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
