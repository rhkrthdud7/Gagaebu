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
        var totalIncome: Int = 0
        var totalOutcome: Int = 0
        var isEmptyLabelHidden: Bool = true
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh(let transaction):
            let update = Observable.just(Mutation.setTransaction(transaction))
            let set = itemService.fetchItems(nil)
                .map { Mutation.setItems($0) }
            return Observable.concat([update, set])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setItems(let items):
            let income = items.filter { $0.transaction == Transaction.income }
            let outcome = items.filter { $0.transaction == Transaction.outcome }
            if newState.transaction == .income {
                newState.items = income
            } else {
                newState.items = outcome
            }
            newState.totalIncome = income.map({ $0.cost }).reduce(0, +)
            newState.totalOutcome = outcome.map({ $0.cost }).reduce(0, +)
            newState.isEmptyLabelHidden = !items.isEmpty
        case .setTransaction(let transaction):
            newState.transaction = transaction
        }
        return newState
    }

}
