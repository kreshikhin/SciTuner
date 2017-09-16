//
//  HarmonicDetector.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 9/15/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import XCTest
@testable import SciTuner

class HarmonicDetectorTests: XCTestCase {
    let detector = HarmonicDetector()
    
    var dataset: [(input: [Double], pulsation: Double, output: Int)] = []
    
    override func setUp() {
        let files = [330, 247, 196, 147, 110].map { (n) -> String in
            return "dataset_\(n)hz"
        }
        
        files.forEach { (file) in
            guard let currentBundle = Bundle.allBundles.first(where: { (bundle) -> Bool in
                guard let p = bundle.path(forResource: file, ofType: "json") else {
                    return false
                }
                
                print(p)
                
                return true
            }) else {
                return
            }
            
            guard let path = currentBundle.path(forResource: file, ofType: "json") else {
                return
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as! [String: Any] else {
                return
            }
            
            let samples = json["samples"] as! [Any]
            
            for sample in samples {
                let s = sample as! [String: Any]
                var input = [Double](s["f"] as! [Double])
                let output = s["o"] as! Int
                let pulsation = s["p"] as! Double
                
                dataset.append((input, pulsation, output))
            }
        }
        
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertEqual(detector.networks.count, 3)
    }
    
    func test1stHarmonic() {
        let subtones = [0.00, 0.00, 0.00, 0.17, 0.09, 1.00, 0.00, 0.72, 0.00, 0.00]
        let pulsation = 0.99
        
        let result = detector.detect(subtones: subtones, pulsation: pulsation)
        
        XCTAssertEqual(result, 1)
    }
    
    func test2ndHarmonic() {
        let subtones = [0.60, 0.53, 0.80, 0.20, 0.40, 1.00, 0.39, 0.44, 0.35, 0.18]
        let pulsation = 0.90
        
        let result = detector.detect(subtones: subtones, pulsation: pulsation)
        
        XCTAssertEqual(result, 2)
    }
    
    func testDatasets() {
        var passes: Double = 0
        var errors: Double = 0
        for sample in dataset {
            let result = detector.detect(subtones: sample.input, pulsation: sample.pulsation)
            if result == sample.output {
                passes += 1
            } else {
                errors += 1
            }
        }
        
        XCTAssertGreaterThan(passes / (passes + errors), 0.9)
    }
    
}
