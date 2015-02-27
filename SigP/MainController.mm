//
//  MainController.m
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import "MainController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation MainController

@synthesize ipAddress;
@synthesize rectifyButton;
@synthesize filterButton;
@synthesize normalizeButton;
@synthesize serverButton;
@synthesize readButton;
@synthesize zscoreButton;
@synthesize minmaxChannel1;
@synthesize minmaxChannel2;
@synthesize minmaxChannel3;
@synthesize minmaxChannel4;
@synthesize minmaxChannel5;
@synthesize minmaxChannel6;
@synthesize filterBufferField;
@synthesize normalizeBufferField;
@synthesize minmaxButton;
@synthesize basealignButton;
@synthesize bufferTimeSlider;
@synthesize multiplierSlider;
@synthesize normalizationSlider;
@synthesize dataRateValue;
@synthesize channelValue;
@synthesize bufferTimeValue;
@synthesize multiplierValue;
@synthesize normalizationTimeValue;
@synthesize settingsView;
@synthesize mainWindow;
@synthesize mergeGraphView;
@synthesize viewChannel1;
@synthesize viewChannel2;
@synthesize viewChannel3;
@synthesize viewChannel4;
@synthesize viewChannel5;
@synthesize viewChannel6;
@synthesize mainTabview;
@synthesize mergeGraph, graphChannel1, graphChannel2, graphChannel3, graphChannel4, graphChannel5, graphChannel6;
@synthesize plotBuffer, graphCollections;
@synthesize dataReader;
@synthesize port;
@synthesize channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6;
@synthesize channelSlider, dataRateSlider;

#pragma mark core functions

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.mainWindow setBackgroundColor:[NSColor colorWithCalibratedRed:20/255.0f green:10/255.0f blue:10/255.0f alpha:1.0]];
    [self.mainTabview setDrawsBackground:NO];
    [self.mainTabview setDelegate:(id)self];
    //set the view to accept touch events
    //[self.mainTabview setAcceptsTouchEvents:YES];

    mergeGraph = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(mergeGraphView.bounds)];
    [mergeGraph setUpAxesWithRed:0.0f Green:204/255.0f Blue:1.0f];
    [mergeGraph setUpPlotWithLineNumberEqualsTo:6];
    [mergeGraph setUpLineColorWithCPTColors:[NSArray arrayWithObjects:
                                             [CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.0f alpha:1.0f],
                                             [CPTColor colorWithComponentRed:0.0f green:51/255.0f blue:1.0f alpha:1.0f],
                                             [CPTColor colorWithComponentRed:1.0f green:1.0f blue:0.0f alpha:1.0f],
                                             [CPTColor colorWithComponentRed:0.0f green:153/255.0f blue:0.0f alpha:1.0f],
                                             [CPTColor colorWithComponentRed:51/255.0f green:204/255.0f blue:153/255.0f alpha:1.0f],
                                             [CPTColor colorWithComponentRed:0.0f green:204/255.0f blue:204/255.0f alpha:1.0f]
                                             , nil]];
    mergeGraphView.hostedGraph = mergeGraph;

    graphChannel1 = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(viewChannel1.bounds)];
    [graphChannel1 setUpAxesWithRed:1.0f Green:0.0f Blue:0.0f];
    [graphChannel1 setUpPlotWithLineNumberEqualsTo:1];
    [graphChannel1 setUpLineColorWithRed:1.0f Green:0.0f Blue:0.0f];
    [graphChannel1 reloadData];
    [viewChannel1 setHostedGraph:graphChannel1];
    
    graphChannel2 = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(viewChannel2.frame)];
    [graphChannel2 setUpAxesWithRed:0.0f Green:51/255.0f Blue:1.0f];
    [graphChannel2 setUpPlotWithLineNumberEqualsTo:1];
    [graphChannel2 setUpLineColorWithRed:0.0f Green:51/255.0f Blue:1.0f];
    [graphChannel2 reloadData];
    [viewChannel2 setHostedGraph:graphChannel2];

    
    graphChannel3 = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(viewChannel3.frame)];
    [graphChannel3 setUpAxesWithRed:1.0f Green:1.0f Blue:0.0f];
    [graphChannel3 setUpPlotWithLineNumberEqualsTo:1];
    [graphChannel3 setUpLineColorWithRed:1.0f Green:1.0f Blue:0.0f];
    [graphChannel3 reloadData];
    [viewChannel3 setHostedGraph:graphChannel3];
    
    graphChannel4 = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(viewChannel4.frame)];
    [graphChannel4 setUpAxesWithRed:0.0f Green:153/255.0f Blue:0.0f];
    [graphChannel4 setUpPlotWithLineNumberEqualsTo:1];
    [graphChannel4 setUpLineColorWithRed:0.0f Green:153/255.0f Blue:0.0f];
    [graphChannel4 reloadData];
    [viewChannel4 setHostedGraph:graphChannel4];
    
    graphChannel5 = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(viewChannel5.frame)];
    [graphChannel5 setUpAxesWithRed:51/255.0f Green:204/255.0f Blue:153/255.0f];
    [graphChannel5 setUpPlotWithLineNumberEqualsTo:1];
    [graphChannel5 setUpLineColorWithRed:51/255.0f Green:204/255.0f Blue:153/255.0f];
    [graphChannel5 reloadData];
    [viewChannel5 setHostedGraph:graphChannel5];
    
    graphChannel6 = [[ModelGraph alloc] initWithFrame:NSRectToCGRect(viewChannel6.frame)];
    [graphChannel6 setUpAxesWithRed:0 Green:204/255.0f Blue:204/255.0f];
    [graphChannel6 setUpPlotWithLineNumberEqualsTo:1];
    [graphChannel6 setUpLineColorWithRed:0 Green:204/255.0f Blue:204/255.0f];
    [graphChannel6 reloadData];
    [viewChannel6 setHostedGraph:graphChannel6];
    
    graphCollections = [[NSMutableArray alloc] initWithObjects:mergeGraph, graphChannel1, graphChannel2, graphChannel3, graphChannel4, graphChannel5, graphChannel6, nil];
