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
    
    init(pointCount: UInt){
        self.pointCount = pointCount
        processing_init(p, 44100.0, 16.0, size_t(32768), size_t(pointCount))
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
    
    func buildSmoothStandingWave(_ wave: inout [Float], light: inout [Float], length: Int, thickness: Float) {
        processing_build_standing_wave(p, &wave, &light, size_t(length), thickness)
    }
    
    func buildSmoothStandingWave2(_ wave: inout [Double], length: Int) {
        processing_build_standing_wave2(p, &wave, size_t(length))
    }
    
    func getFrequency() -> Double {
        harmonic = Int(processing_get_harmonic_order(p))
        let frequency = (processing_get_frequency(p) + processing_get_sub_frequency(p)) / Double(harmonic)
        
        return frequency
    }
    
    func setTargetFrequency(_ frequency: Double) {
        processing_set_target_frequency(p, frequency, Int32(harmonic));
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
