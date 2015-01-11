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

double get_peak_width(double* s, double freq, double df, size_t length);
double get_range_energy(double* s, double freq, double df, size_t length);

void approximate(double* dest, const double* src, size_t destLength, size_t srcLength);
void approximate_sinc(double* dest, const double* src, size_t destLength, size_t srcLength);

int get_freq_code(double freq);
double get_code_freq(int code);
double sinc(double t);
double get_phase(double re, double im); // 0.. 2pi

void expend2(double* data, size_t length);

void source_generate(double* dest, size_t count, double* t, double dt, double freq);
size_t reverse_bits(size_t x, unsigned int n);