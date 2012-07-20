//
//  TTLCaptureOperation.h
//  TimeLapse
//
//  Created by reddit.com/u/_lowell for http://redd.it/wshn4 on 7/19/12.
//
//

#import <Foundation/Foundation.h>

@protocol TTLCaptureOperationDelegate;

@interface TTLCaptureOperation : NSOperation

@property (assign) __weak id<TTLCaptureOperationDelegate> delegate;

@end

@protocol TTLCaptureOperationDelegate <NSObject>
- (void) operation: (TTLCaptureOperation *) operation didFinishCapture: (CGImageRef) image;
@end