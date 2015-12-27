//
//  NIDAQreader.m
//  CPTTestApp
//
//  Created by Kalanyu Zintus-art on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NIDAQreader.h"
#include <stdio.h>
#include <time.h>
#include <new> //use to standard placement form of new
#include <math.h>

#define DAQmxErrChk(functionCall) { if( DAQmxFailed(error=(functionCall)) ) { goto Error; } }
#define KFILTER_OFF 1
#define KFILTER_ON 2
#define NORMALIZE_ON 1
#define NORMALIZE_WORKING 2
#define NORMALIZE_OFF 0
#define ZSCORE_ON 1
#define ZSCORE_WORKING 2
#define ZSCORE_OFF 0

@implementation NIDAQreader
@synthesize delegate, incomingData, sampleRate, pointsToRead, totalRead, running, channels;
@synthesize noOfChannels;
@synthesize normalizeBuffer;
@synthesize normalizeParameters;
@synthesize zscoreBuffer;
@synthesize fileHandle;
@synthesize zscoreParameters;
@synthesize gainMultiplier;
@synthesize rectify;

int static kFilterStat;
int static normalizeStat;
int static normalizeBufferSize;
int static zscoreStat;
int static zscoreBufferSize;


- (id)init {
    self = [super init];
    if (self) {
        self.incomingData = [NSMutableArray arrayWithObjects:
                             [NSMutableArray arrayWithCapacity:1000], 
                             [NSMutableArray arrayWithCapacity:1000],
                             [NSMutableArray arrayWithCapacity:1000],
                             [NSMutableArray arrayWithCapacity:1000],
                             nil];
        sampleRate = 2000;
        pointsToRead = 50;
        totalRead = 0;
        currentIndex = -5.0;
        rectify = YES;
        kFilterStat = KFILTER_OFF;
    }
    return self;
}

- (id)initWithNumberOfChannels:(int)numbers andSamplingRate:(int)samplingRate
{
    self = [super init];
    if (self) {
        channels = @"";
        noOfChannels = numbers;
        self.incomingData = [NSMutableArray arrayWithCapacity:numbers];
        for (int i = 0; i < numbers; i++) {
            [self.incomingData addObject:[NSMutableArray arrayWithCapacity:1000]];
            if (numbers - i == 1) {
                channels = [channels stringByAppendingFormat:@"Dev1/ai%d",i];
            }
            else {
                channels = [channels stringByAppendingFormat:@"Dev1/ai%d, ",i];
            }
        }
        [channels retain];
        //minimum is 60 fps
        sampleRate = samplingRate;
        pointsToRead = 1;
        totalRead = 0;
        currentIndex = -5.0;
        rectify = NO;
        kFilterStat = KFILTER_OFF;
        gainMultiplier = 1;
    }
    return self;
}

