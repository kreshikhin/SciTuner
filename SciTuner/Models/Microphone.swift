//
//  Microphone.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 28.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

// https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQRecord/RecordingAudio.html#//apple_ref/doc/uid/TP40005343-CH4-SW24

import Foundation
import AVFoundation

protocol MicrophoneDelegate: class{
    func microphone(_ microphone: Microphone?, didReceive data: [Double]?)
}

@objc
class Microphone: NSObject{
    weak var delegate: MicrophoneDelegate?
    
    var aqData = AQRecorderState_create()
    var sleep: Bool = true
    
    var sample: [Double]
    var preview: [Double]
    
    let sampleRate: Double
    let sampleCount: Int
    
    init(sampleRate: Double, sampleCount: Int) {
        self.sampleRate = sampleRate
        self.sampleCount = sampleCount
        
        sample = [Double](repeating: 0, count: sampleCount)
        preview = [Double](repeating: 0, count: Settings.previewLength)
    }
    
    func activate(){
        if !sleep {
            return
        }
        
        var err: NSError?;
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setPreferredSampleRate(sampleRate)
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
        
        let callback: @convention (c) (UnsafeRawPointer?) -> Void = { (owner) in
            guard let opaque = owner else {
                return
            }
            
            let this = Unmanaged<Microphone>.fromOpaque(opaque).takeUnretainedValue()
            
            if(this.sleep) { return }
            
            AQRecorderState_get_samples(this.aqData, &this.sample, size_t(this.sample.count))
            AQRecorderState_get_preview(this.aqData, &this.preview, size_t(this.preview.count))
            
            DispatchQueue.main.async {
                this.delegate?.microphone(this, didReceive: this.sample)
            }
        }
        
        AQRecorderState_init(aqData, sampleRate, size_t(sampleCount))
        AQRecorderState_set_callback(aqData, Unmanaged.passUnretained(self).toOpaque(), callback)
        
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
}
