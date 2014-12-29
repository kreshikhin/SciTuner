//
//  MicSource.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 28.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

/*
import Foundation
import AVFoundation

class MicSource{
    let bufferNumebrs = 3
    
    var dataFormat: AudioStreamBasicDescription
    var queue: AudioQueueRef
    var buffers: AudioQueueBufferRef
    var audioFileID: AudioFileID
    
    var bufferByteSize: Int32
    var currentPacket: Int64
    
    var isRunning: Bool
    
    var onData: (([Float]) -> ()) = { ([Float]) -> () in
    }
    
    var frequency: Double = 0
    
    var frequency1: Double = 400.625565
    var frequency2: Double = 0.05
    
    var frequencyDeviation: Double = 50.0
    var discreteFrequency: Double = 44100
    var t: Double = 0
    
    var sample = [Float](count: 882, repeatedValue: 0)
    
    init(sampleRate: Int, sampleCount: Int) {
        dataFormat.mFormatID = AudioFormatID(kAudioFormatLinearPCM)
        dataFormat.mSampleRate = Float64(sampleRate)
        dataFormat.mChannelsPerFrame = 1
        dataFormat.mBitsPerChannel = 16
        dataFormat.mBytesPerPacket = 1 // for linear pcm
        dataFormat.mBytesPerFrame = dataFormat.mChannelsPerFrame * sizeof(Int16) // for 16bit
        
        var session = AVAudioSession()
        session.setCategory(AVAudioSessionCategoryRecord, error: nil)
        
        recorder = AVAudioRecorder()
        
        
        
        self.discreteFrequency = Double(sampleRate)
        sample = [Float](count: sampleCount, repeatedValue: 0)
        
        var interval = Double(sample.count) / discreteFrequency
        
        NSLog(" %f ", interval);
        
        let timer = NSTimer(timeInterval: interval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    @objc func update(){
        var dt = Double(1) / discreteFrequency
        
        var df: Double = frequencyDeviation * sin(2 * M_PI * frequency2 * t)
        frequency = frequency1 + df
        
        for var i = 0; i < sample.count ; i++ {
            t = t + dt
            sample[i] = Float(1.0 * sin(2 * M_PI * (frequency1 + df) * t + rand() / 100) + 1.0 * (rand() - 0.5))
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
*/
