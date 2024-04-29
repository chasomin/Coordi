//
//  BaseTableViewCell.swift
//  Coordi
//
//  Created by 차소민 on 4/30/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    static var id: String {
        return self.description()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureView()
        contentView.backgroundColor = .backgroundColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() { }
    func configureLayout() { }
    func configureView() { }
}
