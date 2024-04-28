//
//  FeedContentView.swift
//  Coordi
//
//  Created by 차소민 on 4/21/24.
//

import UIKit
import SnapKit
import RxSwift

final class FeedContentCollectionViewCell: BaseCollectionViewCell {
    var disposeBag = DisposeBag()

    let tempTitleLabel = UILabel()
    let tempLabel = UILabel()
    let heartStack = UIStackView()
    let commentStack = UIStackView()
    let commentButton = UIButton()
    let commentCountLabel = UILabel()
    let heartButton = UIButton()
    let heartCountLabel = UILabel()
    let contentLabel = UILabel()
    let dateLabel = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(tempTitleLabel)
        contentView.addSubview(tempLabel)
        contentView.addSubview(heartStack)
        contentView.addSubview(commentStack)
        heartStack.addArrangedSubview(heartButton)
        heartStack.addArrangedSubview(heartCountLabel)
        commentStack.addArrangedSubview(commentButton)
        commentStack.addArrangedSubview(commentCountLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
    }
    override func configureLayout() {
        tempTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(tempTitleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
        }
        heartStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(tempTitleLabel)
            make.bottom.equalTo(tempLabel)
        }
        commentStack.snp.makeConstraints { make in
            make.trailing.equalTo(heartStack.snp.leading).offset(-10)
            make.verticalEdges.equalTo(heartStack)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.greaterThanOrEqualTo(24)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }
    override func configureView() {
        heartStack.axis = .vertical
        heartStack.spacing = 0
        heartStack.alignment = .center
        heartStack.distribution = .equalSpacing
        heartCountLabel.font = .caption
        
        commentStack.axis = .vertical
        commentStack.spacing = 0
        commentStack.alignment = .center
        commentStack.distribution = .equalSpacing
        commentCountLabel.font = .caption
        let commentImage = UIImage(systemName: "ellipsis.bubble")?.setConfiguration(font: .largeTitle)
        commentButton.setImage(commentImage, for: .normal)
        
        tempTitleLabel.text = "이 날의 온도"
        tempTitleLabel.font = .caption
        tempLabel.font = .boldTitle
        contentLabel.font = .body
        contentLabel.numberOfLines = 0
        dateLabel.textColor = .gray
        dateLabel.font = .caption
    }
    
    func configureCell(item: PostModel) {
        contentLabel.text = item.content1
        dateLabel.text = item.createdAt.dateFormatString()
        tempLabel.text = item.temp
        heartCountLabel.text = "\(item.likes.count)"
        commentCountLabel.text = "\(item.comments.count)"
        let dontLikeImage = UIImage(systemName: "heart")?.setConfiguration(font: .largeTitle)
        let likeImage = UIImage(systemName: "heart.fill")?.setConfiguration(font: .largeTitle)
        item.likes.contains(UserDefaultsManager.userId) ? heartButton.setImage(likeImage, for: .normal) : heartButton.setImage(dontLikeImage, for: .normal)
    }
}

