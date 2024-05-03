//
//  SettingTableViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/30/24.
//

import UIKit
import SnapKit

final class SettingTableViewCell: BaseTableViewCell {
    let title = UILabel()
    let icon = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(icon)
        contentView.addSubview(title)
    }
    
    override func configureLayout() {
        icon.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview().inset(15)
            make.width.equalTo(icon.snp.height)
        }
        
        title.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(5)
            make.verticalEdges.equalToSuperview().inset(15)
        }
    }
}
