//
//  FilterTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/31/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class FilterTests: XCTestCase {
    func testFilterStates() {
        XCTAssertNotEqual(Filter.allFilters.count, 0)
    }
}
