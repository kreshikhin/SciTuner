//
//  processing.c
//  oscituner
//
//  Created by Denis Kreshikhin on 29.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

#include "processing.h"

void processing_init(Processing* processing, float fd){
    size_t signalSize = fd * OBSERVATION_TIME * sizeof(float);
    processing->signal = malloc(signalSize);
    processing->packetList = NULL;
    processing->fd = fd;
}

void processing_push(Processing* processing, const float* packetBuffer, size_t length) {
    if (processing->historySize + length > processing->historyLimitInSec * processing->fd) {
        processing->
    }
}

void processing_calculate(Processing* processing){
}

void processing_deinit(Processing* processing){
    free(processing->signal);
}