- (void)startCollection
{
    running = YES;
    // Task parameters
    int32       error = 0;
    taskHandle = 0;
    char        errBuff[2048]={'\0'};
//    t ime_t      startTime;
    
    // Channel parameters
    float64     min = -10.0;
    float64     max = 10.0;
    
    // Timing parameters
    char        clockSource[] = "OnboardClock";
    //    uInt64      samplesPerChan = 1000; not neccessary because its on cont mode
    
    // Data read parameters
    #define     bufferSize (uInt32) 4000
    float64     data[pointsToRead * noOfChannels];
    int32       pointsRead;
    float64     timeout = 5.0;

    fileManager = [NSFileManager defaultManager];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY_MM_dd_kk_mm_ss"];
    NSString *fileName = [NSString stringWithFormat:@"%@/Desktop/EMGSensingData/%@.csv",NSHomeDirectory(),[formatter stringFromDate:date]];

    DAQmxErrChk (DAQmxBaseCreateTask("",&taskHandle));
    DAQmxErrChk (DAQmxBaseCreateAIVoltageChan(taskHandle,[channels cStringUsingEncoding:NSUTF8StringEncoding],"",DAQmx_Val_Cfg_Default,min,max,DAQmx_Val_Volts,NULL));
    DAQmxErrChk (DAQmxBaseCfgSampClkTiming(taskHandle,clockSource,sampleRate,DAQmx_Val_Rising,DAQmx_Val_ContSamps,0));
    DAQmxErrChk (DAQmxBaseCfgInputBuffer(taskHandle,0)); //use a 100,000 sample DMA buffer
    DAQmxErrChk (DAQmxBaseStartTask(taskHandle));
    
    //calculate date & time for filename designation
    
    // This is where we designate the filename
    
    //begin: check the availability of the filename in order to create necessary files/folders
    if(![fileManager fileExistsAtPath:fileName])
    {
        NSError *err;
        BOOL ret;
        if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Desktop/EMGSensingData",NSHomeDirectory()] isDirectory:&ret]) {
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Desktop/EMGSensingData",NSHomeDirectory()] withIntermediateDirectories:YES attributes:nil error:&err];
            if (err) {
                NSLog(@"%@ %@",err, NSHomeDirectory());
            }
        }
        if([fileManager createFileAtPath:fileName contents:nil attributes:nil])
        {
            NSLog(@"new file created");
        }
        else
        {
            NSLog(@"file creation failed");
        }
    }
    if(![fileManager fileExistsAtPath:fileName])
    {
        NSLog(@"file %@ not exist",fileName);
    }
    else
    {
        NSLog(@"file %@ exists", fileName);
    }
    //end: file checking
    
    
    //prepare file write by moving the cursor to the end of file
    self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [self.fileHandle seekToEndOfFile];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //initialize the sensor reading component and assign it to another thread

    // The loop will quit after 10 seconds
    
    //    startTime = time(NULL);

    while(running) {
        DAQmxErrChk (DAQmxBaseReadAnalogF64(taskHandle,pointsToRead,timeout,DAQmx_Val_GroupByChannel,data,pointsToRead * noOfChannels,&pointsRead,NULL));
        totalRead += pointsRead;
//        NSLog(@"%ld",totalRead);
        // Just print out the first 10 points of the last data read
        NSDictionary *incoming;
        NSAutoreleasePool *pool;
        pool = [[NSAutoreleasePool alloc] init];
        
        for (int i = 0; i < pointsToRead; ++i)
        {
            
            NSString *fileWrite = @"";
//            NSDate *now = [NSDate date];
//            NSString *strNow = [formatter stringFromDate:now];
//            fileWrite = [NSString stringWithFormat:@"%@",strNow];
            fileWrite = [NSString stringWithFormat:@"%ld",totalRead-pointsToRead+i];
            
            for (int j = 0; j < noOfChannels; j++) {
                
                //preping string for file write
                fileWrite = [fileWrite stringByAppendingFormat:@",%lf",data[(pointsToRead*j)+i]];
                
                
                double emgData = data[(pointsToRead*j)+i];
                NSLog(@"%lf", emgData);

                
                
                if (zscoreStat == ZSCORE_WORKING) {
                    [[zscoreBuffer objectAtIndex:j] addObject:[[NSNumber alloc] initWithDouble:emgData]];
                    if ([[zscoreBuffer objectAtIndex:j] count] == zscoreBufferSize)
                    {
                        double sum = 0;
                        for (NSNumber *sValue in [zscoreBuffer objectAtIndex:j]) {
                            sum += [sValue doubleValue];
                        }
                        sum /= zscoreBufferSize;
                        [zscoreParameters replaceObjectAtIndex:j withObject:[[NSNumber alloc] initWithDouble:sum]];
                        if (j+1 == noOfChannels) {
                            zscoreStat = ZSCORE_ON;
                        }
                    }
                }
                
                if (zscoreStat == ZSCORE_ON)
                {
                    emgData = (emgData - [[zscoreParameters objectAtIndex:j] doubleValue]);
                }
                
                double finalData = (rectify) ? fabsf(emgData) : emgData;
//                double finalData = emgData;
                
                if (kFilterStat == KFILTER_ON) {
                    finalData = koikeFilters[j].PushInput(finalData);
                }
                
                if (normalizeStat == NORMALIZE_WORKING) {
                    [[normalizeBuffer objectAtIndex:j] addObject:[[NSNumber alloc] initWithDouble:finalData]];
                    if ([[normalizeBuffer objectAtIndex:j] count] == normalizeBufferSize)
                    {
                        NSNumber *max = [[[normalizeBuffer objectAtIndex:j] sortedArrayUsingSelector:@selector(compare:)] lastObject];
                        NSNumber *min = [[[normalizeBuffer objectAtIndex:j] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
                        double sum = 0;
                        for (NSNumber *sValue in [normalizeBuffer objectAtIndex:j]) {
                            sum += [sValue doubleValue];
                        }
                        sum /= normalizeBufferSize;
                        [normalizeParameters replaceObjectAtIndex:j withObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:sum], @"avg",min,@"min",max,@"max", nil]];
                        NSLog(@"%@",normalizeParameters);
                        if (j+1 == noOfChannels) {
                            normalizeStat = NORMALIZE_ON;
                        }
                    }
                }
                
                
                if (normalizeStat == NORMALIZE_ON) {
                    if( j == 0 || j == 1)
                    {
                        double min = [[[normalizeParameters objectAtIndex:j] valueForKey:@"min"] doubleValue];
                        double max = [[[normalizeParameters objectAtIndex:j] valueForKey:@"max"] doubleValue];
                        finalData = ((finalData - min)/(max - min)) * (1-0) + 0;
                    }
                }
                if (i ==  floor(sampleRate/60)) {
                    incoming = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithFloat:finalData],
                                @"y",[NSNumber numberWithFloat:currentIndex],@"x",nil];
                    [[incomingData objectAtIndex:j] insertObject:incoming atIndex:0];                    
                }
            }
            
            [fileHandle writeData:[[fileWrite stringByAppendingFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            if (i ==  floor(sampleRate/60)) {
                [[self delegate] incomingStream:incomingData];
                currentIndex += 0.1f;
            }
            
            for (int j = 0; j < noOfChannels; j++) {
                [[incomingData objectAtIndex:j] removeAllObjects];
            }
        }

//        NSLog(@"%f",currentIndex);
//        NSLog(@"Time");

        
        [pool drain];
    }
    [self.fileHandle closeFile];
    NSLog(@"fileClosed");
    
Error:
    if( DAQmxFailed(error) )
    {
        NSLog(@"error %lu",error);
        DAQmxBaseGetExtendedErrorInfo(errBuff,2048);
        NSLog(@"error %s",errBuff);
    }
    if(taskHandle != 0)
    {
        NSLog(@"error2");
        DAQmxBaseGetExtendedErrorInfo(errBuff,2048);
        long int stop;
        long int clear;
        long int reset;
        stop = DAQmxBaseStopTask (taskHandle);
        clear = DAQmxBaseClearTask (taskHandle);
        reset = DAQmxBaseResetDevice("Dev1");
        NSLog(@"%ld:stop %ld:clear %ld:reset %s:error", stop , clear, reset, errBuff);
    }
}

