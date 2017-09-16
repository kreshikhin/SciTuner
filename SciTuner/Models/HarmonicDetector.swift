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
        
        func calculate(input: [Double]) -> Double {
            var offset = 0
            var result: [Double] = [0]
            
            for count in layers {
                result = calculateLayer(input: input, weights: weights[0..<count * (input.count + 1)])
                
                offset += count * (input.count + 1)
            }
            
            return result[0]
        }
        
        func calculateLayer(input: [Double], weights: ArraySlice<Double>) -> [Double] {
            print("input", input.count)
            print("weights", weights.count)
            
            let count = weights.count / (1 + input.count)
            var result = [Double](repeating: 0, count: count)
            
            for i in 0..<count {
                result[i] = weights[0]
                
                for (k, v) in input.enumerated() {
                    result[i] += v * weights[k + 1]
                }
            }
            
            return result.map{ sigmoid(x: $0) }
        }
        
        func sigmoid(x: Double) -> Double {
            return 1 / (exp(-x) + 1)
        }
        
        func tansig(x: Double) -> Double {
            return 2.0 / (1.0 + exp(-2.0 * x)) - 1.0
        }
    }
    
    var networks = [Network]()
    
    init() {
        ["nn1", "nn2", "nn3"].forEach { (name) in
            if let network = Self.load(network: name) {
                networks.append(network)
            }
        }
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
            
            if result > 0.5 {
                return i + 2
            }
        }
        
        return 1
    }
}
