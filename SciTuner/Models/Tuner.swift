//
//  Tuner.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 28.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation

protocol TunerDelegate: class {
    func didInstrumentChange()
    func didFrequencyChange()
    func didTuningChange()
    func didStringChange()
    func didPitchChange()
    func didFretChange()
    func didFilterChange()
    func didStatusChange()
}

class Tuner {
    weak var delegate: TunerDelegate?
    
    static let sharedInstance = Tuner()
    let defaults = UserDefaults.standard

    var bindings: [String:[()->Void]] = [:]

    var instrument: String = "guitar".localized()
    var tunings: [String] = []
    var tuningStrings: [[String]] = []
    var tuningIndex: Int = 0
    var strings: [String] = []
    var sortedStrings: [String] = []

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
    var pitch: String = "default".localized()
    var instruments: [String: [(title: String, strings: [String])]] = [:]
    var filter: String = "on".localized()

    func setInstrument(_ value: String){
        if instruments[value] == nil {
            return
        }

        instrument = value
        defaults.setValue(instrument, forKey: "instrument".localized())

        tunings = []
        tuningStrings = []
        for tuning in instruments[instrument]! {
            tunings.append(tuning.title)
            tuningStrings.append(tuning.strings)
        }

        let defaultTuning: Int? = defaults.integer(forKey: instrument)
        if defaultTuning != nil {
            setTuningIndex(defaultTuning!)
        }else{
            setTuningIndex(0)
        }

        delegate?.didInstrumentChange()
    }

    func setTuningIndex(_ value: Int) {
        defaults.set(value, forKey: instrument)
        tuningIndex = value
        strings = tuningStrings[tuningIndex]

        sortedStrings = strings.sorted {self.noteFrequency($0) < self.noteFrequency($1)}

        setStringIndex(stringIndex)

        delegate?.didTuningChange()
    }

    func setStringIndex(_ value: Int) {
        if value < 0 {
            stringIndex = 0
        } else if value >= strings.count {
            stringIndex = strings.count - 1
        } else {
            stringIndex = value
        }

        defaults.set(stringIndex, forKey: "stringIndex")
        string = strings[stringIndex]

        let n = Double(noteNumber(string))
        notes = [noteString(n-1.0), noteString(n), noteString(n+1.0)]

        delegate?.didStringChange()
    }

    func setPitchIndex(_ value: Int) {
        defaults.set(value, forKey: "pitchIndex")
        pitchIndex = value
        pitch = pitchValues[pitchIndex]

        if pitch == "scientific" {
            baseFrequency = 256.0
            baseNote = "c4"
            return
        }

        baseFrequency = 440.0
        baseNote = "a4"
        
        delegate?.didPitchChange()
    }

    func setFrequency(_ value: Double){
        frequency = value / fretScale()
        delegate?.didFrequencyChange()
    }

    func setFret(_ value: Int) {
        fret = value

        defaults.set(fret, forKey: "fret")
        
        delegate?.didFretChange()
    }
    
    func setFilter(_ value: String) {
        filter = value
        defaults.set(filter, forKey: "filter")

        delegate?.didFilterChange()
    }
    
    var status = "active"
    func setStatus(_ value: String){
        status = value
        
        delegate?.didStatusChange()
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
            ("Standard/Prima", "e4 e4 a4"),
            ("Bass", "e2 a2 d3"),
            ("Tenor", "a2 a2 e3"),
            ("Alto", "e3 e3 a3"),
            ("Secunda", "a3 a3 d4"),
            ("Piccolo", "b4 e5 a5")
        ])

        addInstrument("ukulele", [
            ("Standard", "g4 c4 e4 a4"),
            ("D-tuning", "a4 d4 f#4 b4")
        ])

        //addInstrument("free mode", [
        //    ("Octaves", "c2 c3 c4 c5 c6"),
        //    ("C-major", "c3 d3 e3 f3 g3 a3 b3"),
        //    ("C-minor", "c3 d3 e3 f3 g3 a3 b3")
        //])

        if defaults.string(forKey: "instrument") != nil {
            let value: String? = defaults.string(forKey: "instrument")
            setInstrument(value!)
        } else {
            setInstrument("guitar")
        }
        
        if defaults.string(forKey: "filter") != nil {
            let value: String? = defaults.string(forKey: "filter")
            setFilter(value!)
        } else {
            setFilter("on")
        }

        setTuningIndex(defaults.integer(forKey: instrument))
        setStringIndex(defaults.integer(forKey: "stringIndex"))
        setPitchIndex(defaults.integer(forKey: "pitchIndex"))
        setFret(defaults.integer(forKey: "fret"))
    }

    func addInstrument(_ name: String, _ tunings: [(String, String)]){
        var result: [(title: String, strings: [String])] = []

        for (title, strings) in tunings {
            let splitStrings: [String] = strings.characters.split {$0 == " "}.map { String($0) }
            let titleStrings: String = splitStrings.map({(note: String) -> String in
                note.replacingOccurrences(of: "#", with: "♯")
            }).joined(separator: " ")
            result += [(title: title + " (" + titleStrings + ")", strings: splitStrings)]
        }

        instruments[name] = result
    }

    func noteNumber(_ noteString: String) -> Int {
        let note = noteString.lowercased()
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

    func noteString(_ num: Double) -> String {
        let noteOctave: Int = Int(num / 12)
        let noteShift: Int = Int(num.truncatingRemainder(dividingBy: 12))

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

    func noteFrequency(_ noteString: String) -> Double {
        let n = noteNumber(noteString)
        let b = noteNumber(baseNote)

        return baseFrequency * pow(2.0, Double(n - b) / 12.0);
    }

    func frequencyNumber(_ f: Double) -> Double {
        let b = noteNumber(baseNote);

        return 12.0 * log(f / baseFrequency) / log(2) + Double(b);
    }

    func frequencyDistanceNumber(_ f0: Double, _ f1: Double) -> Double {
        let n0 = frequencyNumber(f0)
        let n1 = frequencyNumber(f1)

        return n1 - n0;
    }

    func targetFrequency() -> Double {
        return noteFrequency(string) * fretScale()
    }

    func actualFrequency() -> Double {
        return frequency * fretScale()
    }

    func frequencyDeviation() -> Double {
        return 100.0 * frequencyDistanceNumber(noteFrequency(string), frequency)
    }

    func stringPosition() -> Double {
        let pos: Double = soretedStringPosition()
        
        let index: Int = Int(pos + 0.5)

        if index < 0 || index >= sortedStrings.count {
            return pos
        }

        let name = sortedStrings[index]

        let realIndex: Int? = strings.index(of: name)

        if realIndex == nil{
            return pos
        }

        
        return pos + Double(realIndex! - index)
    }

    func soretedStringPosition() -> Double {
        let frst = noteFrequency(sortedStrings.first!)
        let lst = noteFrequency(sortedStrings.last!)
        
        if frequency > frst {
            var f0 = 0.0
            var pos: Double = -1.0
            for str in sortedStrings {
                let f1 = noteFrequency(str)
                if frequency < f1 {
                    return pos + (frequency - f0) / (f1 - f0)
                }
                f0 = f1
                pos += 1
            }
        }

        return Double(strings.count - 1) * (frequency - frst) / (lst - frst)
    }

    func nextString() {
        setStringIndex(stringIndex+1)
    }

    func prevString() {
        setStringIndex(stringIndex-1)
    }

    func fretScale() -> Double {
        return pow(2.0, Double(fret) / 12.0)
    }
}
