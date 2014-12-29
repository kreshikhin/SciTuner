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

struct Processing{
    float* signal;
    Packet* packetList;
    float fd;  // Hz
}

struct Packet{
    float* buffer;
    Packet* prev;
    Packet* next;
    size_t size;
}

void processing_init(Processing* processing, float fd);
void processing_push(Processing* processing, const float* packetBuffer, size_t length);
void processing_calculate(Processing* processing);
void processing_deinit(Processing* processing);


#endif /* defined(__oscituner__processing__) */