//    [mergeGraphView setAcceptsTouchEvents:NO];
    
    NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraph setAlignment:NSCenterTextAlignment];
    NSFont *font = [NSFont boldSystemFontOfSize:15.0];
    
    NSDictionary *attributeOn = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, paragraph,NSParagraphStyleAttributeName, font, NSFontAttributeName, nil];
    NSDictionary *attributeOff = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor darkGrayColor], NSForegroundColorAttributeName, paragraph, NSParagraphStyleAttributeName, font, NSFontAttributeName, nil];

    [rectifyButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"RECTIFY : OFF" attributes:attributeOff] autorelease]];  
    [rectifyButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"RECTIFY : ON" attributes:attributeOn] autorelease]];
    [rectifyButton setFocusRingType:NSFocusRingTypeNone];
    
    [filterButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"FILTER : OFF" attributes:attributeOff] autorelease]];
    [filterButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"FILTER : ON" attributes:attributeOn] autorelease]];
    [filterButton setFocusRingType:NSFocusRingTypeNone];

    [normalizeButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"NORMALIZE : OFF" attributes:attributeOff] autorelease]];
    [normalizeButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"NORMALIZE : ON" attributes:attributeOn] autorelease]];
    [normalizeButton setFocusRingType:NSFocusRingTypeNone];

    [basealignButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"BASE ALIGN : OFF" attributes:attributeOff] autorelease]];
    [basealignButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"BASE ALIGN : ON" attributes:attributeOn] autorelease]];
    [basealignButton setFocusRingType:NSFocusRingTypeNone];

    [serverButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"SERVER : OFF" attributes:attributeOff] autorelease]];
    [serverButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"SERVER : ON" attributes:attributeOn] autorelease]];
    [serverButton setFocusRingType:NSFocusRingTypeNone];
    
    [readButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"READ" attributes:attributeOff] autorelease]];
    [readButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"STOP" attributes:attributeOn] autorelease]];
    [readButton setFocusRingType:NSFocusRingTypeNone];
    
    [zscoreButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"Z-SCORE" attributes:attributeOff] autorelease]];
    [minmaxButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"MIN MAX" attributes:attributeOff] autorelease]];
    [minmaxChannel1 setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"1" attributes:attributeOff] autorelease]];
    [minmaxChannel2 setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"2" attributes:attributeOff] autorelease]];
    [minmaxChannel3 setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"3" attributes:attributeOff] autorelease]];
    [minmaxChannel4 setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"4" attributes:attributeOff] autorelease]];
    [minmaxChannel5 setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"5" attributes:attributeOff] autorelease]];
    [minmaxChannel6 setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"6" attributes:attributeOff] autorelease]];
    [zscoreButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"Z-SCORE" attributes:attributeOn] autorelease]];
    [minmaxButton setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"MIN MAX" attributes:attributeOn] autorelease]];
    [minmaxChannel1 setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"1" attributes:attributeOn] autorelease]];
    [minmaxChannel2 setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"2" attributes:attributeOn] autorelease]];
    [minmaxChannel3 setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"3" attributes:attributeOn] autorelease]];
    [minmaxChannel4 setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"4" attributes:attributeOn] autorelease]];
    [minmaxChannel5 setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"5" attributes:attributeOn] autorelease]];
    [minmaxChannel6 setAttributedAlternateTitle:[[[NSAttributedString alloc] initWithString:@"6" attributes:attributeOn] autorelease]];
    
    [settingsView setWantsLayer:YES];
    [[settingsView layer] setBackgroundColor:CGColorCreateGenericRGB(0, 0.5, 0.7, 0.2)];
    [[settingsView layer] setBorderColor:CGColorCreateGenericRGB(0, 204/255.0f, 1.0, 1.0)];
    [[settingsView layer] setBorderWidth:1.0f];
    NSString *address = @"OFFLINE";
    
    [ipAddress setAttributedTitle:[[[NSAttributedString alloc] initWithString:address attributes:attributeOn] autorelease]];
    [ipAddress setEnabled:NO];
    [ipAddress setFocusRingType:NSFocusRingTypeNone];    
    
    [dataRateValue setStringValue:[NSString stringWithFormat:@"%d",[dataRateSlider intValue]]];
    [channelValue setStringValue:[NSString stringWithFormat:@"%d",[channelSlider intValue]]];
    [bufferTimeValue setStringValue:[NSString stringWithFormat:@"%d",[bufferTimeSlider intValue]]];
    [multiplierValue setStringValue:[NSString stringWithFormat:@"%d",[multiplierSlider intValue]]];
    [normalizationTimeValue setStringValue:[NSString stringWithFormat:@"%d",[normalizationSlider intValue]]];

    [paragraph release];
    [attributeOff release];
    [attributeOn release];
}

