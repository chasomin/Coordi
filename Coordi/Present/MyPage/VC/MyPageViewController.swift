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
    private let viewModel: MyPageViewModel
    
    private let editButtonTap = PublishRelay<String>()
    private let dataReload = PublishRelay<Void>()
    
    private let profileView = MyProfileView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let plusBarButton = UIBarButtonItem()
    private let settingBarButton = UIBarButtonItem()
        
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataReload.accept(())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = MyPageViewModel.Input(dataReload: dataReload,
                                          editButtonTap: profileView.editButton.rx.tap.asObservable(),
                                          followButtonTap: profileView.followButton.rx.tap.asObservable(),
                                          plusButtonTap: plusBarButton.rx.tap.asObservable(),
                                          itemSelected: collectionView.rx.modelSelected(PostModel.self).asObservable(),
                                          settingButtonTap: settingBarButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.profile
            .bind(with: self, onNext: { owner, profile in
                owner.profileView.configure(profile: profile)
            })
            .disposed(by: disposeBag)
        
        output.posts
            .map { $0.data }
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCollectionViewCell.id, cellType: FeedCollectionViewCell.self)) { index, post, cell in
                cell.configureCell(item: post)
            }
            .disposed(by: disposeBag)
        
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
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
        
        output.isMyFeed
            .drive(with: self) { owner, value in
                let (isMyFeed, profile) = value
                owner.profileView.followButton.isHidden = isMyFeed
                owner.plusBarButton.isHidden = !isMyFeed
                owner.settingBarButton.isHidden = !isMyFeed
                owner.navigationItem.title = Constants.NavigationTitle.myPage(value: isMyFeed, nick: profile.nick).title
            }
            .disposed(by: disposeBag)
        
        output.followValue
            .drive(with: self) { owner, follow in
                owner.profileView.followButton.setTitle(text: follow.following_status ? "팔로우 취소" : "팔로우", font: .boldBody)
                let followCount = owner.profileView.followerCount.text!
                owner.profileView.followerCount.text = follow.following_status ? ((Int(followCount) ?? 0) + 1).description : ((Int(followCount) ?? 0) - 1).description
            }
            .disposed(by: disposeBag)
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
        navigationItem.rightBarButtonItems = [settingBarButton, plusBarButton]
        plusBarButton.image = UIImage(systemName: "plus")
        settingBarButton.image = UIImage(systemName: "ellipsis")
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.id)
        collectionView.showsVerticalScrollIndicator = false
    }
    
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
