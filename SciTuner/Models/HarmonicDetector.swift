//
//  HarmonicDetector.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/15/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import Foundation

class HarmonicDetector {
    typealias `Self` = HarmonicDetector
    
    static let factors: [Double] = [0.25, 1/3, 0.5, 2/3, 0.75, 1.0, 1.5, 2, 3, 4]
    
    struct Network{
        var layers: [Int]
        var weights: [Double]
        
        func activate(input: [Double]) -> Double {
            var offset = 0
            var result: [Double] = input
            
            for count in layers {
                let l = count * (result.count + 1)
                result = calculateLayer(input: result, weights: [Double](weights[offset..<offset+l]))
                offset += l
            }
            
            return result[0]
        }
        
        func activateLayer(input: [Double], weights: [Double]) -> [Double] {
            let step = 1 + input.count
            let count = weights.count / step
            var result = [Double](repeating: 0, count: count)
            
            for i in 0..<count {
                result[i] = weights[i*step]
                
                for (k, v) in input.enumerated() {
                    result[i] += v * weights[i*step + k + 1]
                }
            }
            
            return result.map{ 1 / (exp(-$0) + 1) }
        }
    }
    
    var networks = [Network]()
    
    init() {
        ["nn1", "nn2", "nn3"].forEach { (name) in
            if let network = Self.load(network: name) {
                networks.append(network)
            }
        }
        
        print(networks)
    }
    
    static func load(network: String) -> Network? {
        guard let currentBundle = Bundle.allBundles.first(where: { (bundle) -> Bool in
            guard let p = bundle.path(forResource: network, ofType: "json") else {
                return false
            }
            
            print(p)
            
            return true
        }) else {
            return nil
        }
        
        guard let path = currentBundle.path(forResource: network, ofType: "json") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as! [String: [Double]] else {
            return nil
        }
        
        guard let layers = json["layers"] else {
            return nil
        }
        
        guard let weights = json["weights"] else {
            return nil
        }
        
        let network = Network(layers: layers.map({ (layer) -> Int in
            return Int(layer)
        }), weights: weights)
        
        return network
    
    }
    
    func detect(subtones: [Double], pulsation: Double) -> Int {
        var input = [Double](subtones)
        input.append(pulsation)
        
        for (i, network) in networks.enumerated() {
            let result = network.calculate(input: input)
            print("result", result)
            
            if result < 0.5 {
                return i + 1
            }
        }
        
        return 4
    }
}
