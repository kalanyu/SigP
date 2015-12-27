//
//  MainController.h
//  SigP
//
//  Created by KalanyuZ on 12/15/55 BE.
//  Copyright (c) 2555 KalanyuZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NIDAQreader.h"
//#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
#import "GCDAsyncSocket.h"

@interface MainController : NSObjectController <NIDAQreaderProtocol>
{
    IBOutlet NSWindow *mainWindow;

    NIDAQreader *dataReader;
    NSButton *ipAddress;
    
    int port;
    GCDAsyncSocket *listenSocket;
    dispatch_queue_t socketQueue;
    NSMutableArray *connectedSockets;
    bool writeOk;
    
    double channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6;
}
@property (assign) IBOutlet NSButton *ipAddress;
@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) NIDAQreader *dataReader;
@property (retain) NSMutableArray *plotBuffer, *graphCollections;

@property int port;
@property double channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6;

- (IBAction)readFromDAQ:(NSButton *)sender;

@end
