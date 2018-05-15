//
//  LMSpeexManager.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 16/12/21.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//

#import "OggSpeexManager.h"
#import "OggSpeexPlayer.h"
#import "OggSpeexRecorder.h"
#import "AudioSessionNotificationTool.h"
#import "ProximityMoniteringTool.h"

@interface OggSpeexManager() <AudioSessionNotificationToolDelegate,ProximityMoniteringToolDelegate>

@property (strong, nonatomic) OggSpeexPlayer *player;
@property (strong, nonatomic) OggSpeexRecorder *recorder;
@property (nonatomic, strong) AudioSessionNotificationTool *audioTool;
@property (nonatomic, strong) ProximityMoniteringTool *proximityTool;
@property (nonatomic, assign) BOOL playAndRecordMode; //是否是听筒模式，YES：听筒模式，NO：扬声器模式
@property (nonatomic, assign) BOOL autoSwitchPlayCateGory;

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
        self.autoSwitchPlayCateGory = YES;
        self.audioTool = [[AudioSessionNotificationTool alloc]init];
        self.audioTool.delegate = self;
        [self.audioTool startListen];
        self.proximityTool = [[ProximityMoniteringTool alloc]init];
        self.proximityTool.delegate = self;
        [self.proximityTool startProximityMonitering];
        self.player = [[OggSpeexPlayer alloc]init];
        self.recorder = [[OggSpeexRecorder alloc]init];
    }
    return self;
}
- (void)proximityMoniteringToolStateChange:(ProximityMoniteringTool *)tool
{
    [self autoSwitchPlayCategoryWhenProximityMoniteringToolStateChange];
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:proximityDeviceStateChanged:)])
    {
        [self.delegate oggSpeex:self proximityDeviceStateChanged:tool.proximityState];
    }
}

- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionRouteChange:(NSUInteger)reason
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:audioSessionRouteChange:)])
    {
        [self.delegate oggSpeex:self audioSessionRouteChange:reason];
    }
}

- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionInterruption:(NSUInteger)type
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:audioSessionInterruption:)])
    {
        [self.delegate oggSpeex:self audioSessionInterruption:type];
    }
}


- (void)autoSwitchPlayCategoryWhenProximityMoniteringToolStateChange
{
    if(self.autoSwitchPlayCateGory &&!self.playAndRecordMode)
    {
        if(self.isPlaying && self.player.playingFilePath)
        {
            //从扬声器切换到听筒，从头开始播放
            if(self.proximityTool.proximityState)
            {
                [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
                [self playAudioFile:self.player.playingFilePath playAndRecordMode:YES];
            }
            else
            {
                //从扬声器切换到自动
                [AVAudioSessionPlayCateGoryTool switchToPlayback];
            }
        }
        
    }
}

- (BOOL)isPlaying
{
    return self.player.isPlaying;
}
- (BOOL)proximityState
{
    return self.proximityTool.proximityState;
}


- (void)setMaxRecordDuration:(NSTimeInterval)maxRecordDuration
{
    self.recorder.maxRecordDuration = maxRecordDuration;
}

- (NSTimeInterval)maxRecordDuration
{
    return self.recorder.maxRecordDuration;
}

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}

- (NSTimeInterval)recordDuration
{
    return self.recorder.recordDuration;
}

- (void)playAudioFile:(NSString *)filePath playAndRecordMode:(BOOL)playAndRecordMode
{
    @synchronized (self)
    {
        if (self.isRecording)
        {
            [self.recorder stopRecord];
        }
        [self.player playAudioFile:filePath newDelegate:self.delegate playAndRecordMode:playAndRecordMode];
    }
}


- (void)playAudioFile:(NSString *)filePath
{
    [self playAudioFile:filePath playAndRecordMode:self.playAndRecordMode];
}

- (void)stopPlay
{
    @synchronized (self)
    {
        [self.player stopPlay];
    }
}

- (void)startRecordInFilePath:(NSString *)filePath
{
    @synchronized (self)
    {
        if (self.isPlaying)
        {
            [self.player stopPlay];
        }
        [self.recorder startRecordInFilePath:filePath newDelegate:self.delegate];
    }
}

- (void)stopRecord
{
    @synchronized (self)
    {
        [self.recorder stopRecord];
    }
}

- (void)cancelRecord
{
    @synchronized (self)
    {
        [self.recorder cancelRecord];
    }
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
