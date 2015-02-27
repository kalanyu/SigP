//
//  SigPDisabledButton.m
//  SigP
//
//  Created by カーランユー ジントゥザアート on 12/21/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import "SigPDisabledButton.h"

@implementation SigPDisabledButton


- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{    
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    
    // Outer stroke (drawn as gradient)
    [ctx saveGraphicsState];
    
    NSBezierPath *outerClip = [NSBezierPath bezierPathWithRect:frame];
    [outerClip setClip];
    NSColor *outerColor = [NSColor colorWithCalibratedRed:200/255.0f green:0.0f blue:0.0f alpha:1.0f];
    
    [outerColor drawSwatchInRect:[outerClip bounds]];
    [ctx restoreGraphicsState];
    
    // Background gradient
    
    [ctx saveGraphicsState];
    NSBezierPath *backgroundPath = 
    
    [NSBezierPath bezierPathWithRect:NSInsetRect(frame, 1.0f, 1.0f)];
    
    [backgroundPath setClip];
    
    //    NSColor *backgroundGradient = 
    //    [NSColor colorWithDeviceRed:0.0f green:204/255.0f blue:1.0f alpha:0.5f];
    
    [[NSColor colorWithCalibratedRed:80/255.0f green:0.0f blue:0.0f alpha:1.0  ] drawSwatchInRect:[backgroundPath bounds]];
    
    [ctx restoreGraphicsState];
}

@end
