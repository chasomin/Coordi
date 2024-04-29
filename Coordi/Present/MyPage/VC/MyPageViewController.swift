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
    
    private let profileView = MyProfileView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let plusBarButton = UIBarButtonItem()
    private let settingBarButton = UIBarButtonItem()
    
//    private var posts: [PostModel] = []
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [settingBarButton, plusBarButton]
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
        plusBarButton.image = UIImage(systemName: "plus")
        settingBarButton.image = UIImage(systemName: "line.3.horizontal")
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.id)

        collectionView.showsVerticalScrollIndicator = false

    }

    override func bind() {
        
        let input = MyPageViewModel.Input(editButtonTap: profileView.editButton.rx.tap.asObservable(),
                                          followButtonTap: profileView.followButton.rx.tap.asObservable(),
                                          plusButtonTap: plusBarButton.rx.tap.asObservable(),
                                          itemSelected: collectionView.rx.modelSelected(PostModel.self).asObservable(),
                                          settingButtonTap: settingBarButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.profile
            .bind(with: self, onNext: { owner, profile in
                owner.profileView.profileImageView.loadImage(from: profile.profileImage)
                owner.profileView.nicknameLabel.text = profile.nick
                owner.profileView.followerCount.text = "\(profile.followers.count)"
                owner.profileView.followingCount.text = "\(profile.following.count)"
                if profile.followers.map({ $0.user_id == UserDefaultsManager.userId }).isEmpty {
                    owner.profileView.followButton.setTitle(text: "팔로우", font: .boldBody)
                } else {
                    owner.profileView.followButton.setTitle(text: "팔로우 취소", font: .boldBody)
                }
            })
            .disposed(by: disposeBag)
        
        output.posts
            .map { $0.data }
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCollectionViewCell.id, cellType: FeedCollectionViewCell.self)) { index, post, cell in
                cell.configureCell(item: post)
            }
            .disposed(by: disposeBag)
        
        output.plusButtonTap
            .drive(with: self) { owner, _ in
                owner.navigationController?.pushViewController(CreatePostViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.settingButtonTap
            .drive(with: self) { owner, _ in
                let vc = SettingViewController()
                vc.sheetPresentationController?.detents = [.medium()]
                vc.sheetPresentationController?.prefersGrabberVisible = true
                owner.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.itemSelected
            .drive(with: self) { owner, postModel in
                owner.navigationController?.pushViewController(FeedDetailViewController(postModel: BehaviorRelay(value: postModel)),
                                                               animated: true)
            }
            .disposed(by: disposeBag)
        
        output.failureTrigger
            .drive(with: self) { owner, text in
                owner.showErrorToast(text)
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

        output.isMyFeed
            .drive(with: self) { owner, value in
                let (isMyFeed, profile) = value
                owner.profileView.followButton.isHidden = isMyFeed
                owner.plusBarButton.isHidden = !isMyFeed
                owner.settingBarButton.isHidden = !isMyFeed
                owner.navigationItem.title = Constants.NavigationTitle.myPage(value: isMyFeed, nick: profile.nick).title
            }
            .disposed(by: disposeBag)
        
        output.editButtonTap
            .bind(with: self) { owner, profile in
                owner.navigationController?.pushViewController(EditProfileViewController(nick: profile.nick, profileImage: profile.profileImage), animated: true)
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

}
