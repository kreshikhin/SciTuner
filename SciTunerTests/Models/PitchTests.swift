//
//  PitchTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/31/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class PitchTests: XCTestCase {
    func testScientificPitch() {
        let pitch = Pitch.scientific
        
        let (n, f) = pitch.noteAndFrequency()
        
        XCTAssertEqual(n, Note("C4"))
        XCTAssertEqual(f, 256)
    }
    
    func testStandardPitch() {
        let pitch = Pitch.standard
        
        let (n, f) = pitch.noteAndFrequency()
        
        XCTAssertEqual(n, Note("A4"))
        XCTAssertEqual(f, 440)
    }
    
    func testFrequency() {
        let f = Pitch.scientific.frequency(of: Note("C5"))
        XCTAssertEqual(f, 512)
    }
    
    func testDeviation() {
        let deltaA4 = Pitch.standard.deviation(note: Note("A4"), frequency: 440)
        XCTAssertEqual(deltaA4, 0)
        
        let deltaC5diez = Pitch.scientific.deviation(note: Note("C5"), frequency: 542.4451043119592)
        XCTAssertEqualWithAccuracy(deltaC5diez, 1.0, accuracy: 0.01)
        
        let deltaC5b = Pitch.scientific.deviation(note: Note("C5"), frequency: 483.2636480930270)
        XCTAssertEqualWithAccuracy(deltaC5b, -1.0, accuracy: 0.01)
    }
    
    func testNotePosition() {
        let pitch = Pitch.scientific
        
        XCTAssertEqual(pitch.notePosition(with: 256.0), 48.0)
    }
}
