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
    
    bool filter;
    double targetFrequency;
    
    double peakFrequency;
    double peakSubFrequency;
    double peakPhase;
    
    size_t subcounter;
    
    double *subSignalReal;
    double *subSignalImag;
    
    double *subSpectrumReal;
    double *subSpectrumImag;
    
    double *subSpectrum;
    size_t subLength;
    
    size_t pointCount;
    double* points;

    size_t signalLength;
    double* signal;

    double* real;
    double* imag;

    double* spectrum;

    size_t step;

    double fGrid[5];
    
    FFTSetupD fs;
    FFTSetupD sfs;
} Processing;

void source_generate(double* dest, size_t count, double* t, double dt, double freq);

Processing* processing_create();
void processing_destroy(Processing* p);

void processing_init(Processing* processing, double fd, double fMin, size_t pointCount, size_t points);

void processing_push(Processing* processing, const double* packetBuffer, size_t length);
void processing_recalculate(Processing* processing);
void processing_build_standing_wave(Processing* processing, float* wave, float* light, size_t length, float thickness);

double processing_get_frequency(Processing* p);
double processing_get_sub_frequency(Processing* p);


void processing_set_target_frequency(Processing* p, double frequency);
void processing_enable_filter(Processing* p);
void processing_disable_filter(Processing* p);

void processing_deinit(Processing* processing);

int transform_radix2(double real[], double imag[], size_t n);

size_t reverse_bits(size_t x, unsigned int n);
size_t ceil2(double value);

#endif /* defined(__oscituner__processing__) */
