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
    // push new samples
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
    
    for(int i = 0; i < p->signalLength; i ++){
        p->spectrum[i] = p->real[i] * p->real[i] + p->imag[i] * p->imag[i];
    }
}


void processing_build_standing_wave(Processing* p, double* wave, size_t length){
    memcpy(wave, p->signal, length * sizeof(*wave));
}

void processing_build_build_power_spectrum(Processing* p, double* spectrum, size_t length){
    memcpy(spectrum, p->spectrum, length * sizeof(*spectrum));
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
