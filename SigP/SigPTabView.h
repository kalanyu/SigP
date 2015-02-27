//
//  SigPTabView.h
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol cursorTrackingListener <NSObject>
- (void)cursorHasEnteredRegion:(int)areaCode;
- (void)cursorHasLeftRegion:(int)areaCode;
@end

@interface SigPTabView : NSTabView
{
    NSTouch *_initialTouches[3], *_currentTouches[3];
    BOOL isTracking;
    double threshold;
    NSTrackingArea *leftRect, *rightRect;
    id<cursorTrackingListener> delegate;
}
@end
