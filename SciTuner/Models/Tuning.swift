//
//  Tuning.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/10/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

struct Tuning: Equatable {
    typealias `Self` = Tuning
    
    let id: String
    let strings: [Note]
    let description: String
    
    func localized() -> String {
        return id.localized() + " (" + description + ")"
    }
    
    init(_ id: String, _ strings: String) {
        self.id = id
        
        let splitStrings: [String] = strings.characters.split {$0 == " "}.map { String($0) }
        
        self.description = splitStrings.map({(note: String) -> String in
            note.replacingOccurrences(of: "#", with: "♯")
        }).joined(separator: " ")
        
        self.strings = splitStrings.map() { (name: String) -> Note in
            return Note(name)
        }
    }
    
    init?(instrument: Instrument, id: String) {
        let tunings = instrument.tunings()
        
        guard let tuning = tunings.filter({ $0.id == id}).first else {
            return nil
        }
        
        self = tuning
    }
    
    init(standard instrument: Instrument) {
        self = instrument.tunings().first!
    }
    
    func index(instrument: Instrument) -> Int? {
        return instrument.tunings().index(of: self)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let guitarTunings = [
        Tuning("standard", "e2 a2 d3 g3 b3 e4"),
        Tuning("new_standard", "c2 g2 d3 a3 e4 g4"),
        Tuning("russian", "d2 g2 b2 d3 g3 b3 d4"),
        Tuning("drop_d", "d2 a2 d3 g3 b3 e4"),
        Tuning("drop_c", "c2 g2 c3 f3 a3 d4"),
        Tuning("drop_g", "g2 d2 g3 c4 e4 a4"),
        Tuning("open_d", "d2 a2 d3 f#3 a3 d4"),
        Tuning("open_c", "c2 g2 c3 g3 c4 e4"),
        Tuning("open_g", "g2 g3 d3 g3 b3 d4"),
        Tuning("lute", "e2 a2 d3 f#3 b3 e4"),
        Tuning("irish", "d2 a2 d3 g3 a3 d4")
    ]
    
    static let celloTunings = [
        Tuning("standard", "c2 g2 d3 a3"),
        Tuning("alternative", "c2 g2 d3 g3")
    ]
    
    static let violinTunings = [
        Tuning("standard", "g3 d4 a4 e5"),
        Tuning("tenor", "g2 d3 a3 e4"),
        Tuning("tenor_alter", "f2 c3 g3 d4")
    ]
    
    static let banjoTunings = [
        Tuning("standard", "g4 d3 g3 b3 d4")
    ]
    
    static let balalaikaTunings = [
        Tuning("standard_prima", "e4 e4 a4"),
        Tuning("bass", "e2 a2 d3"),
        Tuning("tenor", "a2 a2 e3"),
        Tuning("alto", "e3 e3 a3"),
        Tuning("secunda", "a3 a3 d4"),
        Tuning("piccolo", "b4 e5 a5")
    ]
    
    static let ukuleleTunings = [
        Tuning("standard", "g4 c4 e4 a4"),
        Tuning("d_tuning", "a4 d4 f#4 b4")
    ]
    
    static let freemodeTunings = [
        Tuning("octaves", "c2 c3 c4 c5 c6"),
        Tuning("c_major", "c3 d3 e3 f3 g3 a3 b3"),
        Tuning("c_minor", "c3 d3 e3 f3 g3 a3 b3")
    ]
}
