//
//  Processing.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 11.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import Foundation
import Acceleration

public func fft(input: [Double]) -> [Double] {
    var real = [Double](input)
    var imaginary = [Double](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)

    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetupD(length, radix)

    vDSP_fft_zipD(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    var magnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))

    var normalizedMagnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_vsmulD(sqrt(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))

    return normalizedMagnitudes
}

struct Complex{
    var real: Double = 0
    var image: Double = 0
}

func *(left: Double, right: Complex) -> Complex {
    return Complex(real: left * right.real, image: left * right.image)
}

func *(left: Complex, right: Double) -> Complex {
    return Complex(real: right * left.real, image: right * left.image)
}

func *(left: Complex, right: Complex) -> Complex {
    return Complex(
        real: left.real * right.real - left.image * right.image,
        image: left.real * right.image + left.image * right.real)
}

func +(left: Complex, right: Complex) -> Complex {
    return Complex(
        real: left.real + right.real,
        image: left.image + right.image)
}

func -(left: Complex, right: Complex) -> Complex {
    return Complex(
        real: left.real - right.real,
        image: left.image -  right.image)
}

func /(left: Complex, right: Double) -> Complex {
    return Complex(real: left.real / right, image: left.image / right)
}

func abs(val: Complex) -> Double {
    return sqrt(val.real * val.real + val.image * val.image)
}

func abs2(val: Complex) -> Double {
    return val.real * val.real + val.image * val.image
}

//
// Computes the discrete Fourier transform (DFT) of the given complex vector, storing the result back into the vector.
// The vector can have any length. This is a wrapper function.
//
func Transform(sequence: [Complex]) -> [Complex] {
    var n = sequence.count

    if n == 0 {
        return []
    } else if ((n & (n - 1)) == 0) {    // Is power of 2
        return TransformRadix2(sequence)
    } else {  // More complicated algorithm for arbitrary sizes
        return TransformBluestein(sequence)
    }
}

//
// Computes the inverse discrete Fourier transform (IDFT) of the given complex vector, storing the result back into the vector.
// The vector can have any length. This is a wrapper function. This transform does not perform scaling, so the inverse is not a true inverse.
//
func InverseTransform(sequence: [Complex]) -> [Complex] {
    return Transform(sequence)
}


//
// Computes the discrete Fourier transform (DFT) of the given complex vector, storing the result back into the vector.
// The vector's length must be a power of 2. Uses the Cooley-Tukey decimation-in-time radix-2 algorithm.
//
func TransformRadix2(var sequence: [Complex]) -> [Complex] {
    var n = sequence.count

    if n == 1 { // Trivial transform
        return [ sequence[0] ]
    }

    var levels = -1

    for i in 0 ..< 32 {
        if (1 << i == n) {
            levels = i;  // Equal to log2(n)
        }
    }

    if levels == -1 {
        //panic("Length is not a power of 2")
    }

    var cosTable = [Double](count: n/2, repeatedValue: 0)
    var sinTable = [Double](count: n/2, repeatedValue: 0)

    for i in 0 ..< n/2 {
        var phi: Double = Double(i) / Double(n)

        cosTable[i] = cos(M_2_PI * phi)
        sinTable[i] = sin(M_2_PI * phi)
    }

    // Bit-reversed addressing permutation
    for i in 0 ..< n {
        var j = reverseBits(i, levels)
        if j > i {
            var tmp = sequence[i]
            sequence[i] = sequence[j]
            sequence[j] = tmp
        }
    }

    // Cooley-Tukey decimation-in-time radix-2 FFT
    for var size = 2; size <= n; size *= 2 {
        var h = size / 2
        var tablestep = n / size

        for var i = 0; i < n; i += size {
            var k = 0
            for var j = i; j < i + h; j++ {

                //var tpre =  real[j+h] * cosTable[k] + imag[j+h] * sinTable[k];
                //var tpim = -real[j+h] * sinTable[k] + imag[j+h] * cosTable[k];

                //fmt.Println(j+h, k, len(sequence), len(cosTable))
                var t = sequence[j+h] * Complex(real: cosTable[k], image: -sinTable[k])

                //real[j + h] = real[j] - tpre;
                //imag[j + h] = imag[j] - tpim;
                //real[j] += tpre;
                //imag[j] += tpim;

                sequence[j+h] = sequence[j] - t
                sequence[j] = sequence[j] + t

                k += tablestep
            }
        }
    }

    return sequence
}

