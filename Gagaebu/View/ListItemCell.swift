//
//  ListItemCell.swift
//  Gagaebu
//
//  Created by Soso on 11/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import Then

class ListItemCell: BaseTableViewCell {
    let labelTitle = UILabel()
    let labelDate = UILabel()
    let labelCost = UILabel()

    override func initialize() {
        selectionStyle = .none
        
        let viewShadow = UIView().then {
            $0.backgroundColor = .clear
            $0.layer.applyShadow(alpha: 1, x: 0, y: 1, blur: 4, spread: 0)
        }
        addSubview(viewShadow)
        viewShadow.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        let viewContent = UIView().then {
            $0.layer.cornerRadius = 15
            $0.layer.masksToBounds = true
            $0.backgroundColor = .systemBackground
        }
        viewShadow.addSubview(viewContent)
        viewContent.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        viewContent.addSubview(labelDate)
        labelDate.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        viewContent.addSubview(labelTitle)
        labelTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(10)
        }
        viewContent.addSubview(labelCost)
        labelCost.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
