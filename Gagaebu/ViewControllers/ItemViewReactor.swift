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
    case new
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
        case .new:
            self.initialState = State(title: "New", buttonTitle: "추가")
        case .edit(let item):
            self.initialState = State(title: "Edit", buttonTitle: "수정", itemTitle: item.title, itemCost: item.cost, itemDate: item.date, isSubmitButtonEnabled: true)
        }
    }

    enum Action {
        case updateDate(Date)
        case updateCost(String)
        case updateTitle(String)
        case pressSubmit
    }

    enum Mutation {
        case setDate(Date)
        case setCost(String)
        case setTitle(String)
        case pop
    }

    struct State {
        var title: String
        var buttonTitle: String
        var itemTitle: String
        var itemCost: Int
        var itemDate: Date
        var isSubmitButtonEnabled: Bool
        var shouldPop: Bool

        init(
            title: String,
            buttonTitle: String,
            itemTitle: String = "",
            itemCost: Int = 0,
            itemDate: Date = Date(),
            isSubmitButtonEnabled: Bool = false
        ) {
            self.title = title
            self.buttonTitle = buttonTitle
            self.itemTitle = itemTitle
            self.itemCost = itemCost
            self.itemDate = itemDate
            self.isSubmitButtonEnabled = isSubmitButtonEnabled
            self.shouldPop = false
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateTitle(let title):
            return Observable.just(Mutation.setTitle(title))
        case .updateCost(let cost):
            return Observable.just(Mutation.setCost(cost))
        case .updateDate(let date):
            return Observable.just(Mutation.setDate(date))
        case .pressSubmit:
            switch mode {
            case .new:
                return itemService
                    .create(title: currentState.itemTitle, cost: currentState.itemCost, date: currentState.itemDate)
                    .map { Mutation.pop }
            case .edit(let item):
                return itemService
                    .update(id: item.id, title: currentState.itemTitle, cost: currentState.itemCost, date: currentState.itemDate)
                    .map { Mutation.pop }
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
        case .pop:
            newState.shouldPop = true
        }
        newState.isSubmitButtonEnabled = !newState.itemTitle.isEmpty && newState.itemCost != 0
        return newState
    }

}
