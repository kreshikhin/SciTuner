//
//  Note.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/10/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

struct Note: Comparable, CustomStringConvertible{
    typealias `Self` = Note
    static let semitoneNames = ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"]
    
    var number: Int = 0
    
    var octave: Int { return number / 12 }
    var semitone: Int { return number % 12 }
    
    var string: String {
        get { return Self.semitoneNames[semitone] + String(octave) }
    }
    
    var description: String { return string }

    init(number: Int) {
        self.number = number
    }
    
    init(octave: Int, semitone: Int) {
        number = 12 * octave + semitone
    }
    
    init(_ name: String) {
        let lowercased = name.lowercased().trimmingCharacters(in: .whitespaces)
        var semitone = 0
        var octave = 0
        
        for (i, n) in Self.semitoneNames.enumerated() {
            if lowercased.hasPrefix(n) { semitone = i }
        }
        
        for i in 0...8 {
            if lowercased.hasSuffix(String(i)) { octave = i }
        }
        
        number = 12 * octave + semitone
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.number <= rhs.number
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.number == rhs.number
    }
    
    static func + (lhs: Self, rhs: Int) -> Note {
        return Note(number: lhs.number + rhs)
    }
}
