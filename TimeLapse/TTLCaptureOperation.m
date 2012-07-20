//
//  TTLCaptureOperation.m
//  TimeLapse
//
//  Created by reddit.com/u/_lowell for http://redd.it/wshn4 on 7/19/12.
//
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "TTLCaptureOperation.h"

@implementation TTLCaptureOperation

#pragma mark -
#pragma mark NSOperation

- (void) main {

    CGImageRef captureImage = CGDisplayCreateImage(CGMainDisplayID());
    if ([self delegate])
        [[self delegate] operation:self didFinishCapture:captureImage];

    CFRelease(captureImage);
    return;

}

@end