- (IBAction)readFromDAQ:(NSButton *)sender {
    NSLog(@"%d",[sender state]);
    if ([sender state] == 1) {
        //slider from 1 to 6 channels
        self.dataReader = [[[NIDAQreader alloc] initWithNumberOfChannels:[channelSlider intValue] andSamplingRate:[dataRateSlider intValue]] autorelease];
        self.dataReader.delegate = self;
        
        NSLog(@"%d channel %d sample rate",[channelSlider intValue], [dataRateSlider intValue]);
        
        if (self.plotBuffer)
        {
            [self.plotBuffer removeAllObjects];
        }
        else
        {
            self.plotBuffer = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        }

        //specify sampling rate as an argument
        NSInvocationOperation *operation = [[[NSInvocationOperation alloc] initWithTarget:self.dataReader selector:@selector(startCollection) object:nil] autorelease];
        NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
        [operationQueue addOperation:operation];
    }
    else {
        [self.dataReader stop];
    }
}


- (void)incomingStream:(NSMutableArray *)data
{
    //min-max normalize buffer
    //koike filter buffer
    for (int i = 0; i < [graphCollections count]; i++) {
        if (i == 0) {
            //all channels for the mergeGraph
            [[graphCollections objectAtIndex:i] updateUsingData:data];
            
            channelVal1 = [[[[data objectAtIndex:0] lastObject] objectForKey:@"y"] doubleValue];
            channelVal2 = [[[[data objectAtIndex:1] lastObject] objectForKey:@"y"] doubleValue];
            channelVal3 = [[[[data objectAtIndex:2] lastObject] objectForKey:@"y"] doubleValue];
            channelVal4 = [[[[data objectAtIndex:3] lastObject] objectForKey:@"y"] doubleValue];
            channelVal5 = [[[[data objectAtIndex:4] lastObject] objectForKey:@"y"] doubleValue];
            channelVal6 = [[[[data objectAtIndex:5] lastObject] objectForKey:@"y"] doubleValue];
            
//            NSLog(@"%lf %lf %lf %lf %lf %lf", channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6);
        }
        else
        {
            //split channel the number of channels will always have one less than the graph ( merge )
            [[graphCollections objectAtIndex:i] updateUsingData:[data objectAtIndex:i-1]];
        }
    }
}

