//
//  MainController.h
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

#import "ModelGraph.h"
#import "SigPTabView.h"
#import "NIDAQreader.h"
#import "SigPButton.h"
#import "GCDAsyncSocket.h"

@interface MainController : NSObjectController <NIDAQreaderProtocol,cursorTrackingListener>
{
    IBOutlet NSWindow *mainWindow;
    IBOutlet CPTGraphHostingView *mergeGraphView;
    IBOutlet CPTGraphHostingView *viewChannel1;
    IBOutlet CPTGraphHostingView *viewChannel2;
    IBOutlet CPTGraphHostingView *viewChannel3;
    IBOutlet CPTGraphHostingView *viewChannel4;
    IBOutlet CPTGraphHostingView *viewChannel5;
    IBOutlet CPTGraphHostingView *viewChannel6;
    IBOutlet SigPTabView *mainTabview;
    ModelGraph *mergeGraph, *graphChannel1, *graphChannel2, *graphChannel3, *graphChannel4, *graphChannel5, *graphChannel6;

    NIDAQreader *dataReader;
    NSMutableArray *plotBuffer, *graphCollections;
    NSButton *rectifyButton;
    NSButton *filterButton;
    NSButton *normalizeButton;
    NSButton *serverButton;
    NSButton *readButton;
    NSButton *zscoreButton;
    NSButton *minmaxChannel1;
    NSButton *minmaxChannel2;
    NSButton *minmaxChannel3;
    NSButton *minmaxChannel4;
    NSButton *minmaxChannel5;
    NSButton *minmaxChannel6;
    NSButton *leftViewChanger, *rightViewChanger;
    NSTextField *filterBufferField;
    NSTextField *normalizeBufferField;
    NSButton *minmaxButton;
    NSButton *basealignButton;
    NSSlider *dataRateSlider;
    NSSlider *channelSlider;
    NSSlider *bufferTimeSlider;
    NSSlider *multiplierSlider;
    NSSlider *normalizationSlider;
    NSTextField *dataRateValue;
    NSTextField *channelValue;
    NSTextField *bufferTimeValue;
    NSTextField *multiplierValue;
    NSTextField *normalizationTimeValue;
    NSView *settingsView;
    NSButton *ipAddress;
    
    int port;
    GCDAsyncSocket *listenSocket;
    dispatch_queue_t socketQueue;
    NSMutableArray *connectedSockets;
    
    double channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6;
}
@property (assign) IBOutlet NSButton *ipAddress;
@property (assign) IBOutlet NSButton *rectifyButton;
@property (assign) IBOutlet NSButton *filterButton;
@property (assign) IBOutlet NSButton *normalizeButton;
@property (assign) IBOutlet NSButton *serverButton;
@property (assign) IBOutlet NSButton *readButton;
@property (assign) IBOutlet NSButton *zscoreButton;
@property (assign) IBOutlet NSButton *minmaxChannel1;
@property (assign) IBOutlet NSButton *minmaxChannel2;
@property (assign) IBOutlet NSButton *minmaxChannel3;
@property (assign) IBOutlet NSButton *minmaxChannel4;
@property (assign) IBOutlet NSButton *minmaxChannel5;
@property (assign) IBOutlet NSButton *minmaxChannel6;
@property (assign) IBOutlet NSTextField *filterBufferField;
@property (assign) IBOutlet NSTextField *normalizeBufferField;
@property (assign) IBOutlet NSButton *minmaxButton;
@property (assign) IBOutlet NSButton *basealignButton;
@property (assign) IBOutlet NSSlider *dataRateSlider;
@property (assign) IBOutlet NSSlider *channelSlider;
@property (assign) IBOutlet NSSlider *bufferTimeSlider;
@property (assign) IBOutlet NSSlider *multiplierSlider;
@property (assign) IBOutlet NSSlider *normalizationSlider;
@property (assign) IBOutlet NSTextField *dataRateValue;
@property (assign) IBOutlet NSTextField *channelValue;
@property (assign) IBOutlet NSTextField *bufferTimeValue;
@property (assign) IBOutlet NSTextField *multiplierValue;
@property (assign) IBOutlet NSTextField *normalizationTimeValue;


@property (assign) IBOutlet NSView *settingsView;
@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) IBOutlet CPTGraphHostingView *mergeGraphView;
@property (assign) IBOutlet CPTGraphHostingView *viewChannel1;
@property (assign) IBOutlet CPTGraphHostingView *viewChannel2;
@property (assign) IBOutlet CPTGraphHostingView *viewChannel3;
@property (assign) IBOutlet CPTGraphHostingView *viewChannel4;
@property (assign) IBOutlet CPTGraphHostingView *viewChannel5;
@property (assign) IBOutlet CPTGraphHostingView *viewChannel6;
@property (assign) IBOutlet SigPTabView *mainTabview;

@property (retain) ModelGraph *mergeGraph, *graphChannel1, *graphChannel2, *graphChannel3, *graphChannel4, *graphChannel5, *graphChannel6;
@property (assign) NIDAQreader *dataReader;
@property (retain) NSMutableArray *plotBuffer, *graphCollections;

@property int port;
@property double channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6;

- (IBAction)readFromDAQ:(NSButton *)sender;
- (IBAction)rectifyButtonClicked:(NSButton *)sender;
- (IBAction)serverButtonClicked:(NSButton *)sender;
- (IBAction)filterButtonClicked:(NSButton *)sender;
- (IBAction)normalizeButtonClicked:(NSButton *)sender;
- (IBAction)zscoreButtonClicked:(NSButton *)sender;
- (IBAction)minmaxButtonClicked:(NSButton *)sender;
- (IBAction)basealignButtonClicked:(NSButton *)sender;
- (IBAction)sliderValueChanged:(NSSlider *)sender;
- (void)changeRightTab;
- (void)changeLeftTab;

@end
