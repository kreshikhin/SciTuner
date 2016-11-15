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
    var sleep: Bool = true
    
    var onData: (() -> ()) = { () -> () in
    }
    
    var frequency: Double = 0
    
    var frequency1: Double = 400.625565
    var frequency2: Double = 0.05
    
    var frequencyDeviation: Double = 50.0
    var discreteFrequency: Double = 44100
    var t: Double = 0
    
    var sample = [Double](count: 2205, repeatedValue: 0)
    var preview = [Double](count: Int(PREVIEW_LENGTH), repeatedValue: 0)
    
    let sampleRate: Double
    let sampleCount: Int
    
    init(sampleRate: Double, sampleCount: Int) {
        self.sampleRate = sampleRate
        self.sampleCount = sampleCount
    }
    
    func activate(){
        if !sleep {
            return
        }
        
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
        
        AQRecorderState_init(aqData, sampleRate, size_t(sampleCount))
        
        self.discreteFrequency = Double(sampleRate)
        sample = [Double](count: sampleCount, repeatedValue: 0)
        
        let interval = Double(sample.count) / discreteFrequency
        
        let timer = NSTimer(timeInterval: interval, target: self, selector: #selector(MicSource.update), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        sleep = false;
    }
    
    func inactivate(){
        if sleep {
            return
        }
        
        AQRecorderState_deinit(aqData);
        sleep = true;
    }
    
    deinit{
        AQRecorderState_destroy(aqData);
    }
    
    @objc func update(){
        if(sleep) {
            return
        }
        
        AQRecorderState_get_samples(self.aqData, &sample, size_t(sample.count))
        AQRecorderState_get_preview(self.aqData, &preview, size_t(preview.count))
        onData()
    }
}
