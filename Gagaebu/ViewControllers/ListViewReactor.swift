//
//  ListViewReactor.swift
//  Gagaebu
//
//  Created by Soso on 05/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxRelay
import RealmSwift

final class ListViewReactor: Reactor {
    let initialState = State()
    let itemService: ItemServiceType

    init(itemService: ItemServiceType) {
        self.itemService = itemService
    }

    enum Action {
        case refresh
    }

    enum Mutation {
        case setItems([Item])
    }

    struct State {
        var items: [Item] = []
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return itemService.fetchItems()
                .map { Mutation.setItems($0) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setItems(let items):
            newState.items = items
        }
        return newState
    }

}
