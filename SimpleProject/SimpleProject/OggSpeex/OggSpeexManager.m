//
//  LMSpeexManager.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 16/12/21.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//

#import "OggSpeexManager.h"
#import "PlayerManager.h"
#import "RecorderManager.h"
#import "AVAudioSessionPlayCateGoryTool.h"

@interface OggSpeexManager() <RecordingDelegate, PlayingDelegate>

//因为录音时必定设置为听筒模式，因此需要记录在录音前的模式，在录音后将其设置回来
@property (strong, nonatomic) NSString *lastPlayCategory;

@end



@implementation OggSpeexManager

static OggSpeexManager *shareManager = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[OggSpeexManager alloc]init];
    });
    return shareManager;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playCategoryChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
        [PlayerManager sharedManager];
        [RecorderManager sharedManager];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Recording & Playing Delegate

- (void)playCategoryChanged:(NSNotification *)notification
{
    NSNumber *reasonKey = notification.userInfo[AVAudioSessionRouteChangeReasonKey];
    if(reasonKey.longValue == 3)
    {
        if([self.delegate respondsToSelector:@selector(speexManagerPlayCategoryChanged:)])
        {
            [self.delegate speexManagerPlayCategoryChanged:self];
        }
    }
}

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval {
    if([self.delegate respondsToSelector:@selector(speexManager:didRecordSuccessfulWithFileName:time:)])
    {
        [self.delegate speexManager:self didRecordSuccessfulWithFileName:filePath time:interval];
    }
}

- (void)recordingTimeout {
    if([self.delegate respondsToSelector:@selector(speexManagerDidRecordTimeout:)])
    {
        [self.delegate speexManagerDidRecordTimeout:self];
    }
}

- (void)switchToLastCategory
{
    if(self.lastPlayCategory && [self.lastPlayCategory isEqualToString:AVAudioSessionCategoryPlayback])
    {
        [AVAudioSessionPlayCateGoryTool switchToPlayback];
    }
}

- (void)recordingStopped {
    
    [self switchToLastCategory];
    if([self.delegate respondsToSelector:@selector(speexManagerDidStopRecord:)])
    {
        [self.delegate speexManagerDidStopRecord:self];
    }
}

- (void)recordingFailed:(NSString *)failureInfoString {
    [self switchToLastCategory];
    if([self.delegate respondsToSelector:@selector(speexManager:didRecordFailure:)])
    {
        [self.delegate speexManager:self didRecordFailure:failureInfoString];
    }
}

- (void)levelMeterChanged:(float)levelMeter
{
    if([self.delegate respondsToSelector:@selector(speexManager:recordingLeverMeterUpdated:)])
    {
        [self.delegate speexManager:self recordingLeverMeterUpdated:levelMeter];
    }
}

- (void)recorderTimeChanged:(NSTimeInterval)time
{
    if([self.delegate respondsToSelector:@selector(speexManager:recordingTimeUpdated:)])
    {
        [self.delegate speexManager:self recordingTimeUpdated:time];
    }
}

- (void)playingStoped {
    
    if([self.delegate respondsToSelector:@selector(speexManagerDidStopPlay:)])
    {
        [self.delegate speexManagerDidStopPlay:self];
    }
}

- (void)didAwayDevice
{
    if([self.delegate respondsToSelector:@selector(speexManagerDidFarAwayToDevice:)])
    {
        [self.delegate speexManagerDidFarAwayToDevice:self];
    }
}

- (void)didProximityDevice
{
    if([self.delegate respondsToSelector:@selector(speexManagerDidCloseToDevice:)])
    {
        [self.delegate speexManagerDidCloseToDevice:self];
    }
}


#pragma private function

- (void)setMaxRecorderDuration:(NSTimeInterval)maxRecorderDuration
{
    [RecorderManager sharedManager].maxRecorderDuration = maxRecorderDuration;
}

- (void)playAudioWithFilePath:(NSString *)filePath
{
    @synchronized (self) {
        if (self.isRecording) {
            [self stopRecording];
        }
        
        if ( ! self.isPlaying) {
            [PlayerManager sharedManager].delegate = nil;
            [[PlayerManager sharedManager] playAudioWithFileName:filePath delegate:self];
        }
    }
}

- (void)stopPlaying
{
    @synchronized (self) {
        if (!self.isPlaying) {
            return;
        }
        [[PlayerManager sharedManager] stopPlaying];
    }
}

- (void)startRecordingInFilePath:(NSString *)filePath
{
    @synchronized (self) {
        
        self.lastPlayCategory = [AVAudioSessionPlayCateGoryTool.category copy];
        if (self.isPlaying)
        {
            [self stopPlaying];
        }
        if (!self.isRecording)
        {
            [RecorderManager sharedManager].delegate = self;
            [[RecorderManager sharedManager] startRecordingInFilePath:filePath];
        }
    }
}

- (void)stopRecording
{
    @synchronized (self) {
        if(!self.isRecording)
        {
            return;
        }
        
        [[RecorderManager sharedManager] stopRecording];
    }
}

- (void)cancelRecording
{
    @synchronized (self) {
        if(!self.isRecording)
        {
            return;
        }
        [[RecorderManager sharedManager] cancelRecording];
    }
}

- (BOOL)isRecording
{
    return [RecorderManager sharedManager].isRecording;
}

- (BOOL)isPlaying
{
    return [PlayerManager sharedManager].isPlaying;
}

- (NSString *)playCategory
{
    return [AVAudioSessionPlayCateGoryTool category];
}

- (void)switchToPlayAndRecord
{
    [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
}

- (void)switchToPlayback
{
    [AVAudioSessionPlayCateGoryTool switchToPlayback];
}

@end
