//
//  Instrument.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/9/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

enum Instrument: String {
    case guitar = "guitar"
    case cello = "cello"
    case violin = "violin"
    case banjo = "banjo"
    case balalaika = "balalaika"
    case ukulele = "ukulele"
    
    static let all: [Instrument] = [.guitar, .cello, .violin, .banjo, .balalaika, .ukulele]
    
    func localized() -> String {
        return rawValue.localized()
    }
    
    func tunings() -> [Tuning] {
        switch self {
        case .guitar: return Tuning.guitarTunings
        case .cello: return Tuning.celloTunings
        case .violin: return Tuning.violinTunings
        case .banjo: return Tuning.banjoTunings
        case .balalaika: return Tuning.balalaikaTunings
        case .ukulele: return Tuning.ukuleleTunings
        }
    }
}