- (IBAction)serverButtonClicked:(NSButton *)sender
{
    NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraph setAlignment:NSCenterTextAlignment];
    NSFont *font = [NSFont boldSystemFontOfSize:15.0];
    
    NSDictionary *attributeOn = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, paragraph,NSParagraphStyleAttributeName, font, NSFontAttributeName, nil];
    
    if ([ipAddress.title isNotEqualTo:@"OFFLINE"]) {

        [ipAddress setAttributedTitle:[[[NSAttributedString alloc] initWithString:@"OFFLINE" attributes:attributeOn] autorelease]];
    }
    else {
        port = 6363;
 
        NSString *address = @"STARTUP ERROR";
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0)
        {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while(temp_addr != NULL)
            {
                if(temp_addr->ifa_addr->sa_family == AF_INET)
                {
                    // Check if interface is en0 which is the wifi connection on the iPhone
                    if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get NSString from C String
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }//if the first interface doesn't contain ip address, try en1 (for laptops)
                    if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
                    if ([address isNotEqualTo:@"STARTUP ERROR"]) {
                        address = [[@"ONLINE : " stringByAppendingString:address] stringByAppendingFormat:@":%d",port];
                        break;
                    }
                }
                
                temp_addr = temp_addr->ifa_next;
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
        
        socketQueue = dispatch_queue_create("socketQueue", NULL);
        listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
        //setup an array to store all accepted client connections
        connectedSockets = [[NSMutableArray alloc] initWithCapacity:10];

        [ipAddress setAttributedTitle:[[[NSAttributedString alloc] initWithString:address attributes:attributeOn] autorelease]];
        
        NSError *error = nil;
        if (![listenSocket acceptOnPort:port error:&error]) {
            NSLog(@"error starting server : %@", error);
        }
        else {
            NSLog(@"server started on port :%d", port);
        }
    }
}

- (IBAction)filterButtonClicked:(NSButton *)sender
{
    [self.dataReader activateKoikefilterWithBuffersize:[dataRateSlider intValue]/2];
//    NSLog(@"%d",[bufferTimeSlider intValue] * [dataRateSlider intValue]);
}

- (IBAction)normalizeButtonClicked:(NSButton *)sender
{
    [self.dataReader activateNormalizationWithBufferSize:[normalizationSlider intValue] * [dataRateSlider intValue]];
    NSLog(@"%d",[normalizationSlider intValue] * [dataRateSlider intValue]);
}

- (IBAction)zscoreButtonClicked:(NSButton *)sender
{
    [sender setState:1];
    [minmaxButton setState:0];
    [minmaxChannel1 setEnabled:NO];
    [minmaxChannel2 setEnabled:NO];
    [minmaxChannel3 setEnabled:NO];
    [minmaxChannel4 setEnabled:NO];
    [minmaxChannel5 setEnabled:NO];
    [minmaxChannel6 setEnabled:NO];
}

- (IBAction)minmaxButtonClicked:(NSButton *)sender
{
    [sender setState:1];
    [zscoreButton setState:0];
    [minmaxChannel1 setEnabled:YES];
    [minmaxChannel2 setEnabled:YES];
    [minmaxChannel3 setEnabled:YES];
    [minmaxChannel4 setEnabled:YES];
    [minmaxChannel5 setEnabled:YES];
    [minmaxChannel6 setEnabled:YES];
}

