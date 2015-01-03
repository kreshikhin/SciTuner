//
//  MicSource.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 28.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

// https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQRecord/RecordingAudio.html#//apple_ref/doc/uid/TP40005343-CH4-SW24

import Foundation
import AVFoundation

class MicSource{
    var aqData = AQRecorderState_create()
    
    var onData: (([Float]) -> ()) = { ([Float]) -> () in
    }
    
    var frequency: Double = 0
    
    var frequency1: Double = 400.625565
    var frequency2: Double = 0.05
    
    var frequencyDeviation: Double = 50.0
    var discreteFrequency: Double = 44100
    var t: Double = 0
    
    var sample = [Float](count: 882, repeatedValue: 0)
    
    init(sampleRate: Double, sampleCount: Int) {
        AQRecorderState_init(aqData, sampleRate, UInt(sampleCount))
        
        /*
        self.discreteFrequency = Double(sampleRate)
        sample = [Float](count: sampleCount, repeatedValue: 0)
        
        var interval = Double(sample.count) / discreteFrequency
        
        NSLog(" %f ", interval);
        
        let timer = NSTimer(timeInterval: interval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)*/
    }
    
    deinit{
        AQRecorderState_deinit(aqData);
        AQRecorderState_destroy(aqData);
    }
    
    @objc func update(){
        
        //onData()
    }
}
