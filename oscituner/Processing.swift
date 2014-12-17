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

    var frequency: Double = 440

    var leftFrequency: Double = 400
    var rightFrequency: Double = 500

    var figurePointCount: Int = 256

    var samples: [Double] = [Double]()

    var doubleWave: [Double] = [Double]()

    var doubleWaveFftSetup: FFTSetup?
    var samplesFftSetup: FFTSetup?

    init(){
        samples = [Double](count: Int(4 * discreteFrequency / minFrequency), repeatedValue: 0)
        samples.reserveCapacity(samples.count*2)
        setFrequency(440)
    }

    func buildSpectrum() -> [Double] {
        var realPart = [Float](samples)
        var imagPart = [Float](count: samples.count, repeatedValue: 0)

        var signal = DSPSplitComplex(
            realp: UnsafeMutablePointer<Float>(realPart),
            imagp: UnsafeMutablePointer<Float>(imagPart))

        fft_zrip(
            samplesFftSetup,
            signal,
            vDSP_Stride(1),
            samples.count,
            FFTDirection(kFFTDirection_Forward))

        var powerSpectrum = [Double](count: samples.count, repeatedValue: 0)

        zaspec(
            signal,
            UnsafeMutablePointer(powerSpectrum),
            samples.count
        )

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
        var df: Double = discreteFrequency / Double(spectrum.count))
        var position: Double = f / df

        var index0 = Int(ceil(position))
        var index1 = Int(floor(position))
        var s0 = spectrum[index0]
        var s1 = spectrum[index1]

        if index0 != index1 {
            var k0 = (Double(index0) * df - f) / df
            var k1 = (Double(index1) * df - f) / df
            var s = s0 * sin(M_1_PI * k0) / k0 + s1 * sin(M_1_PI * k1) / k1

            return s / 5.0
        }

        return s0 / 3.0
    }

    func Push(sample: [Double]) {
        samples += sample
        samples.removeRange(Range(start: 0, end: sample.count))

        doubleWave += sample
        doubleWave.removeRange(Range(start: 0, end: sample.count))
    }

    func setFrequency(var newFrequency: Double) {

        if newFrequency < minFrequency {
            newFrequency = minFrequency
        }

        if newFrequency > maxFrequency {
            newFrequency = maxFrequency
        }

        frequency = newFrequency

        var length: Int
        var dspLength: Int

        (dspLength, length) = log2length(discreteFrequency / frequency)

        doubleWave = [Double](samples[0 ..< length])

        if doubleWaveFftSetup != nil {
            destroy_fftsetup(doubleWaveFftSetup!)
            doubleWaveFftSetup = nil
        }


        doubleWaveFftSetup = create_fftsetupD(vDSP_Length(dspLength), FFTRadix(kFFTRadix2))
    }

    func buidStandingWaveForFrequency(f0: Double) -> [Double] {
        var realPart = [Float](doubleWave)
        var imagPart = [Float](count: doubleWave.count, repeatedValue: 0)

        var signal = DSPSplitComplex(
            realp: UnsafeMutablePointer<Float>(realPart),
            imagp: UnsafeMutablePointer<Float>(imagPart))

        fft_zrip(
            doubleWaveFftSetup,
            signal,
            vDSP_Stride(1),
            doubleWave.count,
            FFTDirection(kFFTDirection_Forward))

        var index, frac, x, y: Float

        index, frac = modf(0.5 * frequency / discreteFrequency)

        if index < length / 2 {
            var index0 = Int(ceil(index))
            var index1 = Int(floor(index))
            x = (1 - frac) * realPart[index0] + frac * realPart[index1]
            y = (1 - frac) * imagPart[index0] + frac * imagPart[index1]
        } else {
            x = realPart[index]
            y = imagPart[index]
        }

        var phase = atan2(x, y) + M_1_PI / 2

        var periodLength: Double = discreteFrequency / frequency
        var offset: Int = Int(periodLength * phase / M_2_PI)

        return approximate([Double](doubleWave[offset ..< offset + Int(length)]), count: figurePointCount)
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

    func log2length(time: Double) -> (Int, Int) {
        var lengthExp: Int = Int(floor(log2(time))) + 1
        var length: Int = Int(pow(2, Double(lengthExp)))

        return (lengthExp, length)
    }
}
