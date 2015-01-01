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

void processing_init(Processing* p, double fd, double fMin, size_t pointCount) {
    p->fd = fd;
    p->fMin = fMin;
    p->signalLength = ceil2((double)pointCount);
    p->bufferLength = ceil2((double)pointCount * fd / fMin);
    p->step = 1;

    p->buffer = malloc(p->bufferLength * sizeof(*p->buffer))

    memset(p->buffer, 0, p->bufferLength * sizeof(*p->buffer));

    p->real = malloc(p->signalLength * sizeof(*p->real))
    p->imag = malloc(p->signalLength * sizeof(*p->imag))
}

void processing_push(Processing* p, const double* packet, size_t packetLength) {
    // push new samples
    if(packetLength >= p->bufferLength) {
        memcpy(p->buffer, packet + (packetLength - p->bufferLength), p->bufferLength * sizeof(*p->buffer));
        return;
    }

    memmove(buffer, buffer + packetLength, p->bufferLength - packetLength * sizeof(*p->buffer));
    memcpy(buffer + p->bufferLength - packetLength, packet, packetLength * sizeof(*p->buffer));
}

void processing_calculate(Processing* processing){
    int i;
    int j;

    double freal = p->fd / p->step;

    for(i = 0; i < p->bufferLength; i += p->step, j++){
        p->real[j] = p->buffer[i];  // thinning
    }

    memset(p->imag, 0, p->signalLength);

    transform_radix2(p->real, p->imag);
}

void processing_deinit(Processing* p){
    free(p->signal);
    free(p->real);
    free(p->imag);
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
