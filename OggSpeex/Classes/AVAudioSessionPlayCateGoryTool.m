//
//  PlayCateGoryTool.m
//  SimpleProject
//
//  Created by Flame Grace on 2017/6/23.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "AVAudioSessionPlayCateGoryTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVAudioSessionPlayCateGoryTool

+ (NSString *)category
{
    return [AVAudioSession sharedInstance].category;
}

+ (NSError *)switchToPlayAndRecord
{
    NSError *error = [self switchToCategory:AVAudioSessionCategoryPlayAndRecord];
    return error;
}
+ (NSError *)switchToPlayback
{
    NSError *error = [self switchToCategory:AVAudioSessionCategoryPlayback];
    return error;
}


+ (NSError *)switchToCategory:(NSString *)category
{
    NSError *error = nil;
    if(![self.category isEqualToString:category])
    {
        if(![[AVAudioSession sharedInstance] setCategory:category error:&error])
        {
            NSLog(@"AVAudioSession setCategory:%@失败 %@\n",category, error);
        }
        else
        {
            if(![[AVAudioSession sharedInstance] setActive:YES error:&error])
            {
                NSLog(@"ERROR INITIALIZING AUDIO SESSION! %@\n", error);
            }
        }
    }
    return error;
}

@end
