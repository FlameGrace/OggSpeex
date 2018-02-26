//
//  PlayerDelegater.m
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace. All rights reserved.
//

#import "PlayerDelegater.h"

@implementation PlayerDelegater

- (void)oggSpeexStopedPlay:(id)oggSpeex
{
    NSLog(@"停止播放");
    if(self.stopBlock)
    {
        self.stopBlock();
    }
}

- (void)oggSpeex:(id)oggSpeex proximityDeviceStateChanged:(BOOL)near
{
    NSLog(@"哈哈--PlayerDelegater");
}

- (void)oggSpeex:(id)oggSpeex audioSessionRouteChange:(NSUInteger)reason
{
    if(reason == 3)
    {
        if(self.playCateGoryBlock)
        {
            self.playCateGoryBlock();
        }
    }
}

@end
