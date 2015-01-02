//
//  micsource.c
//  SciTuner
//
//  Created by Denis Kreshikhin on 02.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

#include "micsource.h"

struct AQRecorderState* AQRecorderState_create(){
    return malloc(sizeof(struct AQRecorderState));
}

void AQRecorderState_init(struct AQRecorderState* aq, double sampleRate, size_t count){
    aq->mDataFormat.mFormatID = kAudioFormatLinearPCM;
    aq->mDataFormat.mSampleRate = sampleRate;
    aq->mDataFormat.mChannelsPerFrame = 1;
    aq->mDataFormat.mBitsPerChannel = 16;
    aq->mDataFormat.mBytesPerPacket = 1;// for linear pcm
    aq->mDataFormat.mBytesPerFrame = aq->mDataFormat.mChannelsPerFrame * sizeof(int16_t);
}

void AQRecorderState_destroy(struct AQRecorderState* aq){
    return free(aq);
}

static void HandleInputBuffer (
    void                                 *aqData,
    AudioQueueRef                        inAQ,
    AudioQueueBufferRef                  inBuffer,
    const AudioTimeStamp                 *inStartTime,
    UInt32                               inNumPackets,
    const AudioStreamPacketDescription   *inPacketDesc
) {
}