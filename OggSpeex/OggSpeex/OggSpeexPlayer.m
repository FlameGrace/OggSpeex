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

@interface OggSpeexPlayer ()<DecapsulatingDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) Decapsulator *decapsulator;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
@property (readwrite, nonatomic, assign) BOOL isPlaying;
@property (readwrite, nonatomic, copy) NSString *playingFilePath;

@end

@implementation OggSpeexPlayer


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
        if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexStartPlay:)])
        {
            [self.delegate oggSpeexStartPlay:self];
        }
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
            if(self.delegate && [self.delegate respondsToSelector:@selector(oggSpeexStartPlay:)])
            {
                [self.delegate oggSpeexStartPlay:self];
            }
            return;
        }
    }
    [self stopPlay];
}

@end
