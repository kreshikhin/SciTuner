//
//  SmoothingTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/30/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class SmoothingTests: XCTestCase {
    func testMedianFilter() {
        let filter = Smoothing.createMedianFilter(n: 5)
        let result = [0, 0, 5, 1, 1, 1].map{ filter($0) }
        
        XCTAssertEqual(result, [0, 0, 0, 1, 1, 1])
    }
    
    func testLowPassFilter() {
        let filter = Smoothing.createLowpassFilter(cutoff: 0.5, resonance: 1.1)
        let result = [0, 0, 10, 0, 0, 0].map{ filter($0) }
        
        XCTAssertEqual(result.map{ ($0 * 10).rounded() / 10}, [0, 0, 3.3, 6.6, 2.2, -2.1])
    }
    
    func testSmoothing() {
        let smoothing = Smoothing(n: 5, cutoff: 0.5, resonance: 1.1)
        let result = [0, 0, 10, 1, 1, 1].map{ smoothing.handle(x: $0) }
        
        XCTAssertEqual(result.map{ ($0 * 10).rounded() / 10}, [0, 0, 0, 0.3, 1.0, 1.2])
    }
}