- (IBAction)basealignButtonClicked:(NSButton *)sender {
    [self.dataReader activateZscoreWithBufferSize:[dataRateSlider intValue] * 2];
}

- (IBAction)sliderValueChanged:(NSSlider *)sender {
    if (sender == dataRateSlider) {
        [dataRateValue setStringValue:[NSString stringWithFormat:@"%d",[dataRateSlider intValue]]];
    }
    if (sender == channelSlider)
    {
        [channelValue setStringValue:[NSString stringWithFormat:@"%d",[channelSlider intValue]]];
    }
    if (sender == bufferTimeSlider) {
        [bufferTimeValue setStringValue:[NSString stringWithFormat:@"%d",[bufferTimeSlider intValue]]];
    }
    if (sender == multiplierSlider) {
        [multiplierValue setStringValue:[NSString stringWithFormat:@"%d",[multiplierSlider intValue]]];
        if (self.dataReader) {
            [self.dataReader setGainMultiplier:[multiplierSlider intValue]];
        }
    }
    if (sender == normalizationSlider) {
        [normalizationTimeValue setStringValue:[NSString stringWithFormat:@"%d",[normalizationSlider intValue]]];
    }
}

- (void)dealloc
{
    [mergeGraph release];
    [graphChannel1 release];
    [graphChannel2 release];
    [graphChannel3 release];
    [graphChannel4 release];
    [graphChannel5 release];
    [graphChannel6 release];
    [graphCollections release];
    [super dealloc];
}

- (void)cursorHasEnteredRegion:(int)areaCode
{
    //left region
    if (areaCode == 0) {
        if (leftViewChanger) {
            [leftViewChanger removeFromSuperview];
        }
        NSImage *leftArrow = [NSImage imageNamed:@"leftArrow"];
        leftViewChanger = [[NSButton alloc] initWithFrame: NSMakeRect(-leftArrow.size.width, (mainWindow.frame.size.height/2)-(leftArrow.size.height/2), leftArrow.size.width,leftArrow.size.height)];
        [leftViewChanger setImagePosition:NSImageOnly];
        [leftViewChanger setBordered:NO];
        [leftViewChanger setButtonType:NSMomentaryChangeButton];
        [leftViewChanger setBezelStyle:NSRegularSquareBezelStyle];
        [leftViewChanger setImage:leftArrow];
        [leftViewChanger setAction:@selector(changeLeftTab)];
        [leftViewChanger setTarget:self];
        [[self.mainWindow contentView] addSubview:leftViewChanger];

        NSViewAnimation *slideAnim;
        NSRect before, after;
        NSMutableDictionary *valueDict;
        
        valueDict = [NSMutableDictionary dictionaryWithCapacity:3];
        before = leftViewChanger.frame;
        [valueDict setObject:leftViewChanger forKey:NSViewAnimationTargetKey];
        
        [valueDict setObject:[NSValue valueWithRect:before] forKey:NSViewAnimationStartFrameKey];
        
        after = before;
        after.origin.x += leftArrow.size.width;
        
        [valueDict setObject:[NSValue valueWithRect:after] forKey:NSViewAnimationEndFrameKey];
    
        slideAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:valueDict, nil]];
        [slideAnim setDuration:0.25];
//        [slideAnim setAnimationCurve:NSAnimationEaseOut];
        [slideAnim startAnimation];
        [slideAnim release];
        
    }
    else if(areaCode == 1)
    {
        if (rightViewChanger) {
            [rightViewChanger removeFromSuperview];
        }
        NSImage *rightArrow = [NSImage imageNamed:@"rightArrow"];
        rightViewChanger = [[NSButton alloc] initWithFrame: NSMakeRect(mainWindow.frame.size.width, (mainWindow.frame.size.height/2)-(rightArrow.size.height/2), rightArrow.size.width,rightArrow.size.height)];
        [rightViewChanger setImagePosition:NSImageOnly];
        [rightViewChanger setBordered:NO];
        [rightViewChanger setButtonType:NSMomentaryChangeButton];
        [rightViewChanger setBezelStyle:NSRegularSquareBezelStyle];
        [rightViewChanger setImage:rightArrow];
        [rightViewChanger setAction:@selector(changeRightTab)];
        [rightViewChanger setTarget:self];
        [[self.mainWindow contentView] addSubview:rightViewChanger];
        NSViewAnimation *slideAnim;
        NSRect before, after;
        NSMutableDictionary *valueDict;
        
        valueDict = [NSMutableDictionary dictionaryWithCapacity:3];
        before = rightViewChanger.frame;
        [valueDict setObject:rightViewChanger forKey:NSViewAnimationTargetKey];
        
        [valueDict setObject:[NSValue valueWithRect:before] forKey:NSViewAnimationStartFrameKey];
        
        after = before;
        after.origin.x -= rightArrow.size.width;
        
        [valueDict setObject:[NSValue valueWithRect:after] forKey:NSViewAnimationEndFrameKey];
        
        slideAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:valueDict, nil]];
        [slideAnim setDuration:0.25];
        //        [slideAnim setAnimationCurve:NSAnimationEaseOut];
        [slideAnim startAnimation];
        [slideAnim release];
    }
}

