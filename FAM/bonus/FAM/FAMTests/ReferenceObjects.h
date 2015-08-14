//
//  ReferenceObjects.h
//  FAM
//
//  Created by Marc Schwieterman on 8/4/15.
//  Copyright (c) 2015 Marc Schwieterman Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


struct StaticArrayEndowed {
    UInt8 staticArray[3];
};
typedef struct StaticArrayEndowed StaticArrayEndowed;

@interface ReferenceObjects : NSObject

+ (AudioBufferList* __nonnull)twoBufferListPointer;
+ (void)twoBufferListPointerPointer:(AudioBufferList * __nonnull * __nonnull)audioBufferList;

+ (NSArray * __nonnull )nsArray;

@end
