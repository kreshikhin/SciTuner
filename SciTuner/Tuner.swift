//
//  Tuner.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 28.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation

class Tuner {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    class var sharedInstance: Tuner {
        struct Static {
            static var instance: Tuner?
            static var token: dispatch_once_t = 0
        }

        dispatch_once(&Static.token) {
            Static.instance = Tuner()
        }

        return Static.instance!
    }

    var bindings: [String:[()->Void]] = [:]
    
    func on(name: String, _ callback: ()->Void){
        if bindings[name] != nil {
            bindings[name]! += [callback]
        } else {
            bindings[name] = [callback]
        }
    }
    
    func call(name: String) {
        var callbacks = bindings[name]
        if callbacks == nil {
            return
        }
        
        for callback in callbacks! {
            callback()
        }
    }
    
    var instrument: String = "guitar"
    var tunings: [String] = []
    var tuningStrings: [[String]] = []
    var tuningIndex: Int = 0
    var strings: [String] = []
    var stringIndex: Int = 0
    var string: String = "e2"
    var notes: [String] = []
    var frequency: Double = 440
    var baseFrequency: Double = 440
    var baseNote: String = "a4"
    var fret: Int = 0
    var isPaused = false;
    let pitchs: [String] = ["Default A4=440Hz", "Scientific C4=256Hz"]
    let pitchValues: [String] = ["default", "scientific"]
    var pitchIndex: Int = 0
    var pitch: String = "default"
    var instruments: [String: [(title: String, strings: [String])]] = [:]
    
    func setInstrument(value: String){
        if instruments[value] == nil {
            return
        }
        
        instrument = value
        defaults.setValue(instrument, forKey: "instrument")
        
        tunings = []
        tuningStrings = []
        for tuning in instruments[instrument]! {
            tunings.append(tuning.title)
            tuningStrings.append(tuning.strings)
        }
        
        var defaultTuning: Int? = defaults.integerForKey(instrument)
        if defaultTuning != nil {
            setTuningIndex(defaultTuning!)
        }else{
            setTuningIndex(0)
        }
        
        
        call("instrumentChange")
    }
    
    func setTuningIndex(value: Int) {
        defaults.setInteger(value, forKey: instrument)
        tuningIndex = value
        strings = tuningStrings[tuningIndex]
        
        setStringIndex(stringIndex)
        
        call("tuningChange")
    }

    func setStringIndex(value: Int) {
        if value < 0 {
            stringIndex = 0
        } else if value >= strings.count {
            stringIndex = strings.count - 1
        } else {
            stringIndex = value
        }
        
        defaults.setInteger(stringIndex, forKey: "stringIndex")
        string = strings[stringIndex]
        
        var n = Double(noteNumber(string))
        notes = [noteString(n-1.0), noteString(n), noteString(n+1.0)]
        
        call("stringChange")
    }
    
    func setPitchIndex(value: Int) {
        defaults.setInteger(value, forKey: "pitchIndex")
        pitchIndex = value
        pitch = pitchValues[pitchIndex]
        
        if pitch == "scientific" {
            baseFrequency = 256.0
            baseNote = "c4"
            return
        }
        
        baseFrequency = 440.0
        baseNote = "a4"
        
        call("pitchChange")
    }
    
    func setFrequency(value: Double){
        frequency = value
        call("frequencyChange")
    }

    init(){
        addInstrument("guitar", [
            ("Standard", "e2 a2 d3 g3 b3 e4"),
            ("New Standard", "c2 g2 d3 a3 e4 g4"),
            ("Russian", "d2 g2 b2 d3 g3 b3 d4"),
            ("Drop D", "d2 a2 d3 g3 b3 e4"),
            ("Drop C", "c2 g2 c3 f3 a3 d4"),
            ("Drop G", "g2 d2 g3 c4 e4 a4"),
            ("Open D", "d2 a2 d3 f#3 a3 d4"),
            ("Open C", "c2 g2 c3 g3 c4 e4"),
            ("Open G", "g2 g3 d3 g3 b3 d4"),
            ("Lute", "e2 a2 d3 f#3 b3 e4"),
            ("Irish", "d2 a2 d3 g3 a3 d4")
        ])

        addInstrument("cello", [
            ("Standard", "c2 g2 d3 a3"),
            ("Alternative", "c2 g2 d3 g3")
        ])

        addInstrument("violin", [
            ("Standard", "g3 d4 a4 e5"),
            ("Tenor", "g2 d3 a3 e4"),
            ("Tenor alter.", "f2 c3 g3 d4")
        ])

        addInstrument("banjo", [
            ("Standard", "g4 d3 g3 b3 d4")
        ])
        
        addInstrument("balalaika", [
            ("Standard", "g4 d3 g3 b3 d4")
        ])

        addInstrument("ukulule", [
            ("Standard", "g4 c4 e4 a4"),
            ("D-tuning", "a4 d4 f#4 b4")
        ])
        
        addInstrument("free mode", [
            ("Octaves", "c2 c3 c4 c5 c6"),
            ("C-major", "c3 d3 e3 f3 g3 a3 b3"),
            ("C-minor", "c3 d3 e3 f3 g3 a3 b3")
        ])
        
        if defaults.stringForKey("instrument") != nil {
            var value: String? = defaults.stringForKey("instrument")
            setInstrument(value!)
        } else {
            setInstrument("guitar")
        }
        
        setTuningIndex(defaults.integerForKey(instrument))
        setStringIndex(defaults.integerForKey("stringIndex"))
        setPitchIndex(defaults.integerForKey("pitchIndex"))
    }

    func addInstrument(name: String, _ tunings: [(String, String)]){
        var result: [(title: String, strings: [String])] = []
        
        for (title, strings) in tunings {
            var splitStrings: [String] = split(strings) {$0 == " "}
            var titleStrings: String = join(" ", splitStrings.map({(note: String) -> String in
                return note.stringByReplacingOccurrencesOfString("#", withString: "♯", options: NSStringCompareOptions.LiteralSearch, range: nil).uppercaseString
            }))
            result += [(title: title + " (" + titleStrings + ")", strings: splitStrings)]
        }
        
        instruments[name] = result
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

    func noteString(num: Double) -> String {
        var noteOctave: Int = Int(num / 12)
        var noteShift: Int = Int(num % 12)

        var result = ""
        switch noteShift {
            case 0: result += "c"
            case 1: result += "c#"
            case 2: result += "d"
            case 3: result += "d#"
            case 4: result += "e"
            case 5: result += "f"
            case 6: result += "f#"
            case 7: result += "g"
            case 8: result += "g#"
            case 9: result += "a"
            case 10: result += "a#"
            case 11: result += "b"
            default: result += ""
        }

        return result + String(noteOctave)
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
        return noteFrequency(string)
    }

    func frequencyDeviation() -> Double {
        return 100.0 * frequencyDistanceNumber(targetFrequency(), frequency)
    }

    func stringPosition() -> Double {
        var first = noteFrequency(strings.first!)
        var last = noteFrequency(strings.last!)

        return Double(strings.count - 1) * (frequency - first) / (last - first)
    }

    func nextString() {
        setStringIndex(stringIndex+1)
    }

    func prevString() {
        setStringIndex(stringIndex-1)
    }
}
