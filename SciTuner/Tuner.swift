//
//  Tuner.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 28.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation

class Tuner {
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

    var onInstrumentChange = {()-Void in}

    let sections: [String] = ["pitch", "tuning"]

    let pitchs: [String] = ["Default A4=440Hz", "Scientific C4=256Hz"]
    let pitchValues: [String] = ["default", "scientific"]
    var pitchIndex: Int = 0

    var instruments: [String:[String:String]] = [String:[String:String]]()

    // bindings
    var instrumentTitle: String = ""
    var tuningTitles: [String] = []
    var tuningStrings: [[String]]

    var instrument: String{
        set{
            instrumentTitle = newValue
            tuningTitles = []
            tuningStrings = []
            for (title, strings) in instruments[instrumentTitle]! {
                var splitStrings = split(strings) {$0 == " "}
                var titleStrings = join(" ", splitStrings.map({(note: String) -> String in
                    return note.repl
                })
                tuningTitles.append(title + " (" + titleNotes + ")"))
                //tuningStrings.append(strings.spl)
            }
        }
        get{
            return instrumentTitle
        }
    }

    var shift: Int = 0
    var strings: [String] = ["e2", "a2", "d3", "g3", "b3", "e4"]
    var notes: [String] = ["d#2", "e2", "f2"]

    var frequency: Double = 440

    // pitch
    var baseFrequency: Double = 440
    var baseNote: String = "a4"

    //
    var fret: Int = 0

    // target
    var targetStringNumber: Int = 0
    var targetNote: String {
        get{
            if self.targetStringNumber < 0 {
                return strings.first!
            } else if self.targetStringNumber >= strings.count {
                return strings.last!
            }

            return strings[self.targetStringNumber]
        }
        set{
        }
    }

    init(){
        addInstrument("guitar", [
            "Standard": "e2 a2 d3 g3 b3 e4",
            "New Standard": "c2 g2 d3 a3 e4 g4",
            "Russian": "d2 g2 b2 d3 g3 b3 d4",
            "Drop D": "d2 a2 d3 g3 b3 e4",
            "Drop C": "c2 g2 c3 f3 a3 d4",
            "Drop G": "g2 d2 g3 c4 e4 a4",
            "Open D": "d2 a2 d3 f#3 a3 d4",
            "Open C": "c2 g2 c3 g3 c4 e4",
            "Open G": "g2 g3 d3 g3 b3 d4",
            "Lute": "e2 a2 d3 f#3 b3 e4",
            "Irish": "d2 a2 d3 g3 a3 d4",
        ])

        addInstrument("cello", [
            "Standard": "c2 g2 d3 a3",
            "Alternative": "c2 g2 d3 g3"
        ])

        addInstrument("violin", [
            "Standard": "g3 d4 a4 e5",
            "Tenor": "g2 d3 a3 e4",
            "Tenor alter.": "f2 c3 g3 d4"
        ])

        addInstrument("banjo", [
            "Standard": "g4 d3 g3 b3 d4",
        ])

        addInstrument("ukulule", [
            "Standard": "g4 c4 e4 a4",
            "D-tuning": "a4 d4 f#4 b4",
        ])
    }

    func addInstrument(name: String, _ tunings: [String: String]){
        instruments[name] = tunings
    }

    func getNotePosition(){
    }

    func targetNotes() -> [String] {
        var n = Double(noteNumber(targetNote))
        return [noteString(n-1), noteString(n), noteString(n+1)]
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
        return noteFrequency(targetNote)
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
        if targetStringNumber < strings.count-1 {
            targetStringNumber++
        }
    }

    func prevString() {
        if targetStringNumber > 0 {
            targetStringNumber--
        }
    }
}
