//
//  ModelGraph.m
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import "ModelGraph.h"

@implementation ModelGraph

@synthesize dataForPlots;
@synthesize currentIndex;
@synthesize newLimit;

float static dataLength = 75.0f;
float static yAxisPadding = -2.5f;


- (void)setUpAxesWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue
{
    // clear all paddings
    self.paddingBottom = 0;
    self.paddingTop = 0;
    self.paddingLeft = 0;
    self.paddingRight = 0;
    
    // Setup scatter plot space
    CPTColor *themeColor = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:1.0];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    //plotSpace.delegate = self;
    CPTPlotRange *range = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisPadding) length:CPTDecimalFromFloat(dataLength)];
    plotSpace.xRange = range;
    
    CPTPlotRange *range2 = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-4.5f) length:CPTDecimalFromFloat(9.0f)];
    plotSpace.yRange = range2;
    // Axes
    // Label x axis with a fixed interval policy
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.axisSet;
    
    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = themeColor;
    lineStyle.lineWidth = 1;
    
    CPTColor *themeColorFade = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:0.25];
    CPTMutableLineStyle *lineStyleSmall = [CPTMutableLineStyle lineStyle];
    lineStyleSmall.lineColor = themeColorFade;
    lineStyleSmall.lineWidth = 1;
    
    y.majorIntervalLength = CPTDecimalFromString(@"1");
    //    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
//    y.minorTicksPerInterval = 2;
    //    y.preferredNumberOfMajorTicks = 6;
    y.labelExclusionRanges = [NSArray arrayWithObject:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(0.5f)]];
    y.labelOffset = -5.0;
    y.axisLineStyle = lineStyle;
    y.majorTickLineStyle = lineStyle;
    y.minorTickLineStyle = lineStyle;
    y.labelRotation = M_PI_2;
    
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPTDecimalFromString(@"5");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    //    x.minorTicksPerInterval = 10;
    x.majorTickLineStyle = lineStyle;
    x.minorTickLineStyle = lineStyle;
    x.axisLineStyle = lineStyle;
    x.labelOffset = -5;
    x.labelRotation = (45 / 180.0 * M_PI);
    x.titleLocation = CPTDecimalFromString(@"3.0");
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = themeColor;
    
    if (self.bounds.size.width > 1000) {
        textStyle.fontSize = 20;
    }
    x.labelTextStyle = textStyle;
    x.majorGridLineStyle = lineStyleSmall;
    x.minorGridLineStyle = lineStyleSmall;
    
    y.labelTextStyle = textStyle;
    y.majorGridLineStyle = lineStyleSmall;
//    y.minorGridLineStyle = lineStyleSmall;
    
    self.axisSet.axes = [NSArray arrayWithObjects: x,y, nil];
}

- (void)setUpPlotWithLineNumberEqualsTo:(int)number
{
    self.newLimit = dataLength;
    
    if (!self.dataForPlots) {
        self.dataForPlots = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    }
    
    // Create the plot
    currentIndex = 0;
    
    for (int i = 0; i < number; i++) {
        CGColorRef lightBlue = CGColorCreateGenericRGB(15.0/255.0, 172.0/255.0, 239.0/255.0, 1.0f);
        CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
        dataSourceLinePlot.identifier = [NSString stringWithFormat:@"dataSourcePlot%d",i+1];
//        dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
//        dataSourceLinePlot.shadowOffset = CGSizeMake(.0,.0);
//        dataSourceLinePlot.shadowColor = lightBlue;
//        dataSourceLinePlot.shadowRadius = 5.0;
//        dataSourceLinePlot.shadowOpacity = 5.0f;
        dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
        
        CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
        lineStyle.lineWidth              = 3.0;
        lineStyle.lineColor              = [CPTColor colorWithCGColor:lightBlue];
        CFRelease(lightBlue);
        dataSourceLinePlot.dataLineStyle = lineStyle;
        dataSourceLinePlot.dataSource = self;
        [self addPlot:dataSourceLinePlot];        
        [self.dataForPlots addObject:[NSMutableArray arrayWithCapacity:0]];
    }
}

- (void)setUpLineColorWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue
{
    for (CPTScatterPlot *scatter in self.allPlots) {
        CPTMutableLineStyle *lineStyle = [[scatter.dataLineStyle mutableCopy] autorelease];
        CPTColor  *themeColor = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:1.0];
        lineStyle.lineColor = themeColor;
        scatter.dataLineStyle = lineStyle;
//        scatter.shadowColor = [themeColor cgColor];
    }
}

