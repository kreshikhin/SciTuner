//
//  micsource.c
//  SciTuner
//
//  Created by Denis Kreshikhin on 02.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

#include "micsource.h"

void DeriveBufferSize(AudioQueueRef audioQueue,
                      AudioStreamBasicDescription* ASBDescription,
                      Float64 seconds,
                      UInt32* outBufferSize
                      );

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
    
    AudioQueueNewInput(&aq->mDataFormat,
                       HandleInputBuffer,
                       aq,
                       NULL,
                       kCFRunLoopCommonModes,
                       0,
                       &aq->mQueue);
    
    DeriveBufferSize(aq->mQueue,
                     &aq->mDataFormat,
                     0.5,
                     &aq->bufferByteSize);
    
    aq->mCurrentPacket = 0;
    aq->mIsRunning = true;
    AudioQueueStart(aq->mQueue, NULL);
}

void AQRecorderState_deinit(struct AQRecorderState* aq){
    AudioQueueStop(aq->mQueue, true);
    aq->mIsRunning = false;
    
    AudioQueueDispose(aq->mQueue, true);
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
    struct AQRecorderState* pAqData = (struct AQRecorderState*)aqData;
    
    if(inNumPackets == 0 && pAqData->mDataFormat.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;
    
    /*
    if(AudioFileWritePackets(pAqData->mAudioFile,
                             false,
                             inBuffer->mAudioDataByteSize,
                             inPacketDesc,
                             pAqData->mCurrentPacket,
                             &inNumPackets,
                             inBuffer->mAudioData
    ) == noErr) {
    */
    pAqData->mCurrentPacket += inNumPackets;
    //}
    
    if (pAqData->mIsRunning == 0) return;
    
    AudioQueueEnqueueBuffer(pAqData->mQueue, inBuffer, 0, NULL);
}

void DeriveBufferSize(AudioQueueRef audioQueue,
                      AudioStreamBasicDescription* ASBDescription,
                      Float64 seconds,
                      UInt32* outBufferSize
){
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = ASBDescription->mBytesPerPacket;
    
    if (maxPacketSize == 0){
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        
        AudioQueueGetProperty(audioQueue,
                              kAudioQueueProperty_MaximumOutputPacketSize,
                              // in Mac OS X v10.5, instead use
                              //   kAudioConverterPropertyMaximumOutputPacketSize
                              &maxPacketSize,
                              &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = ASBDescription->mSampleRate * maxPacketSize * seconds;
    *outBufferSize = (UInt32) (numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);
}
