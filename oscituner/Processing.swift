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
    let minFrequency: Double = 20
    let maxFrequency: Double = 20000
    let discreteFrequency: Double = 44100.0
    let discreteTime: Double = 1.0 / 44100.0

    var frequency: Double = 440
    var leftFrequency: Double = 400
    var rightFrequency: Double = 500

    var figurePointCount: Int = 256

    var samples: [Double] = [Double]()

    var doubleWave: [Double] = [Double]()
    
    var doubleWaveFftSetup: FFTSetup?

    init(){
        samples = [Double](count: Int(4 * discreteFrequency / minFrequency), repeatedValue: 0)
        samples.reserveCapacity(samples.count*2)
        setFrequency(440)
    }

    func buildSpectrum() -> [Double] {
        var sample = buildSample()
        var spectrum = [Double]() //fft(sample)

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


    func buildSpectrumForFrequency() -> [Double] {
        var result = [Double](count: figurePointCount, repeatedValue: 0)
        var spectrum = buildSpectrum()

        var i = 0
        for  r in result {
            var f = leftFrequency + (rightFrequency - leftFrequency) * Double(i) / Double(figurePointCount - 1)
            result[i] = getValueAtFrequency(f, spectrum: spectrum)
        }

        return result
    }

    func getValueAtFrequency(f: Double, spectrum: [Double]) -> Double {
        var df: Double = Double(1.0) / (Double(spectrum.count) * discreteTime)
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
        //NSLog(" %i ", samples.count)
        //NSLog(" %i  ", sample.count)
        
        samples += sample
        samples.removeRange(Range(start: 0, end: sample.count))
        
        doubleWave += sample
        doubleWave.removeRange(Range(start: 0, end: sample.count))
    }

    func buildSample() -> [Double] {
        return samples
    }

    func setFrequency(var newFrequency: Double) {
        
        if newFrequency < minFrequency {
            newFrequency = minFrequency
        }

        if newFrequency > maxFrequency {
            newFrequency = maxFrequency
        }

        frequency = newFrequency

        var lengthExp: Int = Int(floor(log2(period() / discreteTime)))
        var length: Int = Int(pow(2, Double(lengthExp)))
        doubleWave = [Double](samples[0 ..< length])
        
        if doubleWaveFftSetup != nil {
            destroy_fftsetup(doubleWaveFftSetup!)
            doubleWaveFftSetup = nil
        }
        
        
        doubleWaveFftSetup = create_fftsetupD(vDSP_Length(lengthExp), FFTRadix(kFFTRadix2))
    }

    func buidStandingWaveForFrequency(f0: Double) -> [Double] {
        
        /* func vDSP_fft_zrip(_ __vDSP_setup: FFTSetup,
            _ __vDSP_ioData: UnsafePointer<DSPSplitComplex>,
            _ __vDSP_stride: vDSP_Stride,
            _ __vDSP_Log2N: vDSP_Length,
            _ __vDSP_direction: FFTDirection) */
        
        
        
        var store = DSPSplitComplex(realp: <#UnsafeMutablePointer<Float>#>, imagp: <#UnsafeMutablePointer<Float>#>)
        
        fft_zrip(doubleWaveFftSetup, <#__vDSP_C: UnsafePointer<DSPSplitComplex>#>, <#__vDSP_IC: vDSP_Stride#>, <#__vDSP_Log2N: vDSP_Length#>, <#__vDSP_Direction: FFTDirection#>)

        return approximate([Double](doubleWave[offsetOpt ..< (offsetOpt + length)]), count: figurePointCount)
    }

    func approximate(source: [Double], count: Int) -> [Double] {
        var result = [Double](count: count, repeatedValue: 0)
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

            result[i] = a * t * t + b * t + c
            i = i + 1
        }
        
        return result
    }

    func period() -> Double {
        return 1.0 / frequency
    }
}
