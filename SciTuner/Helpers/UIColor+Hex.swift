//
//  UIColor+Hex.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/29/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat(Double((hex >> 16) & 0xff) / 255.0),
            G: CGFloat(Double((hex >> 08) & 0xff) / 255.0),
            B: CGFloat(Double((hex >> 00) & 0xff) / 255.0)
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}
