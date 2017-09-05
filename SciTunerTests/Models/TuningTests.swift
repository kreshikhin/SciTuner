//
//  TuningTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/31/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class TuningTests: XCTestCase {
    func testConstructor() {
        let lute = Tuning("lute", "e2 a2 d3 f#3 b3 e4")
        
        let expectedStrings = ["e2", "a2", "d3", "f#3", "b3", "e4"].map{ Note($0) }
        
        XCTAssertEqual(lute.id, "lute")
        XCTAssertEqual(lute.strings, expectedStrings)
    }
    
    func testConstructWithId() {
        let lute = Tuning(instrument: .guitar, id: "lute")
        XCTAssertEqual(lute?.id ?? "", "lute")
        
        let unknown = Tuning(instrument: .guitar, id: "unknown")
        XCTAssertEqual(unknown, nil)
    }
    
    func testStandard() {
        for i in Instrument.all {
            let tune = Tuning(standard: i)
            XCTAssertNotNil(tune)
            if tune.id == "octaves" { continue }
            if tune.id == "standard_prima" { continue }
            XCTAssertEqual(tune.id, "standard")
        }
    }
    
    func testIndex() {
        for i in Instrument.all {
            let tune = Tuning(standard: i)
            let index = tune.index(instrument: i)
            XCTAssertEqual(index, 0)
        }
        
        
        let lute = Tuning(instrument: .guitar, id: "lute")
        XCTAssertEqual(lute?.index(instrument: .guitar) ?? 0, 9)
        
        
        let cello = Tuning(instrument: .cello, id: "lute")
        XCTAssertNil(cello?.index(instrument: .cello))
    }
    
    func testCompare() {
        let standard = Tuning(instrument: .guitar, id: "standard")
        let standard2 = Tuning(instrument: .guitar, id: "standard")
        let lute = Tuning(instrument: .guitar, id: "lute")
        
        XCTAssertNotNil(standard)
        XCTAssertNotNil(standard2)
        XCTAssertNotNil(lute)
        
        XCTAssertEqual(standard, standard2)
        XCTAssertNotEqual(standard, lute)
    }
}
