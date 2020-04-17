//
//  SettingSection.swift
//  Gagaebu
//
//  Created by Soso on 17/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import ReactorKit

enum SettingItem {
    case acknowledgements(SettingItemCellReactor)
    case version(SettingItemCellReactor)
}

class SettingItemCellReactor: Reactor {
    typealias Action = NoAction

    struct State {
        var title: String
        var detail: String?
    }

    let initialState: State

    init(title: String, detail: String? = nil) {
        self.initialState = State(title: title, detail: detail)
    }
}