// Returns the integer whose value is the reverse of the lowest 'bits' bits of the integer 'x'.
func reverseBits(var x: Int, bits: Int)  -> Int {
    var y: Int = 0

    for i in 0 ..< bits {
        y = (y << 1) | (x & 1)
        x /= 2
    }

    return y
}


//
// Computes the discrete Fourier transform (DFT) of the given complex vector, storing the result back into the vector.
// The vector can have any length. This requires the convolution function, which in turn requires the radix-2 FFT function.
// Uses Bluestein's chirp z-transform algorithm.
//
func TransformBluestein(sequence: [Complex]) -> [Complex] {
    // Find a power-of-2 convolution length m such that m >= n * 2 + 1
    var n = sequence.count
    var m: Int = 1

    while m < n * 2 + 1 {
        m *= 2
    }

    // Trignometric tables
    var cosTable = [Double](count: n, repeatedValue: 0) // n)
    var sinTable = [Double](count: n, repeatedValue: 0) // n)

    for i in 0 ..< n {
        var j = i * i % (n * 2)  // This is more accurate than j = i * i
        var phi = Double(j) / Double(n)
        cosTable[i] = cos(M_1_PI * phi)
        sinTable[i] = sin(M_1_PI * phi)
    }

    // Temporary vectors and preprocessing
    //var areal = new Array(m);
    //var aimag = new Array(m);

    var a = [Complex](count: m, repeatedValue: Complex()) // m

    for i in 0 ..< n {
        //areal[i] =  real[i] * cosTable[i] + imag[i] * sinTable[i];
        //aimag[i] = -real[i] * sinTable[i] + imag[i] * cosTable[i];

        a[i] = sequence[i] * Complex(real: cosTable[i], image: -sinTable[i])
    }

    for i in n ..< m {
        a[i] = Complex()
    }

    //var breal = new Array(m);
    //var bimag = new Array(m);
    var b = [Complex](count: m, repeatedValue: Complex())  // m

    //breal[0] = cosTable[0];
    //bimag[0] = sinTable[0];
    b[0] = Complex(real: cosTable[0], image: sinTable[0])

    for i in 1 ..< n {
        //breal[i] = breal[m - i] = cosTable[i];
        //bimag[i] = bimag[m - i] = sinTable[i];
        b[m-i] = Complex(real: cosTable[i], image: sinTable[i])
        b[i] = b[n-i]
    }

    for i in n ..< m - n + 1 {
        b[i] = Complex()
    }

    // Convolution
    var c: [Complex] = ConvolveComplex(a, b)

    // Postprocessing
    var result = [Complex](count: n, repeatedValue: Complex())

    for i in 0 ..< n {
        //real[i] =  creal[i] * cosTable[i] - cimag[i] * ( -sinTable[i]);
        //imag[i] = creal[i] * (- sinTable[i]) + cimag[i] * cosTable[i];
        result[i] = c[i] * Complex(real: cosTable[i], image: -sinTable[i])
    }

    return result
}


//
// Computes the circular convolution of the given real vectors. Each vector's length must be the same.
//
//func convolveReal(x, y, out) {
//    zeros := make([]complex128, len(x))
//    for (var i = 0; i < zeros.length; i++)
//        zeros[i] = 0;
//    convolveComplex(x, zeros, y, zeros.slice(0), out, zeros.slice(0));
//}


//
// Computes the circular convolution of the given complex vectors. Each vector's length must be the same.
//
func ConvolveComplex(x: [Complex], y: [Complex]) -> [Complex]{
    var n = x.count

    var result = [Complex](count: n, repeatedValue: Complex()) // n)

    var X = Transform(x)
    var Y = Transform(y)

    for i in 0 ..< n {
        //var temp = xreal[i] * yreal[i] - ximag[i] * yimag[i];
        //ximag[i] = ximag[i] * yreal[i] + xreal[i] * yimag[i];
        //xreal[i] = temp;
        X[i] = X[i] * Y[i]
    }

    InverseTransform(X)

    for i in 0 ..< n {  // Scaling (because this FFT implementation omits it)
        //outreal[i] = xreal[i] / n;
        //outimag[i] = ximag[i] / n;
        result[i] = X[i] / Double(n)
    }

    return result
}

func Complicate(sequence: [Double]) -> [Complex] {
    var result = [Complex](count: sequence.count, repeatedValue: Complex()) //, len(sequence))
    var i = 0

    for r in sequence {
        result[i] = Complex(real: r, image: 0)
        i = i + 1
    }

    return result
}
