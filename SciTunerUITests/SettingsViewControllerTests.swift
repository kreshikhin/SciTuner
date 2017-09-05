//
//  SettingsViewControllerTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/5/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class SettingsViewControllerTests: XCTestCase {
        
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
    
    func testPitchChange() {
        let app = XCUIApplication()
        app.navigationBars["SciTuner"].buttons["settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Default A4=440Hz"].tap()
        tablesQuery.staticTexts["Scientific C4=256Hz"].tap()
    }
    
}
