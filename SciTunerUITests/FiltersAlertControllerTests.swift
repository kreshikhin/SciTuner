//
//  FiltersAlertControllerTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/2/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class FiltersAlertControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowFilters() {
        let app = XCUIApplication()
        
        if app.buttons["filter: off"].exists {
            app.buttons["filter: off"].tap()
        } else if app.buttons["filter: on"].exists {
            app.buttons["filter: on"].tap()
        }
        
        app.sheets.buttons["cancel"].tap()
    }
    
    func testSetFilterOn() {
        let app = XCUIApplication()
        
        if app.buttons["filter: off"].exists {
            app.buttons["filter: off"].tap()
        } else if app.buttons["filter: on"].exists {
            app.buttons["filter: on"].tap()
        }
        
        app.sheets.buttons["on"].tap()
        XCTAssert(app.buttons["filter: on"].exists)
    }
    
    func testSetFilterOff() {
        let app = XCUIApplication()
        
        if app.buttons["filter: off"].exists {
            app.buttons["filter: off"].tap()
        } else if app.buttons["filter: on"].exists {
            app.buttons["filter: on"].tap()
        }
        
        app.sheets.buttons["off"].tap()
        XCTAssert(app.buttons["filter: off"].exists)
    }
    
}
