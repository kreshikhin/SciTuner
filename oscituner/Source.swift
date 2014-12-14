

import Foundation

class Source{
    var OnData: (([Double]) -> ()) = { ([Double]) -> () in
    }
    
    var Freq: Double = 0

    var f1: Double = 1600.625565
    var f2: Double = 0.05
    
    var dfmax: Double = 2.0
    var Fd: Double = 44100
    var t: Double = 0
    
    var sample = [Double](count: 882, repeatedValue: 0)
    
    init() {
        var interval = Double(sample.count) / Fd
        
        let timer = NSTimer(timeInterval: interval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    @objc func update(){
        var dt = Double(1) / Fd
        
        var df: Double = dfmax * sin(M_2_PI * f2 * t)
        Freq = f1 + df
        
        for var i = 0; i < sample.count ; i++ {
            t = t + dt
            sample[i] = 1.0 * sin(M_2_PI * (f1 + df) * t + rand() / 100) + 1.0 * (rand() - 0.5)
        }
            
        OnData(sample)
    }

    func GetFreqText() -> String {
        return String(format: "%6.2f Hz", Freq)
    }
    
    func rand() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }
}

