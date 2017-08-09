//
//  MicSource2.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 10.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//
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

class MicSource2{
    var onData: (() -> ()) = { () -> () in
    }
    
    var frequency: Double = 0
    
    var frequency1: Double = 400.625565
    var frequency2: Double = 0.05
    
    var frequencyDeviation: Double = 50.0
    var discreteFrequency: Double = 44100
    var t: Double = 0
    
    var sample = [Double](repeating: 0, count: 2205)
    
    init(sampleRate: Double, sampleCount: Int) {
        var err: NSError?;
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setPreferredSampleRate(44100)
        } catch _ {
        }
        do {
            try session.setPreferredInputNumberOfChannels(1)
        } catch _ {
        }
        do {
            try session.setPreferredOutputNumberOfChannels(1)
        } catch _ {
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError {
            err = error
            NSLog("can't activate session %@ ", err!)
        }
        
        do {
            try session.setCategory(AVAudioSessionCategoryRecord)
        } catch let error as NSError {
            err = error
            NSLog("It can't set category, because %@ ", err!)
        }
        
        do {
            try session.setMode(AVAudioSessionModeMeasurement)
        } catch let error as NSError {
            err = error
            NSLog("It can't set mode, because %@ ", err!)
        }
        
        self.discreteFrequency = Double(sampleRate)
        sample = [Double](repeating: 0, count: sampleCount)
        
        let interval = Double(sample.count) / discreteFrequency
        
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(MicSource2.update), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    deinit{
    }
    
    @objc func update(){
        onData()
    }
}
