//
//  Processing.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import Foundation
import Accelerate

class ProcessingAdapter{
    var p = processing_create();
    let pointCount: UInt
    
    init(pointCount: UInt){
        self.pointCount = pointCount
        processing_init(p, 44100.0, 16.0, size_t(32768), size_t(pointCount))
    }
    
    deinit{
        processing_deinit(p)
        processing_destroy(p)
    }
    
    func Push(inout packet: [Double]){
        processing_push(p, packet, size_t(packet.count))
    }
    
    func SavePreview(inout packet: [Double]){
        processing_save_preview(p, packet, size_t(packet.count))
    }
    
    func Recalculate() {
        processing_recalculate(p)
    }
    
    func buildSmoothStandingWave(inout wave: [Float], inout light: [Float], length: Int, thickness: Float) {
        processing_build_standing_wave(p, &wave, &light, size_t(length), thickness)
    }
    
    func getFrequency() -> Double {
        return processing_get_frequency(p)
    }
    
    func getSubFrequency() -> Double {
        return processing_get_sub_frequency(p)
    }
    
    func setTargetFrequency(frequency: Double) {
        processing_set_target_frequency(p, frequency)
    }
    
    func enableFilter(){
        processing_enable_filter(p)
    }
    
    func disableFilter(){
        processing_disable_filter(p)
    }
}
