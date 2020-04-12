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
    let itemService: ItemServiceType

    init(itemService: ItemServiceType) {
        self.itemService = itemService
        self.initialState = State()
    }

    enum Action {
    }

    enum Mutation {
    }

    struct State {
    }
}
