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
import Kingfisher

final class MyPageViewController: BaseViewController {
    private let profileView = MyProfileView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let viewModel = MyPageViewModel()
    
    private let editButtonTap = PublishRelay<Void>()
    private let barButton = UIBarButtonItem()
    
    private var posts: [PostModel] = []
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 15
        layout.itemSize = CGSize(width: (view.frame.width - spacing * 3) / 2 , height: ((view.frame.width - spacing * 3) / 2) * 1.33)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        return layout
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Constants.NavigationTitle.myPage.title
        navigationItem.rightBarButtonItem = barButton
    }
    
    override func configureHierarchy() {
        view.addSubview(profileView)
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        barButton.image = UIImage(systemName: "plus")
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.id)

        collectionView.showsVerticalScrollIndicator = false

    }

    override func bind() {
        let input = MyPageViewModel.Input(viewDidLoad: Observable.just(Void()), editButtonTap: editButtonTap, barButtonTap: barButton.rx.tap.asObservable(), itemSelected: collectionView.rx.modelSelected(PostModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        profileView.editButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.editButtonTap.accept(())
            }
            .disposed(by: disposeBag)
        
        output.profile
            .bind(with: self, onNext: { owner, profile in
                owner.profileView.profileImageView.loadImage(from: profile.profileImage)
                owner.profileView.nicknameLabel.text = profile.nick
            })
            .disposed(by: disposeBag)
        
        output.posts
            .map { $0.data }
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCollectionViewCell.id, cellType: FeedCollectionViewCell.self)) { index, post, cell in
                cell.configureCell(item: post)
            }
            .disposed(by: disposeBag)

        
        output.editButtonTap
            .bind(with: self) { owner, profile in
                owner.navigationController?.pushViewController(EditProfileViewController(nick: profile.nick, profileImage: profile.profileImage), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.barButtonTap
            .drive(with: self) { owner, _ in
                owner.navigationController?.pushViewController(CreatePostViewController(), animated: true)
            }
            .disposed(by: disposeBag)

        output.itemSelected
            .drive(with: self) { owner, postModel in
                owner.navigationController?.pushViewController(FeedDetailViewController(postModel: postModel), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.itemFetchFailureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast("⚠️")
            }
            .disposed(by: disposeBag)
        
        output.profileFetchFailureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast("⚠️")
            }
            .disposed(by: disposeBag)

        output.postsFetchFailureTrigger
            .drive(with: self) { owner, _ in
                owner.showErrorToast("⚠️")
            }
            .disposed(by: disposeBag)
    }    
}
