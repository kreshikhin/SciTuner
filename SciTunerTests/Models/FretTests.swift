//
//  FretTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/11/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class FretTests: XCTestCase {
    func testOpenString() {
        let fret: Fret = .openStrings
        
        XCTAssertEqual(fret.shiftUp(frequency: 100), 100)
        XCTAssertEqual(fret.shiftDown(frequency: 100), 100)
    }
    
    func testFret5() {
        let fret: Fret = .fret5
        
        XCTAssertEqualWithAccuracy(fret.shiftUp(frequency: 100), 133, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(fret.shiftDown(frequency: 133), 100, accuracy: 0.5)
    }

    
    func testFret7() {
        let fret: Fret = .fret7
        
        XCTAssertEqualWithAccuracy(fret.shiftUp(frequency: 100), 150, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(fret.shiftDown(frequency: 150), 100, accuracy: 0.5)
    }
    
    func testFret12() {
        let fret: Fret = .fret12
        
        XCTAssertEqual(fret.shiftUp(frequency: 100), 200)
        XCTAssertEqual(fret.shiftDown(frequency: 200), 100)
    }
}
