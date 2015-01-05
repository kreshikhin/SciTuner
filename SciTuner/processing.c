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

void processing_detect_freq_and_phase(Processing* p, double peakFrequency);
void processing_detect_freq_and_phase2(Processing* p, double peakFrequency);

void approximate(double* dest, const double* src, size_t destLength, size_t srcLength);
void approximate_sinc(double* dest, const double* src, size_t destLength, size_t srcLength);

int get_freq_code(double freq);
double get_code_freq(int code);
double sinc(double t);

void expend2(double* data, size_t length);

void source_generate(double* dest, size_t count, double* t, double dt, double freq){
    for(int i = 0; i < count ; i++){
        *t = *t + dt;
        
        double r1 = (double)rand() / (100.0 * RAND_MAX);
        double r2 = 1.0 * ((double)rand() / (RAND_MAX) - 0.5);
        dest[i] = 1.0 * sin(2.0 * M_PI * freq * (*t) + r1) + r2;
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
    
    p->fs = vDSP_create_fftsetupD(log2(p->signalLength), kFFTRadix2);
}

void processing_deinit(Processing* p){
    vDSP_destroy_fftsetupD(p->fs);
    free(p->signal);
    free(p->real);
    free(p->imag);
    free(p->spectrum);
}

void processing_push(Processing* p, const double* packet, size_t packetLength) {
    long int shift = p->signalLength - packetLength;
    
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

    DSPDoubleSplitComplex spectrum = {p->real, p->imag};
    
    vDSP_fft_zipD(p->fs, &spectrum, 1, log2(p->signalLength), kFFTDirection_Forward);
    
    expend2(p->real, p->signalLength);
    expend2(p->imag, p->signalLength);
    
    memset(p->spectrum, 0, p->signalLength * sizeof(*p->spectrum));
    
    vDSP_zaspecD(&spectrum, p->spectrum, p->signalLength);
    
    //transform_radix2(p->real, p->imag, p->signalLength);
    
    double peak = 0;
    double peakFrequency = 0;
    for(int i = 1; i < p->signalLength / 2; i ++){
        if (p->spectrum[i] > peak) {
            peak = p->spectrum[i];
            peakFrequency = p->fd * i * 0.5 / p->signalLength;
        }
    }
    
    if (peak == 0) {
        peak = 1.0;
    }
    
    for (int i = 0; i < p->signalLength; i ++) {
        p->spectrum[i] /= peak;
    }
    
    processing_detect_freq_and_phase2(p, peakFrequency);
}


void processing_build_standing_wave(Processing* p, float* wave, size_t length){
    double* src = &p->signal[p->signalLength - length / 2];
    
    double peak = 0;
    for (int i = 0; i < length; i+=2) {
        double s = abs(src[i/2]);
        if(s > peak){
            peak = s;
        }
    }
    
    if (peak == 0) {
        peak = 1.0;
    }
    
    //printf("peak %f \n", peak);
    
    for(int i = 0; i < length; i+=2){
        wave[i] = ((double)i / length - 0.5) * 1.9;
        wave[i + 1] = src[i/2] / peak - 0.4;
    }
}

void processing_build_build_power_spectrum(Processing* p, float* spectrum, size_t length){
    int code = get_freq_code(p->peakFrequency);
    
    double left = get_code_freq(code - 2);
    double right = get_code_freq(code + 2);
    
    size_t leftIndex = 2 * left * p->signalLength / p->fd;
    size_t rightIndex = 2 * right * p->signalLength / p->fd;

    //printf("freq range: %f %f Hz \n", left, right);

    double* dest = (double*)spectrum;
    
    approximate_sinc(dest, p->spectrum + leftIndex, length/2, rightIndex - leftIndex);
    for(int i = 0; i < length; i+=2){
        double s = dest[i/2];
        spectrum[i] = ((double)i / length - 0.5) * 1.9;
        spectrum[i+1] = s / 2.0 + 0.4;
    }
    
    /*int l = p->signalLength / 8;
    int f = l * 2 / length;
    for(int i = 0; i < l; i++){
        int j = i / f;
        if (i % f == 0) {
            spectrum[2*j + 1] = 0.4;
        }
        
        double s = p->spectrum[i];
        spectrum[2*j] = ((double)j * 2/ length - 0.5) * 1.9;
        spectrum[2*j+1] += s / (2.0 * f);
    }*/
}

double processing_get_frequency(Processing* p){
    return p->peakFrequency;
}

void processing_detect_freq_and_phase(Processing* p, double peakFrequency){
    double* real = p->real;
    double* imag = p->imag;
    size_t length = p->signalLength;
    
    size_t index = peakFrequency * length / p->fd;
    size_t next = index < length ? index + 1 : length - 1;
    size_t next2 = index < length - 1 ? index + 2 : length - 1;
    size_t prev = index > 0 ? index - 1 : 0;
    size_t prev2 = index + 1 > 0 ? index - 2 : 0;
    
    double peak = 0;
    double df0 = 0;
    
    for(int i = -100; i < 100; i++){
        double df = (double)i / 100;
        
        double re = 0;
        re += real[prev2] * sinc(M_PI * (df + 2.0));
        re += real[prev] * sinc(M_PI * (df + 1.0));
        re += real[index] * sinc(M_PI * df);
        re += real[next] * sinc(M_PI * (df - 1.0));
        re += real[next2] * sinc(M_PI * (df - 2.0));
    
        double im = 0;
        im += imag[prev2] * sinc(M_PI * (df + 2.0));
        im += imag[prev] * sinc(M_PI * (df + 1.0));
        im += imag[index] * sinc(M_PI * df);
        im += imag[next] * sinc(M_PI * (df - 1.0));
        im += imag[next2] * sinc(M_PI * (df - 2.0));
        
        double s = re * re + im * im;
        if(s > peak){
            peak = s;
            df0 = df * p->fd * 2 / p->signalLength;
        }
    }
    p->peakFrequency = peakFrequency + df0;
    
    printf(" F ~ %f       %f \n", p->peakFrequency, df0);
}

void processing_detect_freq_and_phase2(Processing* p, double peakFrequency){
    size_t length = p->signalLength;
    
    double df = 0.1;
    double left = (1 - df) * peakFrequency;
    double right = (1 + df) * peakFrequency;
    
    size_t leftIndex = 2 * left * length / p->fd;
    size_t rightIndex = 2 * right * length / p->fd;
    //size_t index = 2 * peakFrequency * length / p->fd;
    
    double freq = 0;
    double sum = 0;
    
    for(int i = leftIndex; i <= rightIndex; i++){
        double f = (double)i * p->fd / (2.0 * length);
        double k = 1.0; //exp(-1.0 * (f - peakFrequency)*(f - peakFrequency) / (df * df));
        sum += p->spectrum[i] * k;
        freq += p->spectrum[i] * f * k;
    }
    
    if(sum == 0){
        //sum = 1.0;
        //freq = peakFrequency;
    }
    
    freq /= sum;
    
    p->peakFrequency = freq;
    
    printf(" F ~ %f       %f \n", freq, freq - peakFrequency);
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
    for(int i = length - 1; i >= 0; i--) {
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
