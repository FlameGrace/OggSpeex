//
//  RecorderManager.mm
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "RecorderManager.h"
#import "AQRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Encapsulator.h"
#import "AVAudioSessionPlayCateGoryTool.h"

@interface RecorderManager()<EncapsulatingDelegate>

@property (nonatomic, strong) Encapsulator *encapsulator;
@property (strong, nonatomic) NSString *filename;

@property (nonatomic, strong) NSDate *dateStartRecording, *dateStopRecording;
@property (nonatomic, strong) NSTimer *timerLevelMeter;
@property (nonatomic, strong) NSTimer *timerTimeout;
@property (nonatomic, assign) NSTimeInterval recordedDuration;

- (void)updateLevelMeter:(id)sender;
- (void)stopRecording:(BOOL)isCanceled;

@end

@implementation RecorderManager


static RecorderManager *mRecorderManager = nil;
AQRecorder *mAQRecorder;
AudioQueueLevelMeterState *levelMeterStates;

+ (RecorderManager *)sharedManager {
    @synchronized(self) {
        if (mRecorderManager == nil)
        {
            mRecorderManager = [[self alloc] init];
            mRecorderManager.maxRecorderDuration = 60;
        }
    }
    return mRecorderManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(mRecorderManager == nil)
        {
            mRecorderManager = [super allocWithZone:zone];
            mRecorderManager.maxRecorderDuration = 60;
            return mRecorderManager;
        }
    }
    
    return nil;
}

- (void)observrAudioNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(interruptionListener:) name:AVAudioSessionInterruptionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    
    
}

- (void)removeAudioNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)startRecordingInFilePath:(NSString *)filePath
{
    if ( !mAQRecorder) {
        
        mAQRecorder = new AQRecorder();
        [self observrAudioNotifications];
    }
    
    NSError *error = [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
    if(error)
    {
        NSLog(@"ERROR INITIALIZING AUDIO SESSION! %@\n", error);
    }
    
    self.filename = filePath;
    NSLog(@"filename:%@",self.filename);
    
    if ( ! self.encapsulator) {
        self.encapsulator = [[Encapsulator alloc] initWithFileName:self.filename];
        self.encapsulator.delegete = self;
    }
    else {
        [self.encapsulator resetWithFileName:self.filename];
    }
    
    if ( ! mAQRecorder->IsRunning()) {
        NSLog(@"audio session category : %@", [[AVAudioSession sharedInstance] category]);
        Boolean recordingWillBegin = mAQRecorder->StartRecord(self.encapsulator);
        if ( ! recordingWillBegin) {
            if ([self.delegate respondsToSelector:@selector(recordingFailed:)]) {
                [self.delegate recordingFailed:@"程序错误，无法继续录音，请重启程序试试"];
            }
            return;
        }
    }
    self.isRecording = YES;
    self.recordedDuration = 0;
    self.dateStartRecording = [NSDate date];
    
    if (!levelMeterStates)
    {
        levelMeterStates = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * 1);
    }
    [self endRecorderTimer];
    [self endLevelMeterTimer];
    [self timerTimeout];
    [self timerLevelMeter];
}

- (void)stopRecording {
    [self stopRecording:NO];
}

- (void)cancelRecording {
    [self stopRecording:YES];
}

- (void)stopRecording:(BOOL)isCanceled {
    self.isRecording = NO;
    if (self.delegate) {
        [self.delegate recordingStopped];
    }
    if (isCanceled) {
        if (self.encapsulator) {
            [self.encapsulator stopEncapsulating:YES];
        }
    }
    [self endRecorderTimer];
    [self endLevelMeterTimer];
    if (mAQRecorder) {
        mAQRecorder->StopRecord();
    }
    self.dateStopRecording = [NSDate date];
    self.recordedDuration = self.dateStopRecording.timeIntervalSince1970 - self.dateStartRecording.timeIntervalSince1970;
}

- (void)encapsulatingOver {
    if (self.delegate) {
        [self.delegate recordingFinishedWithFileName:self.filename time:[self recordedTimeInterval]];
    }
}

- (NSTimeInterval)recordedTimeInterval {
    return self.recordedDuration;
}

- (void)updateLevelMeter:(id)sender {
    if (self.delegate) {
        UInt32 dataSize = sizeof(AudioQueueLevelMeterState);
        AudioQueueGetProperty(mAQRecorder->Queue(), kAudioQueueProperty_CurrentLevelMeter, levelMeterStates, &dataSize);
        if ([self.delegate respondsToSelector:@selector(levelMeterChanged:)]) {
            [self.delegate levelMeterChanged:levelMeterStates[0].mPeakPower];
        }

    }
}

- (void)handleRecorderTimer{
    
    NSDate *date = [NSDate date];
    NSTimeInterval duration = date.timeIntervalSince1970 - self.dateStartRecording.timeIntervalSince1970;
    self.recordedDuration = duration;
    if([self.delegate respondsToSelector:@selector(recorderTimeChanged:)])
    {
        [self.delegate recorderTimeChanged:self.recordedDuration];
    }
    if(self.recordedDuration >= self.maxRecorderDuration)
    {
        [[self delegate] recordingTimeout];
    }

}

- (void)dealloc {
    if (mAQRecorder) {
        delete mAQRecorder;
    }
    if (levelMeterStates)
    {
        delete levelMeterStates;
    }
    
    [self removeAudioNotifications];
    
    self.encapsulator = nil;
}

#pragma mark AudioSession listeners


- (void)interruptionListener:(NSNotification *)notification
{
    NSNumber *interruptionType = [notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    if(interruptionType)
    {
        NSUInteger type = interruptionType.unsignedIntegerValue;
        if(type == AVAudioSessionInterruptionTypeBegan)
        {
            if (mAQRecorder->IsRunning()) {
                [self stopRecording];
            }
        }
    }
}

- (void)audioRouteChange:(NSNotification *)notification
{
    NSNumber *routeChangeReason = [notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
    AVAudioSessionRouteDescription *description = [notification.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    if(routeChangeReason && description)
    {
        NSUInteger reason = routeChangeReason.unsignedIntegerValue;
        if(reason != AVAudioSessionRouteChangeReasonCategoryChange)
        {
            if (mAQRecorder->IsRunning()) {
                [self stopRecording];
            }
        }
    }
}



- (void)endRecorderTimer
{
    if(self.timerTimeout)
    {
        [self.timerTimeout invalidate];
        self.timerTimeout = nil;
        self.recordedDuration = 0;
    }
    return;
}
-  (NSTimer *)timerTimeout
{
    if(!_timerTimeout)
    {
        _timerTimeout = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleRecorderTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timerTimeout forMode:NSDefaultRunLoopMode];
        [_timerTimeout fire];
    }
    return _timerTimeout;
}

- (void)endLevelMeterTimer
{
    if(self.timerLevelMeter)
    {
        [self.timerLevelMeter invalidate];
        self.timerLevelMeter = nil;
    }
    return;
}
-  (NSTimer *)timerLevelMeter
{
    if(!_timerLevelMeter)
    {
        _timerLevelMeter = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLevelMeter:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timerLevelMeter forMode:NSDefaultRunLoopMode];
        [_timerLevelMeter fire];
    }
    return _timerLevelMeter;
}

@end
