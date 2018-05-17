//
//  AudioSessionNotificationTool.m
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace@hotmail.com. All rights reserved.
//

#import "AudioSessionNotificationTool.h"

@interface AudioSessionNotificationTool()

@property (assign, nonatomic) BOOL isMonitering;

@end


@implementation AudioSessionNotificationTool

- (void)interruptionListener:(NSNotification *)notification
{
    NSNumber *interruptionType = [notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    if(interruptionType)
    {
        NSUInteger type = interruptionType.unsignedIntegerValue;
        if(self.delegate && [self.delegate respondsToSelector:@selector(audioSessionNotificationTool:audioSessionInterruption:)])
        {
            [self.delegate audioSessionNotificationTool:self audioSessionInterruption:type];
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
        if(self.delegate && [self.delegate respondsToSelector:@selector(audioSessionNotificationTool:audioSessionRouteChange:)])
        {
            [self.delegate audioSessionNotificationTool:self audioSessionRouteChange:reason];
        }
    }
}

- (void)startListen
{
    if(!self.isMonitering)
    {
        self.isMonitering = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(interruptionListener:) name:AVAudioSessionInterruptionNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
}

- (void)stopListen
{
    if(self.isMonitering)
    {
        self.isMonitering = NO;
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}

- (void)dealloc
{
    [self stopListen];
}

@end
