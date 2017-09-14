//
//  Tuner.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 28.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import RealmSwift

protocol TunerDelegate: class {
    func didSettingsUpdate()
    func didStatusChange()
    func didFrequencyChange()
}

class Tuner {
    weak var delegate: TunerDelegate?
    private let settings = Settings.shared()
    static let sharedInstance = Tuner()
    
    var instrument: Instrument {
        set{ settings.instrument = newValue }
        get{ return settings.instrument }
    }
    
    var pitch: Pitch {
        set{ settings.pitch = newValue }
        get{ return settings.pitch }
    }

    var tuning: Tuning {
        set{ settings.tuning = newValue }
        get{ return settings.tuning }
    }

    var filter: Filter {
        set{ settings.filter = newValue }
        get{ return settings.filter }
    }

    var fret: Fret {
        set{ settings.fret = newValue }
        get{ return settings.fret }
    }

    var strings: [Note] { return settings.tuning.strings }
    
    var sortedStrings: [Note] {
        return settings.tuning.strings.sorted()
    }

    private let frequencySmoothing = Smoothing(n: 10, cutoff: 0.5, resonance: 1.1)
    
    var frequency: Double {
        set {
            let f = frequencySmoothing.handle(x: newValue)
            originFrequency_ = fret.shiftDown(frequency: f) }
        get { return fret.shiftUp(frequency: originFrequency_) }
    }
    
    private var originFrequency_: Double = 440

    var isPaused = false
    
    var targetString: Note?
    
    var isActive = true {
        didSet { delegate?.didStatusChange() }
    }
    
    func updateTargetFrequency() {
        setTargetFrequency(frequency: frequency)
    }
    
    func setTargetFrequency(frequency: Double) {
        let f0 = fret.shiftDown(frequency: frequency)
        
        targetString = (tuning.strings.min{ (a, b) -> Bool in
            let fa = self.pitch.frequency(of: a)
            let fb = self.pitch.frequency(of: b)
            
            return abs(fa - f0) < abs(fb - f0)
        })
    }

    func targetFrequency() -> Double? {
        guard let ts = targetString else {
            return nil
        }
        
        return fret.shiftUp(frequency: pitch.frequency(of: ts))
    }
    
    func noteDeviation() -> Double {
        if let ts = targetString {
            return 100 * pitch.deviation(note: ts, frequency: frequency)
        }
        
        return 0
        
    }

    func notePosition() -> Double {
        return pitch.notePosition(with: frequency)
    }
    
    func stringPosition() -> Double {
        let pos: Double = sortedStringPosition()
        
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

    func sortedStringPosition() -> Double {
        let frst = pitch.frequency(of: sortedStrings.first!)
        let lst = pitch.frequency(of: sortedStrings.last!)
        
        if frequency > frst {
            var f0 = 0.0
            var pos: Double = -1.0
            for note in sortedStrings {
                let f1 = pitch.frequency(of: note)
                if frequency < f1 {
                    return pos + (frequency - f0) / (f1 - f0)
                }
                f0 = f1
                pos += 1
            }
        }

        return Double(strings.count - 1) * (frequency - frst) / (lst - frst)
    }
    
    func band() -> (fmin: Double, fmax: Double) {
        return pitch.band(of: tuning)
    }
}
