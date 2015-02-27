//
//  SigPButton.m
//  SigP
//
//  Created by カーランユー ジントゥザアート on 12/18/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import "SigPButton.h"

@implementation SigPButton

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{    
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
        
    // Outer stroke (drawn as gradient)
    [ctx saveGraphicsState];
    
    NSBezierPath *outerClip = [NSBezierPath bezierPathWithRect:frame];
    [outerClip setClip];
    NSColor *outerColor = [NSColor colorWithCalibratedRed:0.0f green:204/255.0f blue:1.0f alpha:1.0f];

    [outerColor drawSwatchInRect:[outerClip bounds]];
    [ctx restoreGraphicsState];
    
    // Background gradient
    
    [ctx saveGraphicsState];
    NSBezierPath *backgroundPath = 
    
    [NSBezierPath bezierPathWithRect:NSInsetRect(frame, 1.0f, 1.0f)];
   
    [backgroundPath setClip];
    
//    NSColor *backgroundGradient = 
//    [NSColor colorWithDeviceRed:0.0f green:204/255.0f blue:1.0f alpha:0.5f];
    
    [[NSColor colorWithCalibratedRed:0.0f green:120/255.0f blue:0.6f alpha:1.0  ] drawSwatchInRect:[backgroundPath bounds]];
    
    [ctx restoreGraphicsState];
    
//    // Dark stroke
//    
//    [ctx saveGraphicsState];
//    [[NSColor colorWithDeviceWhite:0.12f alpha:1.0f] setStroke];
//    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.5f, 1.5f) 
//                                     xRadius:roundedRadius 
//                                     yRadius:roundedRadius] stroke];
//    [ctx restoreGraphicsState];
//    
//    // Inner light stroke
    
//    [ctx saveGraphicsState];
//    [[NSColor colorWithDeviceWhite:1.0f alpha:0.05f] setStroke];
//    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.5f, 2.5f) 
//                                     xRadius:roundedRadius 
//                                     yRadius:roundedRadius] stroke];
//    [ctx restoreGraphicsState];        
    
    // Draw darker overlay if button is pressed
    
    if([self isHighlighted]) {
        [ctx saveGraphicsState];
        [[NSBezierPath bezierPathWithRect:NSInsetRect(frame, 1.0f, 1.0f)] setClip];
        [[NSColor colorWithCalibratedWhite:0.0f alpha:0.35] setFill];
        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
        [ctx restoreGraphicsState];
    }
    if (!self.state) {
        [ctx saveGraphicsState];
        [[NSBezierPath bezierPathWithRect:NSInsetRect(frame, 1.0f, 1.0f)] setClip];
        [[NSColor colorWithCalibratedWhite:0.0f alpha:0.6] setFill];
        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
        [ctx restoreGraphicsState];
    }
}

@end
