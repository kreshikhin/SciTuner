//
//  dspmath.h
//  SciTuner
//
//  Created by Denis Kreshikhin on 06.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

#include "dspmath.h"

double get_phase(double x, double y){
    if(!x && !y) return 0;
    
    return atan2(y, x) + M_PI;
}

void source_generate(double* dest, size_t count, double* t, double dt, double freq){
    for(int i = 0; i < count ; i++){
        *t = *t + dt;
        
        double r1 = (double)rand() / (100.0 * RAND_MAX);
        double r2 = 1.0 * ((double)rand() / (RAND_MAX) - 0.5);
        dest[i] = 1.0 * sin(2.0 * M_PI * freq * (*t) + r1) + r2;
    }
}

int get_freq_code(double freq){
    return round(12.0 * log2(freq / 261.63)) + 58;
}

double get_code_freq(int code){
    return pow(2.0, (code - 58.0) / 12.0) * 261.63;
}

void approximate(double* dest, const double* src, size_t destLength, size_t srcLength) {
    double factor = srcLength;
    factor /= (double)destLength;
    
    for(size_t i = 0; i < destLength; i++) {
        double index = 0;
        double t = 0;
        t = modf((double)i * factor, &index);
        
        size_t current = index;
        size_t next = index < srcLength ? index + 1 : srcLength - 1;
        size_t prev = index > 0 ? index - 1 : 0;
        
        double c = src[current];
        double b = src[current] - src[prev];
        double a = src[next] - c - b;
        
        dest[i] = a * t * t + b * t + c;
    }
}


double sinc(double t){
    if(!t) return 1.0;
    
    return sin(t) / t;
}

void approximate_sinc(double* dest, const double* src, size_t destLength, size_t srcLength) {
    double factor = srcLength;
    factor /= (double)destLength;
    
    for(size_t i = 0; i < destLength; i++) {
        double index = 0;
        double t = 0;
        t = modf((double)i * factor, &index);
        
        size_t current = index;
        size_t next = index < srcLength ? index + 1 : srcLength - 1;
        size_t next2 = index < srcLength - 1 ? index + 2 : srcLength - 1;
        size_t prev = index > 0 ? index - 1 : 0;
        size_t prev2 = index + 1 > 0 ? index - 2 : 0;
        
        dest[i] = src[prev2] * sinc(M_PI * (t + 2.0));
        dest[i] += src[prev] * sinc(M_PI * (t + 1.0));
        dest[i] += src[current] * sinc(M_PI * t);
        dest[i] += src[next] * sinc(M_PI * (t - 1.0));
        dest[i] += src[next2] * sinc(M_PI * (t - 2.0));
    }
}

void expend2(double* data, size_t length) {
    for(size_t j = 0; j < length - 1; j++) {
        size_t i = (length - 1) - j;
        double index = 0;
        double t = 0;
        t = modf((double)i * 0.5, &index);
        
        size_t current = index;
        size_t next = index < length / 2 ? index + 1 : length / 2 - 1;
        size_t next2 = index < length / 2 - 1 ? index + 2 : length / 2 - 1;
        size_t prev = index > 0 ? index - 1 : 0;
        size_t prev2 = index + 1 > 0 ? index - 2 : 0;
        
        data[i] = data[prev2] * sinc(M_PI * (t + 2.0));
        data[i] += data[prev] * sinc(M_PI * (t + 1.0));
        data[i] += data[current] * sinc(M_PI * t);
        data[i] += data[next] * sinc(M_PI * (t - 1.0));
        data[i] += data[next2] * sinc(M_PI * (t - 2.0));
    }
}

int transform_radix2(double real[], double imag[], size_t n) {
    int status = 0;
    unsigned int levels;
    double *cos_table, *sin_table;
    size_t size;
    size_t i;
    
    // Compute levels = floor(log2(n))
    {
        size_t temp = n;
        levels = 0;
        while (temp > 1) {
            levels++;
            temp >>= 1;
        }
        if (1u << levels != n)
            return 0;  // n is not a power of 2
    }
    
    // Trignometric tables
    size = (n / 2) * sizeof(double);
    cos_table = malloc(size);
    sin_table = malloc(size);
    
    if (cos_table == NULL || sin_table == NULL)
        goto cleanup;
    
    for (i = 0; i < n / 2; i++) {
        cos_table[i] = cos(2 * M_PI * i / n);
        sin_table[i] = sin(2 * M_PI * i / n);
    }
    
    // Bit-reversed addressing permutation
    for (i = 0; i < n; i++) {
        size_t j = reverse_bits(i, levels);
        if (j > i) {
            double temp = real[i];
            real[i] = real[j];
            real[j] = temp;
            temp = imag[i];
            imag[i] = imag[j];
            imag[j] = temp;
        }
    }
    
    // Cooley-Tukey decimation-in-time radix-2 FFT
    for (size = 2; size <= n; size *= 2) {
        size_t halfsize = size / 2;
        size_t tablestep = n / size;
        
        for (i = 0; i < n; i += size) {
            size_t j;
            size_t k;
            
            for (j = i, k = 0; j < i + halfsize; j++, k += tablestep) {
                double tpre =  real[j+halfsize] * cos_table[k] + imag[j+halfsize] * sin_table[k];
                double tpim = -real[j+halfsize] * sin_table[k] + imag[j+halfsize] * cos_table[k];
                
                real[j + halfsize] = real[j] - tpre;
                imag[j + halfsize] = imag[j] - tpim;
                
                real[j] += tpre;
                imag[j] += tpim;
            }
        }
        
        if (size == n)  // Prevent overflow in 'size *= 2'
            break;
    }
    
    status = 1;
    
cleanup:
    free(cos_table);
    free(sin_table);
    return status;
}

size_t reverse_bits(size_t x, unsigned int n) {
    size_t result = 0;
    unsigned int i;
    
    for (i = 0; i < n; i++, x >>= 1)
        result = (result << 1) | (x & 1);
    
    return result;
}

size_t ceil2(double value){
    int shift = ceil(log2(value));
    size_t result = 1 << shift;
    return result;
}