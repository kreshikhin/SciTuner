//
//  Smoothing.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/28/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

class Smoothing{
    typealias `Self` = Smoothing
    typealias Filter = (Double) -> Double
    var filters = [Filter]()
  
    init(n: UInt, cutoff: Double, resonance: Double){
        filters.append(Self.createMedianFilter(n: 5))
        filters.append(Self.createLowpassFilter(cutoff: cutoff, resonance: resonance))
    }
    
    func handle(x: Double) -> Double {
        var result: Double = x
        
        for filter in filters {
            result = filter(result)
        }
        
        return result
    }
    
    static func createMedianFilter(n: UInt) -> Smoothing.Filter {
        var values = [Double]()
        let m: Int = Int(n | 1)
        
        return { (x: Double) -> Double in
            values.append(x)
            
            if values.count > m {
                values.remove(at: 0)
            }
            
            return values.sorted()[values.count / 2]
        }
    }
    
    static func createLowpassFilter(cutoff: Double, resonance: Double) -> Smoothing.Filter {
        let resonance = max(0.0, resonance) // can't go negative
        let g = pow(10.0, 0.05 * resonance)
        let d = sqrt((4.0 - sqrt(16.0 - 16.0 / (g * g))) / 2.0)
        
        let theta = Double.pi * cutoff
        let sn = 0.5 * d * sin(theta)
        let beta = 0.5 * (1 - sn) / (1 + sn)
        let gamma = (0.5 + beta) * cos(theta)
        let alpha = 0.25 * (0.5 + beta - gamma)
        
        let b0 = 2.0 * alpha
        let b1 = 2.0 * 2.0 * alpha
        let b2 = 2.0 * alpha
        let a1 = 2.0 * -gamma
        let a2 = 2.0 * beta
        
        var x1: Double = 0
        var x2: Double = 0
        
        var y1: Double = 0
        var y2: Double = 0
        
        return { (x: Double) -> Double in
            let y = b0*x + b1*x1 + b2*x2 - a1*y1 - a2*y2
            
            // update state variables
            x2 = x1
            x1 = x
            
            y2 = y1
            y1 = y
            
            return y
        }
    }
}
