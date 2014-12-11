//
//  Processing.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 11.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import Foundation


struct Complex{
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
func TransformRadix2(sequence: [Complex]) -> [Complex] {
    var n = sequence.count
    
    if n == 1 { // Trivial transform
        return [ sequence[0] ]
    }
    
    var levels = -1
    
    for var i = 0; i < 32; i++ {
        if (1 << i == n) {
            levels = i;  // Equal to log2(n)
        }
    }
    
    if levels == -1 {
        //panic("Length is not a power of 2")
    }
    
    var cosTable = [] //, n / 2)
    var sinTable = [] //n / 2)
    
    for var i = 0; i < n / 2; i++ {
        phi = Float(i) / n
        cosTable[i] = cos(M_2_PI * phi)
        sinTable[i] = sin(M_2_PI * phi)
    }
    
    // Bit-reversed addressing permutation
    for var i = 0; i < n; i++ {
        var j = reverseBits(i, levels)
        if j > i {
            swap(&sequence[j], &sequence[i])
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
                var t = sequence[j+h] * Complex(cosTable[k], -sinTable[k])
                
                //real[j + h] = real[j] - tpre;
                //imag[j + h] = imag[j] - tpim;
                //real[j] += tpre;
                //imag[j] += tpim;
                
                sequence[j+h] = sequence[j] - t
                sequence[j] += t
                
                k += tablestep
            }
        }
    }
    
    return sequence
}

// Returns the integer whose value is the reverse of the lowest 'bits' bits of the integer 'x'.
func reverseBits(x, bits int) int {
    var y int = 0
    for i := 0; i < bits; i++ {
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
func TransformBluestein(sequence []complex128) []complex128 {
    // Find a power-of-2 convolution length m such that m >= n * 2 + 1
    n := len(sequence)
    m := 1
    
    for m < n * 2 + 1 {
        m *= 2
        }
        
        // Trignometric tables
        cosTable := make([]float64, n)
    sinTable := make([]float64, n)
    
    for i := 0; i < n; i++ {
        j := i * i % (n * 2)  // This is more accurate than j = i * i
        phi := float64(j) / float64(n)
        cosTable[i] = math.Cos(math.Pi * phi)
        sinTable[i] = math.Sin(math.Pi * phi)
    }
    
    // Temporary vectors and preprocessing
    //var areal = new Array(m);
    //var aimag = new Array(m);
    
    a := make([]complex128, m)
    for i := 0; i < n; i++ {
        //areal[i] =  real[i] * cosTable[i] + imag[i] * sinTable[i];
        //aimag[i] = -real[i] * sinTable[i] + imag[i] * cosTable[i];
        
        a[i] = sequence[i] * complex(cosTable[i], - sinTable[i])
    }
    
    for i := n; i < m; i++ {
        a[i] = 0
    }
    
    //var breal = new Array(m);
    //var bimag = new Array(m);
    b := make([]complex128, m)
    
    //breal[0] = cosTable[0];
    //bimag[0] = sinTable[0];
    b[0] = complex(cosTable[0], sinTable[0])
    
    for i := 1; i < n; i++ {
        //breal[i] = breal[m - i] = cosTable[i];
        //bimag[i] = bimag[m - i] = sinTable[i];
        b[m-i] = complex(cosTable[i], sinTable[i])
        b[i] = b[n-i]
    }
    
    for i:= n; i <= m - n; i++ {
        b[i] = 0;
    }
    
    // Convolution
    c := ConvolveComplex(a, b)
    
    // Postprocessing
    result := make([]complex128, n)
    
    for i := 0; i < n; i++ {
        //real[i] =  creal[i] * cosTable[i] - cimag[i] * ( -sinTable[i]);
        //imag[i] = creal[i] * (- sinTable[i]) + cimag[i] * cosTable[i];
        result[i] =  c[i] * complex(cosTable[i], - sinTable[i])
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
func ConvolveComplex(x, y []complex128) []complex128{
    n := len(x)
    
    result := make([]complex128, n)
    
    X := Transform(x)
    Y := Transform(y)
    
    for i := 0; i < n; i++ {
        //var temp = xreal[i] * yreal[i] - ximag[i] * yimag[i];
        //ximag[i] = ximag[i] * yreal[i] + xreal[i] * yimag[i];
        //xreal[i] = temp;
        X[i] = X[i] * Y[i]
    }
    
    InverseTransform(X)
    
    for i := 0; i < n; i++ {  // Scaling (because this FFT implementation omits it)
        //outreal[i] = xreal[i] / n;
        //outimag[i] = ximag[i] / n;
        result[i] = X[i] / complex(float64(n), 0)
    }
    return result
}

func Complicate(sequence []float64) []complex128{
    result := make([]complex128, len(sequence))
    for i, r := range sequence {
        result[i] = complex(r, 0)
    }
    
    return result
}