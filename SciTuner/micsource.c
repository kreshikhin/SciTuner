//
//  micsource.c
//  SciTuner
//
//  Created by Denis Kreshikhin on 02.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

#include "micsource.h"


size_t Buffer_size(Buffer* node);
Buffer* Buffer_last(Buffer* node);
Buffer* Buffer_new(double* data, size_t length);
Buffer* Buffer_new_zeros(size_t length);
void Buffer_delete(Buffer* node);
Buffer* Buffer_push(Buffer* node, Buffer* next);
Buffer* Buffer_shift(Buffer* node);

size_t Buffer_size(Buffer* node) {
    size_t = 0;
    while(node){
        size ++;
        node = node->next;
    }

    return size;
}

Buffer* Buffer_last(Buffer* node){
    if(!node) return NULL;

    while(node->next){
        node = node->next;
    }

    return node;
}

Buffer* Buffer_new(double* data, size_t length){
    Buffer* node = malloc(sizeof(Buffer));

    memcpy(node->data, data, length * sizeof(*node->data));
    node->length = length;
    node->next = NULL;

    return node
}

Buffer* Buffer_new_zeros(size_t length){
    Buffer* node = malloc(sizeof(Buffer));

    memset(node->data, 0, length * sizeof(*node->data));
    node->length = length;
    node->next = NULL;

    return node
}

void Buffer_delete(Buffer* node){
    while(node){
        Buffer* next = node->next;

        free(node->data);
        free(node);

        node = next;
    }
}

Buffer* Buffer_push(Buffer* node, Buffer* next){
    Buffer* last = Buffer_last(node);
    if(!last) return next;
    last->next = next;

    return node;
}

Buffer* Buffer_shift(Buffer* node){
    if(!node) return NULL;

    Buffer* next = node->next;
    node->next = NULL;
    Buffer_delete(node);

    return next;
}

void DeriveBufferSize(AudioQueueRef audioQueue,
                      AudioStreamBasicDescription* ASBDescription,
                      Float64 seconds,
                      UInt32* outBufferSize
                      );

struct AQRecorderState* AQRecorderState_create(){
    return malloc(sizeof(struct AQRecorderState));
}

void AQRecorderState_init(struct AQRecorderState* aq, double sampleRate, size_t count){
    aq->samples = malloc(count * sizeof(*aq->samples));

    aq->mDataFormat.mFormatID = kAudioFormatLinearPCM;
    aq->mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    aq->mDataFormat.mSampleRate = sampleRate;
    aq->mDataFormat.mChannelsPerFrame = 1;
    aq->mDataFormat.mBitsPerChannel = 16;
    aq->mDataFormat.mFramesPerPacket = 1;
    aq->mDataFormat.mBytesPerPacket = 2;// for linear pcm
    aq->mDataFormat.mBytesPerFrame = 2;

    AudioQueueNewInput(&aq->mDataFormat,
                       HandleInputBuffer,
                       aq,
                       NULL,
                       kCFRunLoopCommonModes,
                       0,
                       &aq->mQueue);

    DeriveBufferSize(aq->mQueue,
                     &aq->mDataFormat,
                     (double)count / sampleRate,  // seconds
                     &aq->bufferByteSize);

    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBuffer(aq->mQueue, aq->bufferByteSize, &aq->mBuffers[i]);
        AudioQueueEnqueueBuffer(aq->mQueue, aq->mBuffers[i], 0, NULL);
    }

    aq->mCurrentPacket = 0;
    aq->mIsRunning = true;

    aq->list = NULL;

    AudioQueueStart(aq->mQueue, NULL);
}

void AQRecorderState_deinit(struct AQRecorderState* aq){
    AudioQueueStop(aq->mQueue, true);
    aq->mIsRunning = false;

    AudioQueueDispose(aq->mQueue, true);

    free(aq->samples);
}

void AQRecorderState_destroy(struct AQRecorderState* aq){
    return free(aq);
}

void AQRecorderState_get_samples(struct AQRecorderState* aq, double* dest, size_t count){
    if(!aq->list) return;

    size_t length = count < aq->list->length ? count : aq->list->length;
    memcpy(dest, aq->list->data, length * sizeof(*aq->samples));

    aq->list = Buffer_shift(aq->list);

    if(Buffer_size() > 16){
        Buffer_delete(aq->list);
        aq->list = NULL;
    }
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

    const SInt16* data = inBuffer->mAudioData;
    Buffer* node = Buffer_new_zeros(inNumPackets);

    for (int i = 0; i < inNumPackets; i++) {
        SInt16 d = data[i];
        double s = (double)d / (0x7000);
        node->data[i] = s;
    }

    pAqData->list = Buffer_push(pAqData->list, node);

    //pAqData->mCurrentPacket += inNumPackets;


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
