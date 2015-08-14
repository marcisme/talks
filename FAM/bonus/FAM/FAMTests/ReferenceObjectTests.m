//
//  ReferenceObjectTests.m
//  FAM
//
//  Created by Marc Schwieterman on 8/4/15.
//  Copyright (c) 2015 Marc Schwieterman Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ReferenceObjects.h"


struct Foo {
    UInt32 a;
    UInt8 b;
    UInt8 c;
    UInt8 d;
    UInt8 e;
};
typedef struct Foo Foo;


@interface ReferenceObjectTests : XCTestCase; @end

@implementation ReferenceObjectTests

- (void)testSizesofThings {
    XCTAssertEqual(sizeof(UInt8), (size_t)1);
    XCTAssertEqual(sizeof(AudioBuffer), (size_t)16);
    XCTAssertEqual(sizeof(AudioBufferList), (size_t)24);
    XCTAssertEqual(offsetof(AudioBufferList, mBuffers[0]), (size_t)8);

    XCTAssertEqual(sizeof(Foo), (size_t)8);
}

- (void)testTwoBufferListPointer {
    AudioBufferList *audioBufferList = [ReferenceObjects twoBufferListPointer];

    XCTAssertEqual(audioBufferList->mNumberBuffers, (UInt32)2);
    XCTAssertEqual(audioBufferList->mBuffers[0].mNumberChannels, (UInt32)1);
    XCTAssertEqual(audioBufferList->mBuffers[0].mDataByteSize, (UInt32)1);
    XCTAssertEqual(*(UInt8*)audioBufferList->mBuffers[0].mData, 128);

    XCTAssertEqual(audioBufferList->mNumberBuffers, (UInt32)2);
    XCTAssertEqual(audioBufferList->mBuffers[1].mNumberChannels, (UInt32)1);
    XCTAssertEqual(audioBufferList->mBuffers[1].mDataByteSize, (UInt32)1);
    XCTAssertEqual(*(UInt8*)audioBufferList->mBuffers[1].mData, 255);
}

- (void)testTwoBufferListPassedPointerPointer {
    AudioBufferList *audioBufferList;
    [ReferenceObjects twoBufferListPointerPointer:&audioBufferList];

    XCTAssertEqual(audioBufferList->mNumberBuffers, (UInt32)2);
    XCTAssertEqual(audioBufferList->mBuffers[0].mNumberChannels, (UInt32)1);
    XCTAssertEqual(audioBufferList->mBuffers[0].mDataByteSize, (UInt32)1);
    XCTAssertEqual(*(UInt8*)audioBufferList->mBuffers[0].mData, 128);

    XCTAssertEqual(audioBufferList->mNumberBuffers, (UInt32)2);
    XCTAssertEqual(audioBufferList->mBuffers[1].mNumberChannels, (UInt32)1);
    XCTAssertEqual(audioBufferList->mBuffers[1].mDataByteSize, (UInt32)1);
    XCTAssertEqual(*(UInt8*)audioBufferList->mBuffers[1].mData, 255);
}

@end
