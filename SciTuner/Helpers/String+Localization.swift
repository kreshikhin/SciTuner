//
//  String+Localization.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/9/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
