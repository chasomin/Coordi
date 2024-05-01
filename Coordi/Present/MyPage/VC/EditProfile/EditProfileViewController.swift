//
//  EditProfileViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditProfileViewController: BaseViewController {
    private let viewModel: EditProfileViewModel
    
    private let imagePickerCancel = PublishRelay<Void>()
    private let imagePickerFinishPicking = PublishRelay<Data>()
    private let viewDidLoadTrigger = PublishRelay<Void>()
    
    private let profileImageView = CirCleImageView()
    private let imageEditLabel = UILabel()
    private let nicknameTitleLabel = UILabel()
    private let nickname = UnderlineLabel()
    private let imageTapGesture = UITapGestureRecognizer()
    private let nicknameTapGesture = UITapGestureRecognizer()
    
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = EditProfileViewModel.Input(viewDidLoadTrigger: .init(),
                                               imageTap: imageTapGesture.rx.event.map { _ in () },
                                               labelTap: nicknameTapGesture.rx.event.map { _ in () },
                                               imagePickerCancel: imagePickerCancel,
                                               imagePickerFinishPicking: imagePickerFinishPicking)
        let output = viewModel.transform(input: input)
        
        viewDidLoadTrigger
            .bind { _ in
                input.viewDidLoadTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        output.viewDidLoadTrigger
            .drive(with: self) { owner, value in
                let (nick, profileImage) = value
                owner.nickname.label.text = nick
                owner.profileImageView.loadImage(from: profileImage)
            }
            .disposed(by: disposeBag)
        
        output.imageTap
            .drive(with: self) { owner, _ in
                let vc = UIImagePickerController()
                vc.allowsEditing = true
                vc.delegate = self
                owner.present(vc, animated: true)   //FIXME: ImagePick present도 ViewModel이????
            }
            .disposed(by: disposeBag)
        
        output.imagePickerFinishPicking
            .drive(with: self) { owner, image in
                owner.profileImageView.loadImage(from: image)
            }
            .disposed(by: disposeBag)
        
        output.changeNick
            .drive(with: self) { owner, nick in
                owner.nickname.label.text = nick
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(profileImageView)
        profileImageView.addSubview(imageEditLabel)
        view.addSubview(nicknameTitleLabel)
        view.addSubview(nickname)
        profileImageView.addGestureRecognizer(imageTapGesture)
        nickname.addGestureRecognizer(nicknameTapGesture)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.centerX.equalTo(view)
            make.size.equalTo(100)
        }
        
        imageEditLabel.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(profileImageView).dividedBy(4)
        }
        
        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(24)
        }
        
        nickname.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view).inset(15)
            make.height.equalTo(24)
            make.bottom.lessThanOrEqualTo(15)
        }
    }
    
    override func configureView() {
        navigationItem.title = Constants.NavigationTitle.editProfile.title
        nicknameTitleLabel.text = "닉네임"
        nicknameTitleLabel.font = .boldBody
        nickname.label.font = .body
        profileImageView.backgroundColor = .pointColor
        profileImageView.isUserInteractionEnabled = true
        imageEditLabel.text = "변경"
        imageEditLabel.textColor = .white
        imageEditLabel.textAlignment = .center
        imageEditLabel.font = .caption
        imageEditLabel.backgroundColor = .black
        imageEditLabel.alpha = 0.5
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerCancel.accept(())
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let image = pickedImage.compressedJPEGData else { return }
        imagePickerFinishPicking.accept(image)
    }
}
