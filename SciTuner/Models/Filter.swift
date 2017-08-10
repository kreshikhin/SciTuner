//
//  Filter.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/10/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

enum Filter: String {
    typealias `Self` = Filter
    case on = "on", off = "off"
    
    static let allFilters: [Self] = [.on, .off]
    
    func localized() -> String {
        return self.rawValue.localized()
    }
}
