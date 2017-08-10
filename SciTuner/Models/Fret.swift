//
//  Fret.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/10/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

@objc
enum Fret: Int {
    static let allFrets = [.fret5, fret7, fret12, .openStrings]
    
    case openStrings = 0
    case fret5 = 5
    case fret7 = 7
    case fret12 = 12
    
    func localized() -> String {
        switch self {
        case .openStrings: return "open strings".localized()
        default:
            return String(format: "%ith fret", self.rawValue).localized()
        }
    }
}
