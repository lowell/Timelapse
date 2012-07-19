//
//  TTLAppController.m
//  TimeLapse
//
//  Created by reddit.com/u/_lowell for http://redd.it/wshn4 on 7/19/12.
//
//

#import "TTLAppController.h"
#import "TTLCaptureOperation.h"

@interface TTLAppController () <NSAnimationDelegate> {

    NSURL *outputFolder;

}

@property BOOL isCapturing;
@property NSInteger captureInterval;
@property (retain) NSTimer *captureTimer;
@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) IBOutlet NSTextField *outputFolderLabel;
@property (assign) IBOutlet NSButton *button;

- (void) ttl_addCaptureOperation;
- (void) ttl_updateOutputFolderLabel;

@end

@implementation TTLAppController

#pragma mark -
#pragma mark NSObject

- (void) awakeFromNib {

    [[self button] setEnabled:NO];

    [self setCaptureInterval:5];
    [self setIsCapturing:NO];
    [super awakeFromNib];
    return;

}

#pragma mark -
#pragma mark NSApplicationDelegate

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void) applicationWillFinishLaunching:(NSNotification *)notification {

    [[self mainWindow] setAlphaValue:0.0];

}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {

    NSAnimation *animation = [[NSAnimation alloc] initWithDuration:1.0
                                                    animationCurve:NSAnimationLinear];
    [[[self mainWindow] animator] setAnimations:@{ animation : @"alphaValue" }];

    [animation startAnimation];
    [[[self mainWindow] animator] setAlphaValue:1.0];

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

        [[self button] setTitle:@"Stop"];
        [self setIsCapturing:YES];
        [self setCaptureTimer:[NSTimer scheduledTimerWithTimeInterval:[self captureInterval]
                                                    target:self
                                                  selector:@selector(ttl_addCaptureOperation)
                                                  userInfo:nil
                                                   repeats:YES]];
        [[self captureTimer] fire];

    } else {

        [[self button] setTitle:@"Start"];
        [self setIsCapturing:NO];
        [[self captureTimer] invalidate];

    }

}

- (void) ttl_addCaptureOperation {

    TTLCaptureOperation *op = [[TTLCaptureOperation alloc] init];
    [op setOutputFolder:self->outputFolder];
    [[NSOperationQueue mainQueue] addOperation:op];

}
- (void) ttl_updateOutputFolderLabel {

    if (self->outputFolder) {

        [[self outputFolderLabel] setStringValue:[NSString stringWithFormat:@"%@", [self->outputFolder relativePath]]];

    } else {

        [NSApp presentError:[NSError errorWithDomain:@""
                                                code:-1
                                            userInfo:@{ @"Error" : @"Invalid path selected." }]];

    }
}
@end
