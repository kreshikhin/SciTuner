//
//  Processing.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import Foundation

class Processing{
    var Fmin: Double = 10
    var Fmax: Double = 400
    var Count: Int = 256
    var Td: Double = 1.0 / 44100.0
    var samples: [Double] = [Double](count: 8192, repeatedValue: 0)
    var lastSample: [Double] = [Double](count: 882, repeatedValue: 0)
    var CurrentPosition: Int = 0

    func BuildSpectrum() -> [Double] {
        var sample = buildSample()
        var spectrum: [Complex] = Transform(Complicate(sample))
        //spectrum := fft.FFTReal(sample)
        var powerSpectrum = [Double](count: spectrum.count, repeatedValue: 0)
    
        var powerMax: Double = 1.0
        
        var i = 0
        for s in spectrum {
            powerSpectrum[i] = abs(s) * abs(s)
            
            if powerMax < powerSpectrum[i] {
                powerMax = powerSpectrum[i]
            }
            
            i = i + 1
        }
    
        i = 0
        for s in powerSpectrum {
            powerSpectrum[i] = s / powerMax
        }
    
        return powerSpectrum
    }


    func BuildSpectrumForFrequency() -> [Double] {
        var result = [Double](count:Count, repeatedValue: 0)
        var spectrum = BuildSpectrum()
    
        var i = 0
        for  r in result {
            var f = Fmin + (Fmax - Fmin) * Double(i) / Double(Count - 1)
            result[i] = getValueAtFrequency(f, spectrum: spectrum)
        }
    
        return result
    }

    func getValueAtFrequency(f: Double, spectrum: [Double]) -> Double {
        var df: Double = Double(1.0) / (Double(spectrum.count) * Td)
        var position: Double = f / df
    
        var index0 = Int(ceil(position))
        var index1 = Int(floor(position))
        var s0 = spectrum[index0]
        var s1 = spectrum[index1]
        
        if index0 != index1 {
            var k0 = (Double(index0) * df - f) / df
            var k1 = (Double(index1) * df - f) / df
            var s = s0 * sin(M_1_PI * k0) / k0 + s1 * sin(M_1_PI * k1) / k1
        
            //return (s0 + s1) / 3.0
            return s / 5.0
        }
    
        return s0 / 3.0
    }

    func Push(sample: [Double]) {
        lastSample = sample
        for s in sample{
            samples[CurrentPosition] = s
            CurrentPosition = (CurrentPosition + 1) % samples.count
        }
    }

    func buildSample() -> [Double] {
        return samples
    }

    func BuidStandingWaveForFrequency(f0: Double) -> [Double] {
        var vOpt: Double = 0
        var offsetOpt: Int = 0
    
        var ti: Double = 1.0 / f0
        var length: Int = Int(ti / Td)
        
        for offset in 0 ..< length {
            var v: Double = 0
            var t: Double = 0
            for i in offset ..< offset+length {
                var s = lastSample[i]
                v = v + sin(M_2_PI * t / ti) * s
                t = t + Td
            }
        
            if v > vOpt {
                offsetOpt = offset
                vOpt = v
            }
        }
    
        return [Double](lastSample[offsetOpt ..< (offsetOpt + Count)])
    }

}