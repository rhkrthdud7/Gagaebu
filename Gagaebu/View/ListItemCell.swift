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
        addSubview(labelDate)
        labelDate.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        addSubview(labelTitle)
        labelTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(10)
        }
        addSubview(labelCost)
        labelCost.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
