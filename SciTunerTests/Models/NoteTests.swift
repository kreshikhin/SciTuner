//
//  NoteTests.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/10/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest

class NoteTests: XCTestCase {
    func testInitWithString() {
        let note = Note("d#4")
        XCTAssertEqual(note.octave, 4)
        XCTAssertEqual(note.semitone, 3)
    }
    
    func testInitWithUppercasedString() {
        let note = Note("D#4")
        XCTAssertEqual(note.octave, 4)
        XCTAssertEqual(note.semitone, 3)
    }
    
    func testInitWithOctaveAndSemitones() {
        let note = Note(octave: 4, semitone: 3)
        XCTAssertEqual(note.string, "d#4")
    }
}
