//
//  Processing.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import Foundation
import Accelerate

class Processing{
    var p = processing_create();
    let pointCount: UInt
    
    var harmonic: Int = 1
    let detector = HarmonicDetector()
    
    init(pointCount: UInt){
        self.pointCount = pointCount
        processing_init(p, Settings.sampleRate, size_t(Settings.spectrumLength), size_t(pointCount), size_t(Settings.previewLength))
    }
    
    deinit{
        processing_deinit(p)
        processing_destroy(p)
    }
    
    func push(_ packet: inout [Double]){
        processing_push(p, packet, size_t(packet.count))
    }
    
    func savePreview(_ packet: inout [Double]){
        processing_save_preview(p, packet, size_t(packet.count))
    }
    
    func recalculate() {
        processing_recalculate(p)
    }
    
    func buildSmoothStandingWave2(_ wave: inout [Double], length: Int) {
        processing_build_standing_wave2(p, &wave, size_t(length))
    }
    
    func getFrequency() -> Double {
        harmonic = getHarmonicOrder()
        let f = processing_get_frequency(p)
        print("order", harmonic, "freq", f)
        let frequency = (processing_get_frequency(p) + processing_get_sub_frequency(p)) / Double(harmonic)
        
        return frequency
    }
    
    func getHarmonicOrder() -> Int {
        var harmonics = [Double](repeating: 0, count: 10)
        var pulsation: Double = 0
        processing_get_harmonics(p, &harmonics, harmonics.count, &pulsation)
        print(harmonics)
        return detector.detect(subtones: harmonics, pulsation: pulsation)
    }
    
    func setTargetFrequency(_ frequency: Double) {
        processing_set_target_frequency(p, frequency, Int32(harmonic))
    }
    
    func setBand(fmin: Double, fmax: Double) {
        processing_set_band(p, fmin, fmax)
    }
    
    func enableFilter(){
        processing_enable_filter(p)
    }
    
    func disableFilter(){
        processing_disable_filter(p)
    }
    
    func pulsation() -> Double {
        return processing_get_pulsation(p)
    }
}
