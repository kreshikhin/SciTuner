//
//  InstrumentTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/31/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class InstrumentTests: XCTestCase {
    func testAll() {
        XCTAssertNotEqual(Instrument.all.count, 0)
    }
    
    func testTunings() {
        for instrument in Instrument.all {
            XCTAssertNotEqual(instrument.tunings().count, 0)
        }
    }
}