- (void)changeLeftTab
{
    NSInteger currentIndex = [self.mainTabview indexOfTabViewItem:[self.mainTabview selectedTabViewItem]];
    NSLog(@"%d",currentIndex);
    if (currentIndex > 0) {
        NSLog(@"left tab");
        [self.mainTabview selectTabViewItemAtIndex:--currentIndex];
    }
    if (leftViewChanger) {
        [leftViewChanger removeFromSuperview];
    }
}

- (void)changeRightTab
{
    NSInteger currentIndex = [self.mainTabview indexOfTabViewItem:[self.mainTabview selectedTabViewItem]];
    NSLog(@"%d",currentIndex);
    if (currentIndex < 2) {
        NSLog(@"right tab");
        [self.mainTabview selectTabViewItemAtIndex:++currentIndex];
    }
    if (rightViewChanger) {
        [rightViewChanger removeFromSuperview];
    }
}

- (void)cursorHasLeftRegion:(int)areaCode
{
    [self.mainTabview setNeedsDisplay:YES];
    if (areaCode == 0) {
        [leftViewChanger removeFromSuperview];
    }
    else if(areaCode == 1)
    {
        [rightViewChanger removeFromSuperview];
    }
}

- (IBAction)rectifyButtonClicked:(NSButton *)sender
{
    [self.dataReader setRectify:![self.dataReader rectify]];
}

#pragma mark socket programming

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
	
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
	}
	
	NSString *host = [newSocket connectedHost];
	UInt16 socketPort = [newSocket connectedPort];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSLog(@"Accepted client %@:%hu", host, socketPort);
		
		[pool release];
        for (GCDAsyncSocket *socket in connectedSockets) {
            NSData *writeOutData = [[NSString stringWithFormat:@"Begin\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
            [socket writeData:writeOutData withTimeout:100 tag:1];
        }
        
	});
	
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	// This method is executed on the socketQueue (not the main thread)
    //	NSLog(@"data is written");
    //	if (tag == 2)
    //	{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
    //	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// This method is executed on the socketQueue (not the main thread)
	
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
        NSRange range = [httpResponse rangeOfString:@"Ack"];
        if (range.location != NSNotFound) {
            NSData *status = [[NSString stringWithFormat:@"%lf,%lf,%lf,%lf,%lf,%lf\r\n", channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6] dataUsingEncoding:NSUTF8StringEncoding];
            [sock writeData:status withTimeout:100 tag:1];
        }
		[pool release];
	});
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != listenSocket)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			
			[pool release];
		});
		
		@synchronized(connectedSockets)
		{
			[connectedSockets removeObject:sock];
		}
	}
}

- (void)applicationWillTerminate
{
    // Stop accepting connections
    [listenSocket disconnect];
    
    // Stop any client connections
    @synchronized(connectedSockets)
    {
        NSUInteger i;
        for (i = 0; i < [connectedSockets count]; i++)
        {
            // Call disconnect on the socket,
            // which will invoke the socketDidDisconnect: method,
            // which will remove the socket from the list.
            [[connectedSockets objectAtIndex:i] disconnect];
        }
    }
    
    NSLog(@"Stopped Echo server");
}


@end
