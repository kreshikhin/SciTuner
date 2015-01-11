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
    
    init(){
        processing_init(p, 44100, 16, 32768)
    }
    
    deinit{
        processing_deinit(p)
        processing_destroy(p)
    }
    
    func Push(inout packet: [Double]){
        processing_push(p, packet, UInt(packet.count))
    }
    
    func Recalculate() {
        processing_recalculate(p)
    }
    
    func buildStandingWave(inout wave: [Float], length: Int) {
        processing_build_standing_wave(p, &wave, UInt(length))
    }
    
    func buildSpectrumWindow(inout spectrum: [Float], length: Int) {
        processing_build_build_power_spectrum(p, &spectrum, UInt(length))
    }
    
    func getFrequency() -> Double {
        return processing_get_frequency(p)
    }
}