- (void)activateKoikefilterWithBuffersize:(int)bsize
{
    if (kFilterStat == KFILTER_OFF) {
        //alloc a block of memory of C++ object arrays using ::operator new
        koikeFilters = static_cast<CKoikeFilter *>(::operator new(sizeof(CKoikeFilter) * noOfChannels));
        for (size_t i = 0; i < noOfChannels; i++) {
            ::new (&koikeFilters[i]) CKoikeFilter(bsize);
        }
        kFilterStat = KFILTER_ON;
    }
    else if(kFilterStat == KFILTER_ON)
    {
        kFilterStat = KFILTER_OFF;
        delete koikeFilters;
    }
}

- (BOOL)activateNormalizationWithBufferSize:(int)bsize
{
    if (normalizeStat == NORMALIZE_OFF) {
        normalizeBufferSize = bsize;
//            NSLog(@"in");
            normalizeBuffer = [[NSMutableArray alloc] initWithCapacity:noOfChannels];
            normalizeParameters = [[NSMutableArray alloc] initWithCapacity:noOfChannels];
            for (int k = 0; k < noOfChannels; k++)
            {
                [normalizeBuffer addObject:[[NSMutableArray alloc] initWithCapacity:normalizeBufferSize]];
                [normalizeParameters addObject:[[NSDictionary alloc] init]];
            }
        normalizeStat = NORMALIZE_WORKING;
    }
    if (normalizeStat == NORMALIZE_ON) {
        normalizeStat = NORMALIZE_OFF;
        [normalizeBuffer removeAllObjects];
        [normalizeParameters removeAllObjects];
        [normalizeBuffer release];
        [normalizeParameters release];
    }
    return normalizeStat;
}

- (BOOL)activateZscoreWithBufferSize:(int)bsize
{
    if (zscoreStat == ZSCORE_OFF) {
        zscoreBufferSize = bsize;
            NSLog(@"in");
            zscoreBuffer = [[NSMutableArray alloc] initWithCapacity:0];
            zscoreParameters = [[NSMutableArray alloc] initWithCapacity:0];
        
            for (int k = 0; k < noOfChannels; k++)
            {
                [zscoreParameters addObject:[[NSNumber alloc] initWithDouble:0]];
                [zscoreBuffer addObject:[[NSMutableArray alloc] initWithCapacity:0]];
            }
        zscoreStat = ZSCORE_WORKING;
    }
    if (zscoreStat == ZSCORE_ON)
    {
        zscoreStat = ZSCORE_OFF;
        [zscoreBuffer removeAllObjects];
        [zscoreParameters removeAllObjects];
        [zscoreParameters release];
        [zscoreBuffer release];
    }
    return zscoreStat;
}

- (void)stop
{
    running = NO;
}
@end
