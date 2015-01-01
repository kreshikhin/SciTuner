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

typedef struct{
    double fd;
    double fMin;
    
    size_t signalLength;
    size_t bufferLength;

    double* buffer;

    double* real;
    double* imag;

    double* spectrum;

    size_t step;

    double fGrid[5];
} Processing;

void processing_init(Processing* processing, double fd, double fMin, size_t pointCount);
void processing_push(Processing* processing, const float* packetBuffer, size_t length);
void processing_calculate(Processing* processing);
void processing_deinit(Processing* processing);

int transform_radix2(double real[], double imag[], size_t n);

size_t reverse_bits(size_t x, unsigned int n);
size_t ceil2(double value);

#endif /* defined(__oscituner__processing__) */
