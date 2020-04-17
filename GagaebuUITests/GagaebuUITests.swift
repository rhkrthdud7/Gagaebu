//
//  GagaebuUITests.swift
//  GagaebuUITests
//
//  Created by Soso on 17/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import XCTest

class GagaebuUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        snapshot("01ListScreen")
        app.navigationBars["List"].buttons["추가"].tap()
        snapshot("02ItemScreen")
        app.navigationBars["New"].buttons["List"].tap()
        app.tabBars.children(matching: .button).element(boundBy: 1).tap()
        snapshot("03SettingScreen")
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
