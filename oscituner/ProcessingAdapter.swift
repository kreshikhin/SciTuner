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
    
    func buildStandingWave(length: Int) -> [Double] {
        var wave = [Double](count: length, repeatedValue: 0)
        processing_build_standing_wave(p, &wave, UInt(length))
        return wave
    }
    
    func buildSpectrumWindow(length: Int) -> [Double] {
        var spectrum = [Double](count: length, repeatedValue: 0)
        processing_build_build_power_spectrum(p, &spectrum, UInt(length))
        return spectrum
    }
    
    func getFrequency() -> Double {
        return processing_get_frequency(p)
    }
/*
    let minFrequency: Double = 20
    let maxFrequency: Double = 20000
    
    var discreteFrequency: Double = 44100.0

    var frequency: Double = 440

    var leftFrequency: Double = 300
    var rightFrequency: Double = 500

    var figurePointCount: Int = 256
    
    
    var samples: [Float]
    var spectrumRealPart: [Float]
    var spectrumImagePart: [Float]
    var spectrum: DSPSplitComplex
    var powerSpectrum: [Float]
    
    var fftSetup: FFTSetup?
    
    var log2Length: vDSP_Length
    
    init(sampleRate: Int, sampleCount: Int){
        discreteFrequency = Double(sampleRate)
        
        samples = [Float](count: sampleCount, repeatedValue: 0)
        
        spectrumRealPart = [Float](count: sampleCount, repeatedValue: 0)
        spectrumImagePart = [Float](count: sampleCount, repeatedValue: 0)
        
        spectrum = DSPSplitComplex(realp: &spectrumRealPart, imagp: &spectrumImagePart)
        
        powerSpectrum = [Float](count: sampleCount, repeatedValue: 0)
        
        log2Length = vDSP_Length(Processing.log2count(sampleCount))
        
        fftSetup = create_fftsetupD(log2Length, FFTRadix(kFFTRadix2))
        
        setFrequency(440)
    }
    
    deinit{
        destroy_fftsetup(fftSetup!)
    }


    func buildSpectrumWindow(count: Int) -> [Float] {
        var result = [Float](count: count, repeatedValue: 0)
        
        var i = 0
        for r in result {
            var f = leftFrequency + (rightFrequency - leftFrequency) * Double(i) / Double(count - 1)
            result[i] = getValueAtFrequency(f)
            
            //NSLog(" %f ", getValueAtFrequency(f))
            i++
        }

        return result
    }

    func getValueAtFrequency(f: Double) -> Float {
        var df: Double = discreteFrequency / Double(powerSpectrum.count)
        var position: Double = f / df

        
        var index0 = Int(ceil(position))
        var index1 = Int(floor(position))
        var s0 = Double(powerSpectrum[index0])
        var s1 = Double(powerSpectrum[index1])
        
        
        //NSLog(" %f %f %f ", position, s0, s1)

        if index0 != index1 {
            var k0 = (Double(index0) * df - f) / df
            var k1 = (Double(index1) * df - f) / df
            var s = s0 * sin(M_1_PI * k0) / k0 + s1 * sin(M_1_PI * k1) / k1

            return Float(s)
        }

        return Float(s0)
    }

    func Push(samples: [Float]) {
        self.samples = samples
    }
    
    func Recalculate() {
        spectrumRealPart = samples
        spectrumImagePart = [Float](count: samples.count, repeatedValue: 0)
        
        powerSpectrum = [Float](count: samples.count, repeatedValue: 0)
        
        spectrum = DSPSplitComplex(realp: &spectrumRealPart, imagp: &spectrumImagePart)
        
        var fs = create_fftsetup(12, FFTRadix(kFFTRadix2))
        fft_zip(fs, &spectrum, vDSP_Stride(1), 12, FFTDirection(kFFTDirection_Forward))
        
        vDSP_zaspec(&spectrum, &powerSpectrum, vDSP_Length(samples.count))
        
        //var powerPick: [Float] = [0, 1]
        //vDSP_maxv(&powerPick, vDSP_Stride(1), &powerSpectrum, vDSP_Length(powerSpectrum.count))
        
        
        var peak = Float(0)
        
        var i = 0
        for p in powerSpectrum {
            if peak < p {
                peak = p
            }
            i++
        }
        
        i = 0
        for p in powerSpectrum {
            powerSpectrum[i] = p / peak
            i++
        }
        
        destroy_fftsetup(fs)
    }

    func setFrequency(var newFrequency: Double) {

        if newFrequency < minFrequency {
            newFrequency = minFrequency
        }

        if newFrequency > maxFrequency {
            newFrequency = maxFrequency
        }

        frequency = newFrequency
    }

    func buidStandingWave() -> [Float] {
        var index: Float
        var frac: Float
        var x: Float
        var y: Float

        (index, frac) = modf(Float( 0.5 * frequency / discreteFrequency))

        if index < Float(samples.count) / 2 {
            var index0 = Int(ceil(index))
            var index1 = Int(floor(index))
            x = (1 - frac) * spectrumRealPart[index0] + frac * spectrumRealPart[index1]
            y = (1 - frac) * spectrumImagePart[index0] + frac * spectrumImagePart[index1]
        } else {
            x = spectrumRealPart[Int(index)]
            y = spectrumImagePart[Int(index)]
        }

        var phase = atan2f(x, y)
        var periodLength: Float = Float(discreteFrequency / frequency)
        var offset: Int = Int(periodLength + periodLength * phase / Float(2 * M_PI))

        return approximate([Float](samples[offset ..< offset + Int(periodLength)]), count: figurePointCount)
    }

    func approximate(source: [Float], count: Int) -> [Float] {
        var result = [Float](count: count, repeatedValue: 0)
        var factor: Double = Double(source.count) / Double(result.count)

        var i: Int = 0
        for r in result {
            var index: Double
            var t: Double
            (index, t) = modf(Double(i) * factor)

            var current = Int(index)
            var next = current + 1
            var prev = current - 1

            if prev < 0 {
                prev = 0
            }

            if next >= source.count {
                next = source.count - 1
            }

            var c = source[current]
            var b = source[current] - source[prev]
            var a = source[next] - c - b

            result[i] = a * Float(t * t) + b * Float(t) + c
            
            i = i + 1
        }

        return result
    }

    class func log2length(time: Double) -> (Int, Int) {
        var lengthExp: Int = Int(floor(log2(time))) + 1
        var length: Int = Int(pow(2, Double(lengthExp)))

        return (lengthExp, length)
    }
    
    class func log2count(count: Int) -> Int {
        var p: Double = ceil(log2(Double(count)))
        return Int(p)
    }
*/
}
