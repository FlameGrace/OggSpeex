//
//  PlayerManager.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "OggSpeexPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "Decapsulator.h"
#import <UIKit/UIKit.h>
#import "AVAudioSessionPlayCateGoryTool.h"
#import "ProximityMoniteringTool.h"

@interface OggSpeexPlayer ()<DecapsulatingDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) ProximityMoniteringTool *tool;
@property (nonatomic, strong) Decapsulator *decapsulator;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
@property (readwrite, nonatomic, assign) BOOL isPlaying;
@property (readwrite, nonatomic, copy) NSString *playingFilePath;

@end

@implementation OggSpeexPlayer

- (instancetype)init
{
    if(self = [super init])
    {
        self.autoSwitchPlayCateGory = YES;
    }
    return self;
}

- (void)proximityMoniteringToolStateChange:(ProximityMoniteringTool *)tool
{
    [self autoSwitchPlayCategoryWhenProximityMoniteringToolStateChange];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(oggSpeex:proximityDeviceStateChanged:)])
    {
        [self.delegate oggSpeex:self proximityDeviceStateChanged:tool.proximityState];
    }
    
}
- (void)autoSwitchPlayCategoryWhenProximityMoniteringToolStateChange
{
    if(self.autoSwitchPlayCateGory &&!self.playAndRecordMode)
    {
        if(self.isPlaying && self.playingFilePath)
        {
            //从扬声器切换到听筒，从头开始播放
            if(self.proximityState)
            {
                [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
                [self playAudioFile:self.playingFilePath newDelegate:self.delegate playAndRecordMode:YES];
            }
            else
            {
                //从扬声器切换到自动
                [AVAudioSessionPlayCateGoryTool switchToPlayback];
            }
        }
        
    }
}

- (void)decapsulatingAndPlayingOver
{
    [self stopPlay];
}


- (void)stopPlay
{
    @synchronized (self) {
        if(!self.isPlaying)
        {
            return;
        }
        self.isPlaying = NO;
        [self oggSpeexDidStopPlay];
        if (self.decapsulator.isPlaying)
        {
            [self.decapsulator stopPlaying];
        }
        self.decapsulator = nil;
        if (self.avAudioPlayer.isPlaying)
        {
            [self.avAudioPlayer stop];
        }
        self.avAudioPlayer = nil;
    }
}


- (void)playAudioFile:(NSString *)filePath newDelegate:(id<OggSpeexPlayerDelegate>)newDelegate playAndRecordMode:(BOOL)playAndRecordMode
{
    if(self.isPlaying)
    {
        [self stopPlay];
    }
    self.isPlaying = YES;
    self.playingFilePath = filePath;
    self.delegate = newDelegate;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self switchPlayCateGoryByPlayAndRecordMode:playAndRecordMode];
    if ([filePath rangeOfString:@".spx"].location != NSNotFound)
    {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        self.decapsulator = [[Decapsulator alloc] initWithFileName:filePath];
        self.decapsulator.delegate = self;
        [self.decapsulator play];
        [self oggSpeexDidStartPlay];
        return;
    }
    if([filePath rangeOfString:@".mp3"].location != NSNotFound)
    {
        NSError *error;
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&error];
        if(!error)
        {
            self.avAudioPlayer.delegate = self;
            [self.avAudioPlayer play];
            [self oggSpeexDidStartPlay];
            return;
        }
    }
    [self stopPlay];
}

- (void)oggSpeexDidStartPlay
{
    if(self.autoSwitchPlayCateGory)
    {
        [self.tool startProximityMonitering];
    }
    if(self.delegate&&[self.delegate respondsToSelector:@selector(oggSpeexStartPlay:)])
    {
        [self.delegate oggSpeexStartPlay:self];
    }
}

- (void)oggSpeexDidStopPlay
{
    if(self.autoSwitchPlayCateGory)
    {
        [self.tool stopProximityMonitering];
    }
    if(self.delegate&&[self.delegate respondsToSelector:@selector(oggSpeexStopedPlay:)])
    {
        [self.delegate oggSpeexStopedPlay:self];
    }
}

- (void)switchPlayCateGoryByPlayAndRecordMode:(BOOL)playAndRecordMode
{
    if(playAndRecordMode)
    {
        //听筒模式
        [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
    }
    else
    {
        //扬声器模式
        [AVAudioSessionPlayCateGoryTool switchToPlayback];
    }
}

- (BOOL)proximityState
{
    return [self.tool proximityState];
}

- (ProximityMoniteringTool *)tool
{
    if(!_tool)
    {
        _tool = [[ProximityMoniteringTool alloc]init];
        _tool.delegate = self;
    }
    return _tool;
}

@end
