//
//  Settings.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/9/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
    typealias `Self` = Settings
    
    static let processingPointCount: UInt = 128
    static let sampleRate: Double = 44100
    static let sampleCount: Int = 2048
    static let spectrumLength: Int = 32768
    static let showFPS = true
    static let previewLength: Int = 5000
    static let fMin: Double = 16.0
    
    dynamic var fret: Fret = .openStrings
    dynamic var stringIndex: Int = 0
    
    var pitch: Pitch {
        set { self.pitch_ = newValue.rawValue }
        get { return Pitch(rawValue: self.pitch_) ?? .standard }
    }
    
    var instrument: Instrument {
        set { self.instrument_ = newValue.rawValue }
        get { return Instrument(rawValue: self.instrument_) ?? .guitar }
    }
    
    var tuning: Tuning {
        set { self.tuning_ = newValue.id }
        get { return Tuning(instrument: instrument, id: self.tuning_) ?? Tuning(standard: instrument)}
    }
    
    var filter: Filter {
        set { self.filter_ = newValue.rawValue }
        get { return Filter(rawValue: self.filter_) ?? .on }
    }
    
    private dynamic var pitch_: String = Pitch.standard.rawValue
    private dynamic var instrument_: String = Instrument.guitar.rawValue
    private dynamic var tuning_: String = Instrument.guitar.rawValue
    private dynamic var filter_: String = Filter.off.rawValue
    
    static func shared() -> Settings {
        let realm = try! Realm()
        
        if let settings = realm.objects(`Self`.self).first {
            return settings
        }
        
        let settings = Settings()
        
        try! realm.write {
            realm.add(settings)
        }
        
        return settings
    }
    
    func primaryKey() -> String {
        return "settings"
    }
}
