//
//  micsource.c
//  SciTuner
//
//  Created by Denis Kreshikhin on 02.01.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

#include "micsource.h"

Buffer* Buffer_new(size_t length);
void Buffer_delete(Buffer* node);

size_t Buffer_free_space(Buffer* buffer);
void Buffer_write_ints(Buffer* buffer, const SInt16* data, size_t length);
void Buffer_read(Buffer* node, double* data, size_t length);

Buffer* Buffer_new(size_t length) {
    Buffer* buffer = malloc(sizeof(Buffer));

    buffer->length = length;
    buffer->position = 0;
    buffer->data = malloc(length * sizeof(double));
    //memset(buffer->data, 0, length * sizeof(double));
    
    return buffer;
}

void Buffer_delete(Buffer* buffer) {
    free(buffer->data);
    free(buffer);
}

size_t Buffer_free_space(Buffer* buffer) {
    return buffer->length - buffer->position;
}

void Buffer_write_ints(Buffer* buffer, const SInt16* data, size_t length) {
    size_t free_space = Buffer_free_space(buffer);
    size_t actual_length = length < free_space ? length : free_space;
    
    double* dest = buffer->data + buffer->position;
    
    for (int i = 0; i < actual_length; i++) {
        SInt16 d = data[i];
        double s = (double)d / (0x7000);
        dest[i] = s;
    }
    buffer->position += actual_length;
}

void Buffer_read(Buffer* buffer, double* data, size_t length) {
    size_t actual_length = length < buffer->position ? length : buffer->position;
    memcpy(data, buffer->data, actual_length * sizeof(double));
    buffer->position -= actual_length;
    memmove(buffer->data, buffer->data + actual_length, buffer->position * sizeof(double));
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

    aq->buffer = Buffer_new(32768);
    aq->preview_buffer = Buffer_new(2500);

    AudioQueueStart(aq->mQueue, NULL);
}

void AQRecorderState_deinit(struct AQRecorderState* aq){
    AudioQueueStop(aq->mQueue, true);
    aq->mIsRunning = false;

    AudioQueueDispose(aq->mQueue, true);
    
    Buffer_delete(aq->buffer);
    Buffer_delete(aq->preview_buffer);
}

void AQRecorderState_destroy(struct AQRecorderState* aq){
    return free(aq);
}

bool AQRecorderState_get_samples(struct AQRecorderState* aq, double* dest, size_t count){
    if(aq->buffer->position < count) {
        return false;
    }
    
    Buffer_read(aq->buffer, dest, count);
    return true;
}

bool AQRecorderState_get_preview(struct AQRecorderState* aq, double* dest, size_t count){
    if(aq->preview_buffer->position < count) {
        return false;
    }
    
    Buffer_read(aq->preview_buffer, dest, count);
    return true;
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
    Buffer_write_ints(pAqData->buffer, data, inNumPackets);
    Buffer_write_ints(pAqData->preview_buffer, data, inNumPackets);
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
