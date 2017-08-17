//
//  Pitch.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/10/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

enum Pitch: String {
    typealias `Self` = Pitch
    
    case standard = "standard_pitch"
    case scientific = "scientific_pitch"
    
    static let allPitches: [Pitch] = [.standard, .scientific]
    
    func noteAndFrequency() -> (Note, Double) {
        switch self {
        case .standard: return (Note("a4"), 440)
        case .scientific: return (Note("c4"), 256)
        }
    }
    
    func localized() -> String {
        return self.rawValue.localized()
    }
    
    func index() -> Int? {
        return Self.allPitches.index(of: self)
    }
    
    func frequency(of note: Note) -> Double {
        let (baseNote, baseFrequency) = self.noteAndFrequency()
        let (b, n) = (baseNote.number, note.number)
        
        return baseFrequency * pow(2.0, Double(n - b) / 12.0);
    }
    
    func notePosition(with frequency: Double) -> Double {
        let (baseNote, baseFrequency) = self.noteAndFrequency()
        let b = baseNote.number
        
        return 12.0 * log(frequency / baseFrequency) / log(2) + Double(b)
    }
    
    //func note(with frequency: Double) -> Note {
    //}
}
