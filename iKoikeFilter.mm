//
//  iKoikeFilter.m
//  CPTTestApp
//
//  Created by Kalanyu Zintus-art on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "iKoikeFilter.h"

@implementation iKoikeFilter
@dynamic filter;

- (id)init {
    self = [super init];
    if (self) {
        [self setFilter:CKoikeFilter()];
    }
    return self;
}
@end
