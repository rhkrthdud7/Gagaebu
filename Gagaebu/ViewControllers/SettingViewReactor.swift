//
//  SettingViewReactor.swift
//  Gagaebu
//
//  Created by Soso on 12/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

final class SettingViewReactor: Reactor {
    let initialState: State

    init() {
        let items: [SettingItem] = [
            .appstore(SettingItemCellReactor(title: "Rate App")),
            .acknowledgements(SettingItemCellReactor(title: "Acknowledgements")),
            .version(SettingItemCellReactor(title: "Version", detail: AppInfo.shared.appVersion))
        ]
        self.initialState = State(items: items)
    }

    enum Action {
    }

    enum Mutation {
    }

    struct State {
        var items: [SettingItem]
    }
}
