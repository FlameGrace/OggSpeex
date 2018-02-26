//
//  RecorderManager.mm
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "OggSpeexRecorder.h"
#import "AQRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Encapsulator.h"
#import "AVAudioSessionPlayCateGoryTool.h"
#import "DispatchTimer.h"
#import "AudioSessionNotificationTool.h"

@interface OggSpeexRecorder()<EncapsulatingDelegate,AudioSessionNotificationToolDelegate>

@property (readwrite, nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) Encapsulator *encapsulator;
@property (strong, nonatomic) NSString *filePath;
@property (nonatomic, strong) NSDate *startRecordTime;
@property (nonatomic, strong) DispatchTimer *levelMeterTimer;
@property (nonatomic, strong) DispatchTimer *recordDurationTimer;
@property (nonatomic, assign) NSTimeInterval recordDuration;
@property (nonatomic, strong) AudioSessionNotificationTool *tool;

@end

@implementation OggSpeexRecorder
AQRecorder *mAQRecorder;
AudioQueueLevelMeterState *levelMeterStates;

- (instancetype)init
{
    if(self = [super init])
    {
        self.tool = [[AudioSessionNotificationTool alloc]init];
        self.tool.delegate = self;
        [self .tool startListen];
        self.maxRecordDuration = 60;
        __weak typeof(self) weakSelf = self;
        self.recordDurationTimer = [[DispatchTimer alloc]initWithDuration:1 handleBlock:^{
            [weakSelf handleRecordDuration];
        }];
        self.levelMeterTimer = [[DispatchTimer alloc]initWithDuration:1 handleBlock:^{
            [weakSelf handleLevelMeter];
        }];
    }
    return self;
}

- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionRouteChange:(NSUInteger)reason
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:audioSessionRouteChange:)])
    {
        [self.delegate oggSpeex:self audioSessionRouteChange:reason];
    }
    if(reason != AVAudioSessionRouteChangeReasonCategoryChange)
    {
        if (mAQRecorder->IsRunning())
        {
            [self stopRecord];
        }
    }
}

- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionInterruption:(NSUInteger)type
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:audioSessionInterruption:)])
    {
        [self.delegate oggSpeex:self audioSessionInterruption:type];
    }
    if(type == AVAudioSessionInterruptionTypeBegan)
    {
        if (mAQRecorder->IsRunning())
        {
            [self stopRecord];
        }
    }
}

- (void)encapsulatingOver
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:recordNewFile:recordDuration:)])
    {
        [self.delegate oggSpeex:self recordNewFile:self.filePath recordDuration:[self recordDuration]];
    }
}

- (void)handleLevelMeter
{
    if ([self.delegate respondsToSelector:@selector(oggSpeex:recordLevelMeterChanged:)])
    {
        UInt32 dataSize = sizeof(AudioQueueLevelMeterState);
        AudioQueueGetProperty(mAQRecorder->Queue(), kAudioQueueProperty_CurrentLevelMeter, levelMeterStates, &dataSize);
        [self.delegate oggSpeex:self recordLevelMeterChanged:levelMeterStates[0].mPeakPower];
    }
}

- (void)handleRecordDuration
{
    NSDate *date = [NSDate date];
    NSTimeInterval duration = date.timeIntervalSince1970 - self.startRecordTime.timeIntervalSince1970;
    self.recordDuration = duration;
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:recordDurationChanged:)])
    {
        [self.delegate oggSpeex:self recordDurationChanged:duration];
    }
    if(self.recordDuration >= self.maxRecordDuration)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexDidReachMaxRecordDuration:)])
        {
            [self.delegate oggSpeexDidReachMaxRecordDuration:self];
        }
    }
}

- (void)startRecordInFilePath:(NSString *)filePath newDelegate:(id<OggSpeexRecorderDelegate>)newDelegate
{
    if(self.isRecording)
    {
        [self cancelRecord];
    }
    self.delegate = newDelegate;
    if (!mAQRecorder)
    {
        mAQRecorder = new AQRecorder();
    }
    NSError *error = [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
    if(error)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexRecordFailed:)])
        {
            [self.delegate oggSpeexRecordFailed:self];
        }
        return;
    }
    self.filePath = filePath;
    if (!self.encapsulator)
    {
        self.encapsulator = [[Encapsulator alloc] initWithFileName:self.filePath];
        self.encapsulator.delegete = self;
    }
    else
    {
        [self.encapsulator resetWithFileName:self.filePath];
    }
    
    if ( ! mAQRecorder->IsRunning())
    {
        Boolean recordingWillBegin = mAQRecorder->StartRecord(self.encapsulator);
        if (!recordingWillBegin)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexRecordFailed:)])
            {
                [self.delegate oggSpeexRecordFailed:self];
            }
            return;
        }
    }
    self.isRecording = YES;
    self.recordDuration = 0;
    self.startRecordTime = [NSDate date];
    if (!levelMeterStates)
    {
        levelMeterStates = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * 1);
    }
    [self.recordDurationTimer startTimer];
    [self.levelMeterTimer startTimer];
}

- (void)stopRecord
{
    [self stopRecording:NO];
}

- (void)cancelRecord
{
    [self stopRecording:YES];
}

- (void)stopRecording:(BOOL)isCanceled
{
    self.isRecording = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexStopedRecord:isCanceled:)])
    {
        [self.delegate oggSpeexStopedRecord:self isCanceled:isCanceled];
    }
    if (isCanceled)
    {
        if (self.encapsulator)
        {
            [self.encapsulator stopEncapsulating:YES];
        }
    }
    [self.recordDurationTimer endTimer];
    [self.levelMeterTimer endTimer];
    if (mAQRecorder)
    {
        mAQRecorder->StopRecord();
    }
    self.recordDuration = [NSDate date].timeIntervalSince1970 - self.startRecordTime.timeIntervalSince1970;
}


- (void)dealloc
{
    if (mAQRecorder)
    {
        delete mAQRecorder;
    }
    if (levelMeterStates)
    {
        delete levelMeterStates;
    }
    self.encapsulator = nil;
    [self.tool stopListen];
}

@end
