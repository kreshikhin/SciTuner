//
//  processing.c
//  oscituner
//
//  Created by Denis Kreshikhin on 29.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

#include "processing.h"

#include <stdlib.h>
#include <math.h>
#include <string.h> /* memset */
#include <unistd.h> /* close */

void approximate(double* dest, const double* src, size_t destLength, size_t srcLength);
int get_freq_code(double freq);
double get_code_freq(int code);


void source_generate(double* dest, size_t count, double* t, double dt, double freq){
    for(int i = 0; i < count ; i++){
        *t = *t + dt;
        dest[i] = 1.0 * sin(2 * M_PI * freq * (*t) + rand() / 100) + 1.0 * (rand() - 0.5);
    }
}

Processing* processing_create(){
    return malloc(sizeof(Processing));
}

void processing_destroy(Processing* p){
    free(p);
}

void processing_init(Processing* p, double fd, double fMin, size_t pointCount) {
    p->fd = fd;
    p->fMin = fMin;
    p->signalLength = ceil2((double)pointCount);
    p->step = 1;

    p->signal = malloc(p->signalLength * sizeof(*p->signal));

    memset(p->signal, 0, p->signalLength * sizeof(*p->signal));

    p->real = malloc(p->signalLength * sizeof(*p->real));
    p->imag = malloc(p->signalLength * sizeof(*p->imag));
    
    p->spectrum = malloc(p->signalLength * sizeof(*p->spectrum));
}

void processing_deinit(Processing* p){
    free(p->signal);
    free(p->real);
    free(p->imag);
    free(p->spectrum);
}

void processing_push(Processing* p, const double* packet, size_t packetLength) {
    int shift = p->signalLength - packetLength;
    
    if(shift <= 0) {
        memcpy(p->signal,
               packet - shift,
               p->signalLength * sizeof(*p->signal));
        
        return;
    }

    memmove(p->signal,
            p->signal + packetLength,
            shift * sizeof(*p->signal));
    
    memcpy(p->signal + shift,
           packet,
           packetLength * sizeof(*p->signal));
}

void processing_recalculate(Processing* p){
    memcpy(p->real, p->signal, p->signalLength * sizeof(*p->signal));
    memset(p->imag, 0, p->signalLength* sizeof(*p->signal));

    transform_radix2(p->real, p->imag, p->signalLength);
    
    double peak = 0;
    for(int i = 1; i < p->signalLength / 2; i ++){
        double s = p->real[i] * p->real[i] + p->imag[i] * p->imag[i];
        p->spectrum[i] = s;
        
        if (s > peak) {
            peak = s;
            p->peakFrequency = p->fd * i * 0.5 / p->signalLength;
        }
    }
    
    if (peak == 0) {
        peak = 1.0;
    }
    
    for (int i = 0; i < p->signalLength; i ++) {
        p->spectrum[i] /= peak;
    }
    
    //printf("preak freq: %f Hz \n", p->peakFrequency);
}


void processing_build_standing_wave(Processing* p, double* wave, size_t length){
    memcpy(wave, p->signal, length * sizeof(*wave));
}

void processing_build_build_power_spectrum(Processing* p, double* spectrum, size_t length){
    int code = get_freq_code(p->peakFrequency);
    
    double left = get_code_freq(code - 2);
    double right = get_code_freq(code + 2);
    
    size_t leftIndex = left * p->signalLength * 2 / p->fd;
    size_t rightIndex = right * p->signalLength * 2/ p->fd;

    //printf("freq range: %f %f Hz \n", left, right);

    approximate(spectrum, p->spectrum + leftIndex, length, rightIndex - leftIndex);
}

double processing_get_frequency(Processing* p){
    return p->peakFrequency;
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
