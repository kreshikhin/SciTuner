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

#define OBSERVATION_TIME 10 // in sex

struct Packet{
    float* buffer;
    struct Packet* prev;
    struct Packet* next;
    size_t size;
};

typedef struct{
    float* signal;
    struct Packet* packetList;
    float fd;  // Hz
} Processing;

void processing_init(Processing* processing, float fd);
void processing_push(Processing* processing, const float* packetBuffer, size_t length);
void processing_calculate(Processing* processing);
void processing_deinit(Processing* processing);

int transform_radix2(double real[], double imag[], size_t n);

#endif /* defined(__oscituner__processing__) */
