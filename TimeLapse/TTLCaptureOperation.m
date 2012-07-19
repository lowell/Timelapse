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

    NSString *filename =
        [NSString stringWithFormat:@"%@/%ld.png", [[self outputFolder] absoluteString], time(NULL)];
    NSURL *fileURL = [NSURL URLWithString:filename];

    CGImageRef captureImage = CGDisplayCreateImage(CGMainDisplayID());
    CGImageDestinationRef destination =
        CGImageDestinationCreateWithURL((CFURLRef) fileURL,
                                        kUTTypePNG,
                                        1,
                                        (CFDictionaryRef)@{ @"" : @"" });
    CGImageDestinationAddImage(destination,
                               captureImage,
                               (CFDictionaryRef)@{ @"" : @"" });
    CGImageDestinationFinalize(destination);
    return;

}

@end
