//
//  GagaebuTests.swift
//  GagaebuTests
//
//  Created by Soso on 15/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import XCTest
@testable import Gagaebu

class GagaebuTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testItemViewReactor() {
        let itemService = ItemService()
        let reactor = ItemViewReactor(itemService: itemService, mode: .new(.outcome))

        XCTAssertEqual(reactor.currentState.isDeleteButtonHidden, true)

        XCTAssertEqual(reactor.currentState.isSubmitButtonEnabled, false)

        let title = "This is a test"
        reactor.action.onNext(.updateTitle(title))
        XCTAssertEqual(reactor.currentState.itemTitle, title)

        reactor.action.onNext(.updateCost("0000010"))
        XCTAssertEqual(reactor.currentState.itemCost, 10)

        let date = Date()
        reactor.action.onNext(.updateDate(date))
        XCTAssertEqual(reactor.currentState.itemDate, date)
    }

    func testListViewReactor() {
        let itemService = ItemService()
        let reactor = ListViewReactor(itemService: itemService)

        reactor.action.onNext(.refresh(.income))
        XCTAssertEqual(reactor.currentState.transaction, Transaction.income)

        reactor.action.onNext(.refresh(.outcome))
        XCTAssertEqual(reactor.currentState.transaction, Transaction.outcome)
    }

}
