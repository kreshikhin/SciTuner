

import Foundation

class MicSource{
    var onData: (([Float]) -> ()) = { ([Float]) -> () in
    }

    var frequency: Double = 0

    var frequency1: Double = 1600.625565
    var frequency2: Double = 0.05

    var frequencyDeviation: Double = 2.0
    var discreteFrequency: Double = 44100
    var t: Double = 0

    var sample = [Float](count: 882, repeatedValue: 0)


    var session AVAudioSession?

    init() {
        session = AVAudioSession.sharedInstance()

        var interval = Double(sample.count) / discreteFrequency

        NSLog(" %f ", interval);

        let timer = NSTimer(timeInterval: interval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    @objc func update(){
        onData(sample)
    }
}
