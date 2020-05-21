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
        case previous
        case next
    }

    enum Mutation {
        case setItems([Item])
        case setTransaction(Transaction)
        case setCurrentYearMonth(Int, Int)
    }

    struct State {
        var year: Int
        var month: Int
        var items: [Item] = []
        var transaction: Transaction = .outcome
        var totalIncome: Int = 0
        var totalOutcome: Int = 0
        var isEmptyLabelHidden: Bool = true

        init() {
            let calendar = Calendar(identifier: .gregorian)
            let date = Date()
            year = calendar.component(.year, from: date)
            month = calendar.component(.month, from: date)
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh(let transaction):
            let set = getItems(current: selectedMonth(year: currentState.year, month: currentState.month))
            let transaction = Observable
                .just(Mutation.setTransaction(transaction))
            return Observable
                .concat([transaction, set])
        case .previous:
            let previous = previousMonth()
            let set = getItems(current: selectedMonth(year: previous.0, month: previous.1))
            let yearMonth = Observable
                .just(Mutation.setCurrentYearMonth(previous.0, previous.1))
            return Observable.concat([set, yearMonth])
        case .next:
            let next = nextMonth()
            let set = getItems(current: selectedMonth(year: next.0, month: next.1))
            let yearMonth = Observable
                .just(Mutation.setCurrentYearMonth(next.0, next.1))
            return Observable.concat([set, yearMonth])
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
            newState.isEmptyLabelHidden = !newState.items.isEmpty
        case .setTransaction(let transaction):
            newState.transaction = transaction
        case .setCurrentYearMonth(let year, let month):
            newState.year = year
            newState.month = month
        }
        return newState
    }
    
    func getItems(current: Date) -> Observable<Mutation> {
        let start = current.startOfMonth
        let end = current.endOfMonth
        return itemService.fetchItems(.period(start, end))
            .map { Mutation.setItems($0) }
    }

    func previousMonth() -> (Int, Int) {
        var newMonth = currentState.month - 1
        var newYear = currentState.year
        if newMonth < 1 {
            newMonth = 12
            newYear -= 1
        }
        return (newYear, newMonth)
    }

    func nextMonth() -> (Int, Int) {
        var newMonth = currentState.month + 1
        var newYear = currentState.year
        if newMonth > 12 {
            newMonth = 1
            newYear += 1
        }
        return (newYear, newMonth)
    }

    func selectedMonth(year: Int, month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month)
        return calendar.date(from: components)!
    }

}
