//
//  FretsAlertControllerTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/3/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class FretsAlertControllerTests: XCTestCase {
        
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
    
    func testShowFrets() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        
        if app.buttons["tune on fret"].exists {
            app.buttons["tune on fret"].tap()
        } else if app.buttons["5th fret"].exists {
            app.buttons["5th fret"].tap()
        } else if app.buttons["7th fret"].exists {
            app.buttons["7th fret"].tap()
        } else if app.buttons["12th fret"].exists {
            app.buttons["12th fret"].tap()
        }
        
        app.sheets.buttons["5th fret"].tap()
        XCTAssert(app.buttons["5th fret"].exists)
        app.buttons["5th fret"].tap()
        
        app.sheets.buttons["7th fret"].tap()
        XCTAssert(app.buttons["7th fret"].exists)
        app.buttons["7th fret"].tap()
        
        app.sheets.buttons["12th fret"].tap()
        XCTAssert(app.buttons["12th fret"].exists)
        app.buttons["12th fret"].tap()
        
        app.sheets.buttons["open strings"].tap()
        XCTAssert(app.buttons["tune on fret"].exists)
        app.buttons["tune on fret"].tap()
        
        app.sheets.buttons["cancel"].tap()
    }
    
}
