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
        
        XCTAssertEqual(fret.scale(frequency: 100), 100)
        XCTAssertEqual(fret.origin(of: 100), 100)
    }
    
    func testFret5() {
        let fret: Fret = .fret5
        
        XCTAssertEqual(fret.scale(frequency: 100), 150)
        XCTAssertEqual(fret.origin(of: 150), 100)
    }

    
    func testFret7() {
        let fret: Fret = .fret7
        
        XCTAssertEqual(fret.scale(frequency: 100), 170)
        XCTAssertEqual(fret.origin(of: 170), 100)
    }
    
    func testFret12() {
        let fret: Fret = .fret12
        
        XCTAssertEqual(fret.scale(frequency: 100), 200)
        XCTAssertEqual(fret.origin(of: 200), 100)
    }
}
