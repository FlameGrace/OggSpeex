//
//  PlayerManager.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "PlayerManager.h"
#import <UIKit/UIKit.h>
#import "AVAudioSessionPlayCateGoryTool.h"

@interface PlayerManager ()


@end

@implementation PlayerManager

@synthesize decapsulator;
@synthesize avAudioPlayer;

static PlayerManager *mPlayerManager = nil;

+ (PlayerManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mPlayerManager = [[self alloc]init];
    });
    return mPlayerManager;
}

- (id)init {
    if (self = [super init])
    {
        [AVAudioSessionPlayCateGoryTool switchToPlayback];
        [[NSNotificationCenter defaultCenter] addObserver:mPlayerManager
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)playAudioWithFileName:(NSString *)filename delegate:(id<PlayingDelegate>)newDelegate {
    if ( ! filename) {
        return;
    }
    if ([filename rangeOfString:@".spx"].location != NSNotFound)
    {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [self stopPlaying];
        self.delegate = newDelegate;
        self.isPlaying = YES;
        self.decapsulator = [[Decapsulator alloc] initWithFileName:filename];
        self.decapsulator.delegate = self;
        [self.decapsulator play];
        [self startProximityMonitering];
    }
    else if([filename rangeOfString:@".mp3"].location != NSNotFound)
    {
        if(![[NSFileManager defaultManager] fileExistsAtPath:filename])
        {
            NSLog(@"要播放的文件不存在:%@", filename);
            self.isPlaying = NO;
            [self.delegate playingStoped];
            [newDelegate playingStoped];
            return;
        }
        self.isPlaying = NO;
        [self.delegate playingStoped];
        self.delegate = newDelegate;
        
        NSError *error;
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filename] error:&error];
        if (self.avAudioPlayer) {
            self.isPlaying = YES;
            self.avAudioPlayer.delegate = self;
            [self.avAudioPlayer play];
            [self startProximityMonitering];
        }
        else
        {
            self.isPlaying = NO;
            [self.delegate playingStoped];
        }
    }
    else
    {
        self.isPlaying = NO;
        [self.delegate playingStoped];
    }
}

- (void)stopPlaying {
    
    @synchronized (self) {
        if(!self.isPlaying)
        {
            return;
        }
        
        self.isPlaying = NO;
        
        [self stopProximityMonitering];
        
        if (self.decapsulator)
        {
            [self.decapsulator stopPlaying];
            self.decapsulator = nil;
        }
        if (self.avAudioPlayer)
        {
            [self.avAudioPlayer stop];
            self.avAudioPlayer = nil;
        }
        
        [self.delegate playingStoped];
    }
}

- (void)decapsulatingAndPlayingOver {
    self.isPlaying = NO;
    [self.delegate playingStoped];
    [self stopProximityMonitering];
}

- (void)sensorStateChange:(NSNotification *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [AVAudioSessionPlayCateGoryTool switchToPlayAndRecord];
        if([self.delegate respondsToSelector:@selector(didProximityDevice)])
        {
            [self.delegate didProximityDevice];
        }
    }
    else {
        
        NSLog(@"Device is not close to user");
        [AVAudioSessionPlayCateGoryTool switchToPlayback];
        if([self.delegate respondsToSelector:@selector(didAwayDevice)])
        {
            [self.delegate didAwayDevice];
        }
    }
}


- (void)startProximityMonitering {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    NSLog(@"开启距离监听");
}

- (void)stopProximityMonitering {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    NSLog(@"关闭距离监听");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
