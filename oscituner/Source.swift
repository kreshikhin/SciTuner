

import Foundation

class Source{
    var onData: (([Float]) -> ()) = { ([Float]) -> () in
    }

    var frequency: Double = 0

    var frequency1: Double = 1600.625565
    var frequency2: Double = 0.05

    var frequencyDeviation: Double = 2.0
    var discreteFrequency: Double = 44100
    var t: Double = 0

    var sample = [Float](count: 882, repeatedValue: 0)

    init() {
        var interval = Double(sample.count) / discreteFrequency
        
        NSLog(" %f ", interval);

        let timer = NSTimer(timeInterval: interval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    @objc func update(){
        var dt = Double(1) / discreteFrequency

        var df: Double = frequencyDeviation * sin(M_2_PI * frequency2 * t)
        frequency = frequency1 + df

        for var i = 0; i < sample.count ; i++ {
            t = t + dt
            sample[i] = Float(1.0 * sin(M_2_PI * (frequency1 + df) * t + rand() / 100) + 1.0 * (rand() - 0.5))
        }
        
        onData(sample)
    }

    func getFreqText() -> String {
        return String(format: "%6.2f Hz", frequency)
    }

    func rand() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }
}
