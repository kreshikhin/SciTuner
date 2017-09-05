//
//  String+LocalizedTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/5/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class String_LocalizedTests: XCTestCase {
    func testExample() {
        XCTAssertEqual("test string".localized(), "localized test string")
    }
}
