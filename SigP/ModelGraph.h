//
//  ModelGraph.h
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import <CorePlot/CorePlot.h>
#import <Cocoa/Cocoa.h>

@interface ModelGraph : CPTXYGraph <CPTPlotDataSource>
{
    NSMutableArray *dataForPlots;
    double currentIndex;
    float newLimit;
}

@property double currentIndex;
@property (retain) NSMutableArray *dataForPlots;
@property float newLimit;

- (void)setUpAxesWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue;
- (void)updateUsingData:(NSMutableArray *)data;
- (void)setUpPlotWithLineNumberEqualsTo:(int)number;
- (void)setUpLineColorWithCPTColors:(NSArray *)colors;
- (void)setUpLineColorWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue;

@end
