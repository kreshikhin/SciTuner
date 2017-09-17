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
    
    double fmin;
    double fmax;
    
    bool filter;
    double targetFrequency;
    int targetHarmonic;
    
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
    
    size_t previewLength;
    double* preview;
    

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

void processing_init(Processing* processing, double fd, size_t pointCount, size_t points, size_t previewLength);

void processing_push(Processing* processing, const double* packetBuffer, size_t length);
void processing_save_preview(Processing* p, const double* packet, size_t packetLength);

void processing_recalculate(Processing* processing);
void processing_build_standing_wave2(Processing* processing, double* wave, size_t length);

double processing_get_frequency(Processing* p);
double processing_get_sub_frequency(Processing* p);

double processing_get_pulsation(Processing* p);
void processing_get_harmonics(Processing* p, double *harmonics, size_t n, double* normed_pulsation);

void processing_get_subtones(Processing* p, double* subtones, size_t n);

void processing_set_target_frequency(Processing* p, double frequency, int harmonic);
void processing_enable_filter(Processing* p);
void processing_disable_filter(Processing* p);
double processing_filter_gain(Processing* p, double f);

void processing_set_band(Processing* p, double fmin, double fmax);

void processing_deinit(Processing* processing);

size_t reverse_bits(size_t x, unsigned int n);
size_t ceil2(double value);

#endif /* defined(__oscituner__processing__) */