- (void)setUpLineColorWithCPTColors:(NSArray *)colors
{
    for (int i = 0; i < [self.allPlots count]; i++) {
        CPTMutableLineStyle *lineStyle = [[[[self.allPlots objectAtIndex:i] dataLineStyle] mutableCopy] autorelease];
        lineStyle.lineColor = [colors objectAtIndex:i];
        [[self.allPlots objectAtIndex:i] setDataLineStyle:lineStyle];
//        [[self.allPlots objectAtIndex:i] setShadowColor:[[colors objectAtIndex:i] cgColor]];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    int plotIndex = [[(NSString *)plot.identifier substringFromIndex:[(NSString *)plot.identifier length]-1] intValue]-1;

    return [[self.dataForPlots objectAtIndex:plotIndex] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    int plotIndex = [[(NSString *)plot.identifier substringFromIndex:[(NSString *)plot.identifier length]-1] intValue]-1;
    //try mixing index and data in same one array?
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
              num = [[[dataForPlots objectAtIndex:plotIndex] objectAtIndex:index] objectForKey:@"x"];
//            num = [NSNumber numberWithDouble:(([[dataForPlots objectAtIndex:plotIndex] count]-1)-index)*0.1];
            break;
            
        case CPTScatterPlotFieldY:
            num = [[[dataForPlots objectAtIndex:plotIndex] objectAtIndex:index] objectForKey:@"y"];
            break;
    }
    return num;
}

- (void)updateUsingData:(NSMutableArray *)data
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    int identifierCount = 0;
    if ([[data objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
        NSString *plotIdentifer = [NSString stringWithFormat:@"dataSourcePlot%d",1];
        CPTPlot *thePlot   = [self plotWithIdentifier:plotIdentifer];
        if ( thePlot ) {
            if ([[dataForPlots objectAtIndex:0] count] > dataLength * 10 )
            {
                
                [[dataForPlots objectAtIndex:0] removeObjectAtIndex:0];
                [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
            }
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
            if (currentIndex >= self.newLimit) {
                NSUInteger location = currentIndex - dataLength +floor(dataLength/5);
                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(location+yAxisPadding) length:CPTDecimalFromUnsignedInteger(dataLength)];
                CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.axisSet;
                axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%d",location]);
                self.newLimit += floor(dataLength/5);
            }
//            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
//            NSUInteger location       = (currentIndex >= dataLength ? currentIndex - dataLength + 1 : 0);
//            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(location+yAxisPadding)
//                                                            length:CPTDecimalFromUnsignedInteger(dataLength)];
//            CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.axisSet;
//            axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%d",location]);

            [[dataForPlots objectAtIndex:0] addObject:[data  lastObject]];
            [thePlot insertDataAtIndex:[[dataForPlots objectAtIndex:0] count] - 1 numberOfRecords:1];
        }


    }
    else
    {
        identifierCount = [data count];
        for (int i = 0 ; i < identifierCount; i++) {
            NSString *plotIdentifer = [NSString stringWithFormat:@"dataSourcePlot%d",i+1];
            CPTPlot *thePlot   = [self plotWithIdentifier:plotIdentifer];
            if ( thePlot ) {
                //because it's each currentIndex is 0.1 
                if ([[dataForPlots objectAtIndex:i] count] > dataLength * 10 )
                {
                    
                    [[dataForPlots objectAtIndex:i] removeObjectAtIndex:0];
                    [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
                }

                [[dataForPlots objectAtIndex:i] addObject:[[data objectAtIndex:i] lastObject]];
                [thePlot insertDataAtIndex:[[dataForPlots objectAtIndex:i] count] - 1 numberOfRecords:1];
            }
        }
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
        if (currentIndex >= self.newLimit) {
            NSUInteger location = currentIndex - dataLength +floor(dataLength/5);
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(location+yAxisPadding) length:CPTDecimalFromUnsignedInteger(dataLength)];
            CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.axisSet;
            axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%d",location]);
            self.newLimit += floor(dataLength/5);
        }
        
//        NSUInteger location       = (currentIndex >= newLimit ? currentIndex - dataLength : 0);
//        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(location+yAxisPadding)
//                                                        length:CPTDecimalFromUnsignedInteger((currentIndex >= dataLength)? dataLength : dataLength)];
//        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.axisSet;
//        axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%d",location]);

    }
    currentIndex += 0.1f;
    
    [pool drain];
}
@end
