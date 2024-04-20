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
    private let viewModel = EditProfileViewModel()
    private let imagePickerCancel = PublishRelay<Void>()
    private let imagePickerFinishPicking = PublishRelay<Data>()
    
    var nick: String
    var profileImage: String
    
    private let profileImageView = CirCleImageView()
    private let nicknameTitleLabel = UILabel()
    private let nickname = UnderlineLabel()
    private let imageTapGesture = UITapGestureRecognizer()
    private let nicknameTapGesture = UITapGestureRecognizer()
    
    init(nick: String, profileImage: String) {
        self.nick = nick
        self.profileImage = profileImage
        
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "프로필 관리"
    }
    
    override func configureHierarchy() {
        view.addSubview(profileImageView)
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
        nicknameTitleLabel.text = "닉네임"
        nicknameTitleLabel.font = .boldBody
        nickname.label.text = nick
        nickname.label.font = .body
        profileImageView.backgroundColor = .pointColor
        profileImageView.isUserInteractionEnabled = true
        profileImageView.loadImage(from: profileImage)
    }
    
    override func bind() {
        let input = EditProfileViewModel.Input(imageTap: imageTapGesture.rx.event.map { _ in () },
                                               labelTap: nicknameTapGesture.rx.event.map { _ in () },
                                               imagePickerCancel: imagePickerCancel,
                                               imagePickerFinishPicking: imagePickerFinishPicking)
        let output = viewModel.transform(input: input)
        
        output.imageTap
            .drive(with: self) { owner, _ in
                let vc = UIImagePickerController()
                vc.allowsEditing = true
                vc.delegate = self
                owner.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.labelTap
            .drive(with: self) { owner, _ in
                print("label 탭")
                //TODO: 닉네임 텍스트필드 + 확인 버튼 수정뷰
//                owner.navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
            }
            .disposed(by: disposeBag)
        
        output.imagePickerCancel
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.imagePickerFinishPicking
            .drive(with: self) { owner, image in
                owner.profileImageView.loadImage(from: image)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
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
