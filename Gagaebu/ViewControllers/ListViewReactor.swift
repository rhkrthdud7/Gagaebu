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
        case refresh(Transaction)
    }

    enum Mutation {
        case setItems([Item])
        case setTransaction(Transaction)
    }

    struct State {
        var items: [Item] = []
        var transaction: Transaction = .outcome
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh(let transaction):
            let update = Observable.just(Mutation.setTransaction(transaction))
            let set = itemService.fetchItems(.transaction(transaction))
                .map { Mutation.setItems($0) }
            return Observable.concat([set, update])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setItems(let items):
            newState.items = items
        case .setTransaction(let transaction):
            newState.transaction = transaction
        }
        return newState
    }

}
