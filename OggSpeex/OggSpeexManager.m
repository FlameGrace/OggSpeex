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

@interface OggSpeexManager()

@property (strong, nonatomic) OggSpeexPlayer *player;
@property (strong, nonatomic) OggSpeexRecorder *recorder;

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
        self.player = [[OggSpeexPlayer alloc]init];
        self.recorder = [[OggSpeexRecorder alloc]init];
    }
    return self;
}

- (void)setDelegate:(id<OggSpeexManagerDelegate>)delegate
{
    if(!_delegate)
    {
        self.player.delegate = delegate;
        self.recorder.delegate = delegate;
    }
    _delegate = delegate;
}


- (void)setAutoSwitchPlayCateGory:(BOOL)autoSwitchPlayCateGory
{
    self.player.autoSwitchPlayCateGory = autoSwitchPlayCateGory;
}

- (BOOL)autoSwitchPlayCateGory
{
    return self.player.autoSwitchPlayCateGory;
}

- (BOOL)isPlaying
{
    return self.player.isPlaying;
}
- (BOOL)proximityState
{
    return self.player.proximityState;
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


- (void)playAudioFile:(NSString *)filePath
{
    @synchronized (self)
    {
        if (self.isRecording)
        {
            [self.recorder stopRecord];
        }
        [self.player playAudioFile:filePath newDelegate:self.delegate];
    }
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
