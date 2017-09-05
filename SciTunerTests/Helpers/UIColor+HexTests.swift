//
//  UIColor+HexTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/5/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class UIColor_HexTests: XCTestCase {
    func testExample() {
        let result = CIColor(color: UIColor(hex: 0xFF8000))
        let orange = CIColor(color: UIColor.orange)
        
        XCTAssertEqualWithAccuracy(result.red, orange.red, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(result.green, orange.green, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(result.blue, orange.blue, accuracy: 0.01)
    }
}
