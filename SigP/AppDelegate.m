//
//  AppDelegate.m
//  SigP
//
//  Created by KalanyuZ on 12/14/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    if (!(([self.window styleMask] & NSFullScreenWindowMask)  == NSFullScreenWindowMask))
        [self.window toggleFullScreen:nil];
    // Insert code here to initialize your application
}

@end
