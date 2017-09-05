//
//  dspmath.h
//  SciTuner
//
//  Created by Denis Kreshikhin on 06.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//
#pragma once

#include <math.h>
#include <stdlib.h>

void approximate_sinc(double* dest, const double* src, size_t destLength, size_t srcLength);

double sinc(double t);
double get_phase(double re, double im); // 0.. 2pi

size_t ceil2(double value);
