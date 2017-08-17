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
    
    var octave: Int
    var semitone: Int
    
    var number: Int {
        get { return 12 * octave + semitone }
    }
    
    var string: String {
        get { return Self.semitoneNames[semitone] + String(octave) }
    }
    
    var description: String { return string }
    
    init(octave: Int, semitone: Int) {
        self.octave = octave
        self.semitone = semitone
    }
    
    init(_ name: String) {
        let lowercased = name.lowercased().trimmingCharacters(in: .whitespaces)
        octave = 0
        semitone = 0
        
        for (i, n) in Self.semitoneNames.enumerated() {
            if lowercased.hasPrefix(n) { semitone = i }
        }
        
        for i in 0...8 {
            if lowercased.hasSuffix(String(i)) { octave = i }
        }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.octave <= rhs.octave && lhs.semitone < rhs.semitone
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.octave == rhs.octave && lhs.semitone == rhs.semitone
    }
}
