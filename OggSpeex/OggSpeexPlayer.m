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
#import "ProximityMoniteringTool.h"
#import "AVAudioSessionPlayCateGoryTool.h"

@interface OggSpeexPlayer ()<DecapsulatingDelegate, AVAudioPlayerDelegate, ProximityMoniteringToolDelegate>

@property (nonatomic, strong) Decapsulator *decapsulator;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
@property (readwrite, nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) ProximityMoniteringTool *tool;

@end

@implementation OggSpeexPlayer


- (instancetype)init
{
    if (self = [super init])
    {
        self.autoSwitchPlayCateGory = YES;
        self.tool = [[ProximityMoniteringTool alloc]init];
        self.tool.delegate = self;
        [self.tool startProximityMonitering];
    }
    return self;
}

- (void)proximityMoniteringToolStateChange:(ProximityMoniteringTool *)tool
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeex:proximityDeviceStateChanged:)])
    {
        [self.delegate oggSpeex:self proximityDeviceStateChanged:self.proximityState];
    }
    [self switchPlayCateGory];
}

- (void)switchPlayCateGory
{
    if(self.autoSwitchPlayCateGory)
    {
        if(self.tool.proximityState)
        {
            [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
        }
        else
        {
            [AVAudioSessionPlayCateGoryTool switchToPlayback];
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
        if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexStopedPlay:)])
        {
            [self.delegate oggSpeexStopedPlay:self];
        }
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


- (void)playAudioFile:(NSString *)filePath newDelegate:(id<OggSpeexPlayerDelegate>)newDelegate
{
    if(self.isPlaying)
    {
        [self stopPlay];
    }
    self.isPlaying = YES;
    self.delegate = newDelegate;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self switchPlayCateGory];
    if ([filePath rangeOfString:@".spx"].location != NSNotFound)
    {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        self.decapsulator = [[Decapsulator alloc] initWithFileName:filePath];
        self.decapsulator.delegate = self;
        [self.decapsulator play];
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
            return;
        }
    }
    [self stopPlay];
}

@end
