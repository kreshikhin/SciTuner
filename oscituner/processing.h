//
//  processing.h
//  oscituner
//
//  Created by Denis Kreshikhin on 29.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

#ifndef __oscituner__processing__
#define __oscituner__processing__

#include <stdio.h>
#include <Accelerate/Accelerate.h>

typedef struct{
    double fd;
    double fMin;
    
    double peakFrequency;
    
    size_t signalLength;

    double* signal;

    double* real;
    double* imag;

    double* spectrum;

    size_t step;

    double fGrid[5];
    
    FFTSetupD fs;
} Processing;

void source_generate(double* dest, size_t count, double* t, double dt, double freq);

Processing* processing_create();
void processing_destroy(Processing* p);

void processing_init(Processing* processing, double fd, double fMin, size_t pointCount);
void processing_push(Processing* processing, const double* packetBuffer, size_t length);
void processing_recalculate(Processing* processing);
void processing_build_standing_wave(Processing* processing, float* wave, size_t length);
void processing_build_build_power_spectrum(Processing* processing, float* spectrum, size_t length);
double processing_get_frequency(Processing* p);

void processing_deinit(Processing* processing);

int transform_radix2(double real[], double imag[], size_t n);

size_t reverse_bits(size_t x, unsigned int n);
size_t ceil2(double value);

#endif /* defined(__oscituner__processing__) */
