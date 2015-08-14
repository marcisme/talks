//
//  ReferenceObjects.m
//  FAM
//
//  Created by Marc Schwieterman on 8/4/15.
//  Copyright (c) 2015 Marc Schwieterman Software, LLC. All rights reserved.
//

#import "ReferenceObjects.h"


@implementation ReferenceObjects

+ (AudioBufferList *)twoBufferListPointer {
    size_t size = offsetof(AudioBufferList, mBuffers[0]) + sizeof(AudioBuffer) * 2;

    AudioBufferList *audioBufferList = malloc(size);

    audioBufferList->mNumberBuffers = 2;

    audioBufferList->mBuffers[0].mNumberChannels = 1;
    audioBufferList->mBuffers[0].mDataByteSize = 1;
    audioBufferList->mBuffers[0].mData = malloc(sizeof(UInt8));
    *(UInt8 *)audioBufferList->mBuffers[0].mData = 128;

    audioBufferList->mBuffers[1].mNumberChannels = 1;
    audioBufferList->mBuffers[1].mDataByteSize = 1;
    audioBufferList->mBuffers[1].mData = malloc(sizeof(UInt8));
    *(UInt8 *)audioBufferList->mBuffers[1].mData = 255;

    return audioBufferList;
}

+ (void)twoBufferListPointerPointer:(AudioBufferList **)audioBufferList {
    size_t size = offsetof(AudioBufferList, mBuffers[0]) + sizeof(AudioBuffer) * 2;

    *audioBufferList = malloc(size);

    (*audioBufferList)->mNumberBuffers = 2;

    (*audioBufferList)->mBuffers[0].mNumberChannels = 1;
    (*audioBufferList)->mBuffers[0].mDataByteSize = 1;
    (*audioBufferList)->mBuffers[0].mData = malloc(sizeof(UInt8));
    *(UInt8 *)(*audioBufferList)->mBuffers[0].mData = 128;

    (*audioBufferList)->mBuffers[1].mNumberChannels = 1;
    (*audioBufferList)->mBuffers[1].mDataByteSize = 1;
    (*audioBufferList)->mBuffers[1].mData = malloc(sizeof(UInt8));
    *(UInt8 *)(*audioBufferList)->mBuffers[1].mData = 255;
}

+ (NSArray *)nsArray {
    return [NSArray array];
}

@end
