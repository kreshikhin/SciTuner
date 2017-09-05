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


size_t ceil2(double value){
    int shift = ceil(log2(value));
    size_t result = 1 << shift;
    return result;
}
