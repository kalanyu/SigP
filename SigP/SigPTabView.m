//
//  SigPTabView.m
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import "SigPTabView.h"

@interface SigPTabView()
@property BOOL isTracking;
@property double threshold;
@property (strong) NSTrackingArea *leftRect, *rightRect;
@property id delegate;
@end

@implementation SigPTabView

@synthesize isTracking;
@synthesize threshold;
@synthesize leftRect, rightRect;
@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        threshold = 0.3;
        // Initialization code here.
//        [[self window] makeFirstResponder: self];
//        [[self window] setAcceptsMouseMovedEvents: YES];
//        if ([[self window] acceptsMouseMovedEvents]) {NSLog(@"window now acceptsMouseMovedEvents");}
//        else
//        {
//            NSLog(@"what the heck");
//        }
    }
    
    return self;
}

//when window is active
- (void)viewDidMoveToWindow
{
    
    leftRect = [self addTrackingRect:NSMakeRect(-5,
                                                0,
                                                [self window].frame.size.width/10,
                                                [self window].frame.size.height)
                               owner:self userData:NULL assumeInside:NO];
    rightRect = [self addTrackingRect:NSMakeRect(
                                                 [self window].frame.size.width - [self window].frame.size.width/10,
                                                 0,
                                                 [self window].frame.size.width/10,
                                                 [self window].frame.size.height)
                                owner:self userData:NULL assumeInside:NO];
}

//when frame(window) is resized
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self removeTrackingArea:leftRect];
    [self removeTrackingArea:rightRect];
    leftRect = [self addTrackingRect:NSMakeRect(-5,
                                                0,
                                                [self window].frame.size.width/10,
                                                [self window].frame.size.height)
                               owner:self userData:NULL assumeInside:NO];
    rightRect = [self addTrackingRect:NSMakeRect(
                                                 [self window].frame.size.width - [self window].frame.size.width/10,
                                                 0,
                                                 [self window].frame.size.width/10,
                                                 [self window].frame.size.height)
                                owner:self userData:NULL assumeInside:NO];

}
////when bound is resized
//- (void)setBounds:(NSRect)aRect
//{
//    [super setBounds:aRect];
//    [self removeTrackingArea:leftRect];
//    [self removeTrackingArea:rightRect];
//    leftRect = [self addTrackingRect:NSMakeRect([self window].frame.origin.x, [self window].frame.origin.y, [self window].frame.size.width/10, [self window].frame.size.height) owner:self userData:NULL assumeInside:NO];
//    rightRect = [self addTrackingRect:NSMakeRect(
//                                                 [self window].frame.size.width - [self window].frame.size.width/10,
//                                                 [self window].frame.origin.y,
//                                                 [self window].frame.size.width/10,
//                                                 [self window].frame.size.height)
//                                owner:self userData:NULL assumeInside:NO];
//}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
//if we need to track the cursor in real-time
//    [[self window] setAcceptsMouseMovedEvents:YES];
    NSInteger selectedIndex = [self indexOfTabViewItem:[self selectedTabViewItem]];

    if ([theEvent trackingArea] == leftRect) {
            if (selectedIndex > 0) {
                //0 for left
                [delegate cursorHasEnteredRegion:0];
//                NSLog(@"left");
//                [self selectTabViewItemAtIndex:--selectedIndex];
            }
    }
    else if([theEvent trackingArea] == rightRect){
            if (selectedIndex < 2) {
                //1 for right
                [delegate cursorHasEnteredRegion:1];
//                NSLog(@"right");
//                [self selectTabViewItemAtIndex:++selectedIndex];
            }
    }

}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[self window] setAcceptsMouseMovedEvents:NO];
    if ([theEvent trackingArea] == leftRect) {
//        NSLog(@"left area departed");
        [delegate cursorHasLeftRegion:0];
    }
    else if([theEvent trackingArea] == rightRect){
//        NSLog(@"right area departed");
        [delegate cursorHasLeftRegion:1];
    }
   
}

#pragma mark- NSResponder Events
- (void)touchesBeganWithEvent:(NSEvent *)event
{
//    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self];

//    NSArray *touchObjects = [touches allObjects];
//    
//    if (touchObjects.count == 3) {
//        _initialTouches[0] = [[touchObjects objectAtIndex:0] retain];
//        _initialTouches[1] = [[touchObjects objectAtIndex:1] retain];
//        _initialTouches[2] = [[touchObjects objectAtIndex:2] retain];
//    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseMoved inView:self];
    NSArray *touchObjects = [touches allObjects];

//    NSLog(@"%lf %lf",[self window].frame.origin.x, [self window].frame.origin.y);
    NSRect theFrame = [self window].frame;
    NSRect monitorFrame = [[[NSScreen screens] objectAtIndex:0] frame];
    
    if ([touchObjects count] == 1) {
        
        NSPoint touchLoc = ((NSTouch *)[touchObjects objectAtIndex:0]).normalizedPosition;
//        NSLog(@"current location : %lf : %lf", roundf(touchLoc.x * monitorFrame.size.width), roundf(touchLoc.y * monitorFrame.size.height));
        
        if (  roundf(touchLoc.x * monitorFrame.size.width) < (theFrame.origin.x + theFrame.size.width / 6) || roundf(touchLoc.x * monitorFrame.size.width) > ((theFrame.origin.x + theFrame.size.width) - theFrame.size.width/6)) {
//            NSLog(@"activation area touched. bounds : %lf and %lf", (theFrame.origin.x + theFrame.size.width / 6),  ((theFrame.origin.x + theFrame.size.width) - theFrame.size.width/6));
        }
    }
    
//
//    if (touchObjects.count == 3 && _initialTouches[0]) {
//        for (int i = 0; i < 3; i++) {
//            for (int j = 0; j < 3; j++) {
//                if ([_initialTouches[i].identity isEqual:[(NSTouch *)[touchObjects objectAtIndex:j] identity]]) {
//                    _currentTouches[i] = [[touchObjects objectAtIndex:j] retain];
//                }
//            }
//        }
//        CGFloat x1 = MIN(MIN(_initialTouches[0].normalizedPosition.x, _initialTouches[1].normalizedPosition.x), _initialTouches[2].normalizedPosition.x);
//        CGFloat x2 = MIN(MIN(_currentTouches[0].normalizedPosition.x, _currentTouches[1].normalizedPosition.x), _currentTouches[2].normalizedPosition.x);
//        
//        NSInteger selectedIndex = [self indexOfTabViewItem:[self selectedTabViewItem]];
//        
//        if (isTracking) {
//            if ((x1 - x2) > threshold) {
//                if (selectedIndex < 2) {
//                    [self selectTabViewItemAtIndex:++selectedIndex];
//                    isTracking = NO;
//                }
//            }
//            else if ((x1 - x2) < -threshold) {
//                if (selectedIndex > 0) {
//                    [self selectTabViewItemAtIndex:--selectedIndex];
//                    isTracking = NO;
//                }
//            }
//        }
//    }
    
}
- (void)touchesEndedWithEvent:(NSEvent *)event
{
//    isTracking = YES;
}

@end
