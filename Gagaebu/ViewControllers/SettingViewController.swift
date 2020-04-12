//
//  SettingViewController.swift
//  Gagaebu
//
//  Created by Soso on 12/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift

class SettingViewController: BaseViewController, View {

    init(reactor: SettingViewReactor) {
        super.init()

        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Setting"
        view.backgroundColor = .systemBackground
    }
    
    func bind(reactor: SettingViewReactor) {
        
    }
}
