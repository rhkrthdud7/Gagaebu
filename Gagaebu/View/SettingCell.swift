//
//  SettingCell.swift
//  Gagaebu
//
//  Created by Soso on 17/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import ReactorKit
import Then

class SettingCell: BaseTableViewCell, View {
    let labelTitle = UILabel()
    let labelDetail = UILabel()

    override func initialize() {
        selectionStyle = .none

        addSubview(labelTitle)
        labelTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        addSubview(labelDetail)
        labelDetail.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }

    func bind(reactor: SettingItemCellReactor) {
        reactor.state.map { $0.title }
            .bind(to: labelTitle.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.detail }
            .bind(to: labelDetail.rx.text)
            .disposed(by: disposeBag)
    }

}
