//
//  TTLAppController.m
//  TimeLapse
//
//  Created by reddit.com/u/_lowell for http://redd.it/wshn4 on 7/19/12.
//
//
#include <objc/runtime.h>
#import <QTKit/QTKit.h>
#import "TTLAppController.h"
#import "TTLCaptureOperation.h"

@interface TTLAppController () <NSAnimationDelegate> {

    NSURL *outputFolder;
    Class CaptureOperation;

}

@property BOOL isCapturing;
@property NSInteger captureInterval;
@property NSTimeInterval imagePlaybackDuration;
@property (retain) NSMutableArray *images;
@property (retain) NSTimer *captureTimer;
@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) IBOutlet NSTextField *outputFolderLabel;
@property (assign) IBOutlet NSButton *button;
@property (assign) IBOutlet NSProgressIndicator *spinner;

- (void) ttl_addCaptureOperation;
- (void) ttl_updateOutputFolderLabel;
- (void) ttl_buildMovie;

@end

@implementation TTLAppController

#pragma mark -
#pragma mark NSObject

- (void) awakeFromNib {

    [self setImages:[NSMutableArray array]];
    [[self button] setEnabled:NO];

    [self setCaptureInterval:1];
    [self setImagePlaybackDuration:2.0];
    [self setIsCapturing:NO];
    [super awakeFromNib];
    
    return;
    /*
    self->CaptureOperation = objc_allocateClassPair([NSOperation class], "CaptureOperation", 0);
    objc_registerClassPair(CaptureOperation);

    objc_property_attribute_t type = { "T", "@\"id\"" };
    objc_property_attribute_t ownership = { "W", "" };
    objc_property_attribute_t backingivar  = { "V", "_delegate" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty(CaptureOperation, "delegate", attrs, 3);

    Protocol *captureOperationDelegate = objc_allocateProtocol("TTLCaptureOperationDelegate");
//    objc_registerProtocol(captureOperationDelegate);
    class_addProtocol(CaptureOperation, captureOperationDelegate);

    protocol_addMethodDescription(captureOperationDelegate, @selector(operation:didFinishCapture:), "@:@@", YES, YES);

    id (^main)(id, SEL) = ^id (id __self, SEL ___cmd){
        CGImageRef captureImage = CGDisplayCreateImage(CGMainDisplayID());
        if ([__self delegate])
            [[__self delegate] operation:__self didFinishCapture:captureImage];
        
        CFRelease(captureImage);
        return __self;
    };
    class_addMethod(CaptureOperation, @selector(main), imp_implementationWithBlock(main), "@@:");
    */
>>>>>>> Stashed changes

}

#pragma mark -
#pragma mark NSApplicationDelegate

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {

    return YES;

}

- (void) applicationWillFinishLaunching:(NSNotification *)notification {

    [[self mainWindow] makeKeyAndOrderFront:self];
    [[self mainWindow] setAlphaValue:0.0];

}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {

    NSAnimation *animation = [[NSAnimation alloc] initWithDuration:0.5
                                                    animationCurve:NSAnimationEaseInOut];
    [(NSWindow *)[[self mainWindow] animator] setAnimations:@{ animation : @"alphaValue" }];

    [animation startAnimation];
    [[[self mainWindow] animator] setAlphaValue:1.0];
    [animation release];

}

#pragma mark -
#pragma mark TTLAppController

- (IBAction) selectOutputFolder: sender {

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanCreateDirectories:YES];

    __block NSURL *outputFolderLocal = self->outputFolder;
    [openPanel beginSheetModalForWindow:[self mainWindow]
                      completionHandler:^(NSInteger result) {

                          outputFolderLocal = [[openPanel URL] copy];
                          self->outputFolder = outputFolderLocal;
                          [self ttl_updateOutputFolderLabel];
                          [[self button] setEnabled:YES];

    }];
    
}

- (IBAction) startOrCancelCaptures: sender {

    if (![self isCapturing]) {

        [[self spinner] startAnimation:self];
        [[self button] setTitle:@"Stop & Make Movie"];
        [self setIsCapturing:YES];
        [self setCaptureTimer:[NSTimer scheduledTimerWithTimeInterval:[self captureInterval]
                                                    target:self
                                                  selector:@selector(ttl_addCaptureOperation)
                                                  userInfo:nil
                                                   repeats:YES]];
        [[self captureTimer] fire];

    } else {

        [[self spinner] stopAnimation:self];
        [[self button] setTitle:@"Take Screenshots"];
        [self setIsCapturing:NO];
        [[self captureTimer] invalidate];

        [self ttl_buildMovie];

    }

}

- (void) ttl_addCaptureOperation {

//    id op = [[self->CaptureOperation alloc] init];
    TTLCaptureOperation *op = [[TTLCaptureOperation alloc] init];
    [op setDelegate:self];
    [[NSOperationQueue mainQueue] addOperation:op];

}

- (void) ttl_buildMovie {

    NSBlockOperation *buildMovieOperation = [NSBlockOperation blockOperationWithBlock:^(void) {
        
        NSString *file = [NSString stringWithFormat:@"%@/%ld.m4v", [self->outputFolder relativePath], time(NULL)];

        NSError *movieError = nil;
        QTMovie *movie = [[QTMovie alloc] initToWritableFile:file error:&movieError];
        [movie setAttribute:@YES
                     forKey:QTMovieEditableAttribute];

        if (!movie) {

            NSLog(@"%@", movieError);

        }

        NSLog(@"%lx images in movie.", [[self images] count]);
        for (NSImage *img in [self images]) {
            [movie addImage:img
                forDuration:QTMakeTimeWithTimeInterval([self imagePlaybackDuration])
             withAttributes:@{ QTAddImageCodecType : @"mp4v", QTAddImageCodecQuality : @(codecHighQuality) }];
            [movie updateMovieFile];
        }
        NSLog(@"Writing to file %@...", file);

        if ([movie updateMovieFile]) {

            NSLog(@"Wrote to file %@", file);

        } else {
            [NSApp presentError:[NSError errorWithDomain:@"com.github.user.lowell"
                                                    code:-500
                                                userInfo:@{ @"TTLFailureMessage" : @"Unable to write file."}]];
        };
        [movie release];
    }];
    [buildMovieOperation setCompletionBlock:^{

        [NSApp performSelectorOnMainThread:@selector(requestUserAttention:)
                                withObject:nil
                             waitUntilDone:NO];

    }];

    [[NSOperationQueue mainQueue] addOperation:buildMovieOperation];
    
}

- (void) ttl_updateOutputFolderLabel {

    if (self->outputFolder) {

        [[self outputFolderLabel] setStringValue:[NSString stringWithFormat:@"%@", [self->outputFolder relativePath]]];

    }

}

#pragma mark -
#pragma mark TTLAppControllerDelegate

- (void) operation:(TTLCaptureOperation *)operation didFinishCapture:(CGImageRef)image {

    NSImage *_image = [[NSImage alloc] initWithCGImage:image
                                                  size:NSMakeSize(CGImageGetWidth(image),
                                                                  CGImageGetHeight(image))];
    [[self images] addObject:[_image autorelease]];
    return;

}

@end
