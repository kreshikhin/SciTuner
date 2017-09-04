//
//  InstrumentsAlertControllerTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/4/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class InstrumentsAlertControllerTests: XCTestCase {
        
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
    
    func testInstruments() {
        // Use recording to get started writing UI tests.
        
        let app = XCUIApplication()
        let scitunerNavigationBar = app.navigationBars["SciTuner"]
        
        let instruments = ["guitar", "cello", "violin", "ukulele", "balalaika", "banjo"]
        let strings = [
            "guitar": "e2 a2 d3 g3 b3 e4",
            "cello": "c2 g2 d3 a3",
            "violin": "g3 d4 a4 e5",
            "ukulele": "g4 c4 e4 a4",
            "balalaika": "e4 e4 a4",
            "banjo": "g4 d3 g3 b3 d4",
        ]
        
        // tap on the instrument button in the navigation bar
        for instrument in instruments {
            if scitunerNavigationBar.buttons[instrument].exists {
                scitunerNavigationBar.buttons[instrument].tap()
            }
        }
        
        app.sheets.buttons["guitar"].tap()
        scitunerNavigationBar.buttons["settings"].tap()
        let standard = app.tables.cells.staticTexts["Standard (e2 a2 d3 g3 b3 e4)"]
        
        XCTAssert(standard.exists)
        standard.tap()
        
        app.navigationBars["settings"].buttons["SciTuner"].tap()
        scitunerNavigationBar.buttons["guitar"].tap()
        
        for instrument in instruments {
            app.sheets.buttons[instrument].tap()
            
            XCTAssert(scitunerNavigationBar.buttons[instrument].exists)
            // check strings
            if let strings = strings[instrument] {
                for string in strings.components(separatedBy: " ") {
                    XCTAssert(app.staticTexts[string].exists)
                    print(string, "ok")
                }
            } else {
                XCTFail("can't find strings for " + instrument)
            }
            
            scitunerNavigationBar.buttons[instrument].tap()
        }
        
        XCTAssert(app.sheets.buttons["cancel"].exists)
        app.sheets.buttons["cancel"].tap()
    }
    
}
