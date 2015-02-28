//
//  Tuner.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 28.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation

class Tuner {
    var shift: Int = 0
    var strings: [String] = ["e2", "a2", "b3", "g3", "d3", "e4"]
    var notes: [String] = ["d#4", "e4", "f4"]
    
    var frequency: Double = 440
    
    var baseFrequency: Double = 440
    var baseNote: String = "a4"
    
    var targetNote: String = "a4"
    
    init(){
    }
    
    func getNotePosition(){
    }
    
    func noteNumber(noteString: String) -> Int {
        var note = noteString.lowercaseString
        var number = 0
        var octave = 0
        
        if note.hasPrefix("c") { number = 0; }
        if note.hasPrefix("c#") { number = 1; }
        if note.hasPrefix("d") { number = 2; }
        if note.hasPrefix("d#") { number = 3; }
        if note.hasPrefix("e") { number = 4; }
        if note.hasPrefix("f") { number = 5; }
        if note.hasPrefix("f#") { number = 6; }
        if note.hasPrefix("g") { number = 7; }
        if note.hasPrefix("g#") { number = 8; }
        if note.hasPrefix("a") { number = 9; }
        if note.hasPrefix("a#") { number = 10; }
        if note.hasPrefix("b") { number = 11; }
        
        if note.hasSuffix("0") { octave = 0; }
        if note.hasSuffix("1") { octave = 1; }
        if note.hasSuffix("2") { octave = 2; }
        if note.hasSuffix("3") { octave = 3; }
        if note.hasSuffix("4") { octave = 4; }
        if note.hasPrefix("5") { octave = 5; }
        if note.hasPrefix("6") { octave = 6; }
        if note.hasPrefix("7") { octave = 7; }
        if note.hasPrefix("8") { octave = 8; }
        
        return 12 * octave + number
    }
    
    func noteFrequency(noteString: String) -> Double {
        var n = noteNumber(noteString)
        var b = noteNumber(baseNote)
        
        return baseFrequency * pow(2.0, Double(n - b) / 12.0);
    }
    
    func frequencyNumber(f: Double) -> Double {
        var b = noteNumber(baseNote);
        
        return 12.0 * log(f / baseFrequency) / log(2) + Double(b);
    }
    
    func frequencyDistanceNumber(f0: Double, _ f1: Double) -> Double {
        var n0 = frequencyNumber(f0)
        var n1 = frequencyNumber(f1)
        
        return n1 - n0;
    }
    
    func targetFrequency() -> Double {
        return noteFrequency(targetNote)
    }
    
    func frequencyDeviation() -> Double {
        return 100.0 * frequencyDistanceNumber(targetFrequency(), frequency)
    }
}