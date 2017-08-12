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
        set { self.tuning_ = tuning.id }
        get { return Tuning(instrument: instrument, id: self.tuning_) ?? Tuning(instrument: .guitar)}
    }
    
    var filter: Filter {
        set { self.filter_ = newValue.rawValue }
        get { return Filter(rawValue: self.filter_) ?? .off }
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
