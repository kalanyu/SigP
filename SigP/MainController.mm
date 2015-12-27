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
@synthesize mainWindow;
@synthesize dataReader;
@synthesize port;
@synthesize channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6;

#pragma mark core functions

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.mainWindow setBackgroundColor:[NSColor colorWithCalibratedRed:20/255.0f green:10/255.0f blue:10/255.0f alpha:1.0]];
      NSString *address = @"OFFLINE";
    
 }

- (IBAction)filterButtonClicked:(NSButton *)sender
{
    [self.dataReader activateKoikefilterWithBuffersize: 50];
    //    NSLog(@"%d",[bufferTimeSlider intValue] * [dataRateSlider intValue]);
}

- (IBAction)normalizeButtonClicked:(NSButton *)sender
{
    [self.dataReader activateNormalizationWithBufferSize: 200];
//    NSLog(@"%d",[normalizationSlider intValue] * [dataRateSlider intValue]);
}


- (IBAction)rectifyButtonClicked:(NSButton *)sender
{
    [self.dataReader setRectify:![self.dataReader rectify]];
}

- (IBAction)basealignButtonClicked:(NSButton *)sender {
    [self.dataReader activateZscoreWithBufferSize:50 * 2];
}

- (IBAction)readFromDAQ:(NSButton *)sender {
    NSLog(@"reading from daq");
    if ([sender state] == 1) {
        //slider from 1 to 6 channels
//        self.dataReader = [[[NIDAQreader alloc] initWithNumberOfChannels:[channelSlider intValue] andSamplingRate:[dataRateSlider intValue]] autorelease];
        self.dataReader = [[[NIDAQreader alloc] initWithNumberOfChannels:1 andSamplingRate:100] autorelease];
        self.dataReader.delegate = self;
        
//        NSLog(@"%d channel %d sample rate",[channelSlider intValue], [dataRateSlider intValue]);
        
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

            
            channelVal1 = [[[[data objectAtIndex:0] lastObject] objectForKey:@"y"] doubleValue];
            channelVal2 = [[[[data objectAtIndex:1] lastObject] objectForKey:@"y"] doubleValue];
            channelVal3 = [[[[data objectAtIndex:2] lastObject] objectForKey:@"y"] doubleValue];
            channelVal4 = [[[[data objectAtIndex:3] lastObject] objectForKey:@"y"] doubleValue];
            channelVal5 = [[[[data objectAtIndex:4] lastObject] objectForKey:@"y"] doubleValue];
            channelVal6 = [[[[data objectAtIndex:5] lastObject] objectForKey:@"y"] doubleValue];
            
            NSLog(@"%lf %lf %lf %lf %lf %lf", channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6);

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
        port = 6353;
 
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


- (void)dealloc
{
    [super dealloc];
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
            socket.delegate = self;
            NSData *writeOutData = [[NSString stringWithFormat:@"Welcome\n"] dataUsingEncoding:NSUTF8StringEncoding];
            [socket writeData:writeOutData withTimeout:-1 tag:1];
        }
        
	});
	
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	// This method is executed on the socketQueue (not the main thread)
//    	NSLog(@"data is written");
    //	if (tag == 2)
    //	{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:tag];
    //	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// This method is executed on the socketQueue (not the main thread)
//    NSLog(@"data read");
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",httpResponse);
        NSRange range = [httpResponse rangeOfString:@"Ack"];
        if (range.location != NSNotFound) {
            NSData *status = [[NSString stringWithFormat:@"%lf,%lf,%lf,%lf,%lf,%lf\n", channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6] dataUsingEncoding:NSUTF8StringEncoding];
//            NSLog(@"%@",[NSString stringWithFormat:@"%lf,%lf,%lf,%lf,%lf,%lf\n", channelVal1, channelVal2, channelVal3, channelVal4, channelVal5, channelVal6]);
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
