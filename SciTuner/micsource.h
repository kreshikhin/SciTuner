//
//  micsource.h
//  SciTuner
//
//  Created by Denis Kreshikhin on 02.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

#ifndef __SciTuner__micsource__
#define __SciTuner__micsource__

#include <stdio.h>

#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>

static const int kNumberBuffers = 3;                            // 1

typedef struct{
    double* data;
    size_t length;
    struct Buffer* next;
} Buffer;

struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;                   // 2
    AudioQueueRef                mQueue;                        // 3
    AudioQueueBufferRef          mBuffers[kNumberBuffers];      // 4
    //AudioFileID                  mAudioFile;                    // 5
    UInt32                       bufferByteSize;                // 6
    SInt64                       mCurrentPacket;                // 7
    bool                         mIsRunning;                    // 8s
    
    Buffer* list;
};

struct AQRecorderState* AQRecorderState_create();
void AQRecorderState_init(struct AQRecorderState* aq, double sampleRate, size_t count);
void AQRecorderState_deinit(struct AQRecorderState* aq);
void AQRecorderState_destroy(struct AQRecorderState* aq);

void AQRecorderState_get_samples(struct AQRecorderState* aq, double* dest, size_t count);

static void HandleInputBuffer (
    void                                *aqData,             // 1
    AudioQueueRef                       inAQ,                // 2
    AudioQueueBufferRef                 inBuffer,            // 3
    const AudioTimeStamp                *inStartTime,        // 4
    UInt32                              inNumPackets,        // 5
    const AudioStreamPacketDescription  *inPacketDesc        // 6
);

#endif /* defined(__SciTuner__micsource__) */
