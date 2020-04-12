//
//  ItemViewReactor.swift
//  Gagaebu
//
//  Created by Soso on 05/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

enum ItemMode {
    case new(Transaction)
    case edit(Item)
}

final class ItemViewReactor: Reactor {
    let initialState: State
    let itemService: ItemServiceType
    let mode: ItemMode

    init(itemService: ItemServiceType, mode: ItemMode) {
        self.itemService = itemService
        self.mode = mode

        switch mode {
        case .new(let transaction):
            self.initialState = State(title: "New", buttonTitle: "추가", transaction: transaction)
        case .edit(let item):
            self.initialState = State(title: "Edit", buttonTitle: "수정", itemTitle: item.title, itemCost: item.cost, itemDate: item.date, transaction: item.transaction, isSubmitButtonEnabled: true, isDeleteButtonHidden: false)
        }
    }

    enum Action {
        case updateTitle(String)
        case updateCost(String)
        case updateDate(Date)
        case updateTransaction(Transaction)
        case pressSubmit
        case pressDelete
    }

    enum Mutation {
        case setTitle(String)
        case setCost(String)
        case setDate(Date)
        case setTransaction(Transaction)
        case pop
    }

    struct State {
        var title: String
        var buttonTitle: String
        var itemTitle: String
        var itemCost: Int
        var itemDate: Date
        var transaction: Transaction
        var isSubmitButtonEnabled: Bool
        var isDeleteButtonHidden: Bool
        var shouldPop: Bool

        init(
            title: String,
            buttonTitle: String,
            itemTitle: String = "",
            itemCost: Int = 0,
            itemDate: Date = Date(),
            transaction: Transaction,
            isSubmitButtonEnabled: Bool = false,
            isDeleteButtonHidden: Bool = true
        ) {
            self.title = title
            self.buttonTitle = buttonTitle
            self.itemTitle = itemTitle
            self.itemCost = itemCost
            self.itemDate = itemDate
            self.isSubmitButtonEnabled = isSubmitButtonEnabled
            self.isDeleteButtonHidden = isDeleteButtonHidden
            self.shouldPop = false
            self.transaction = transaction
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateTitle(let title):
            return .just(Mutation.setTitle(title))
        case .updateCost(let cost):
            return .just(Mutation.setCost(cost))
        case .updateDate(let date):
            return .just(Mutation.setDate(date))
        case .updateTransaction(let transaction):
            return .just(Mutation.setTransaction(transaction))
        case .pressSubmit:
            switch mode {
            case .new:
                return itemService
                    .create(currentState.itemTitle, currentState.itemCost, currentState.itemDate, currentState.transaction)
                    .map { Mutation.pop }
            case .edit(let item):
                return itemService
                    .update(item.id, currentState.itemTitle, currentState.itemCost, currentState.itemDate, currentState.transaction)
                    .map { Mutation.pop }
            }
        case .pressDelete:
            if case let .edit(item) = self.mode {
                return itemService
                    .delete(item.id)
                    .map { Mutation.pop }
            } else {
                return .empty()
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setTitle(let title):
            newState.itemTitle = title
        case .setCost(let cost):
            if let cost = Int(cost) {
                newState.itemCost = cost
            } else {
                newState.itemCost = 0
            }
        case .setDate(let date):
            newState.itemDate = min(date, Date())
        case .setTransaction(let transaction):
            newState.transaction = transaction
        case .pop:
            newState.shouldPop = true
        }
        newState.isSubmitButtonEnabled = !newState.itemTitle.isEmpty && newState.itemCost != 0
        return newState
    }

}
