//
//  RecorderDelegater.m
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace. All rights reserved.
//

#import "RecorderDelegater.h"

@implementation RecorderDelegater

- (void)oggSpeex:(id)oggSpeex recordNewFile:(NSString *)filePath recordDuration:(NSTimeInterval)duration
{
    NSLog(@"已获得录音文件");
    if(self.newBlock)
    {
        self.newBlock(filePath, duration);
    }
}
- (void)oggSpeexDidReachMaxRecordDuration:(id)oggSpeex
{
    NSLog(@"已超出最大录音时间");
}
- (void)oggSpeexStopedRecord:(id)oggSpeex isCanceled:(BOOL)isCanceled
{
    NSLog(@"已停止录音");
}
- (void)oggSpeexRecordFailed:(id)oggSpeex
{
    NSLog(@"录音失败");
}
- (void)oggSpeex:(id)oggSpeex recordLevelMeterChanged:(float)level
{
    NSLog(@"录音音量变化：%f",level);
}
- (void)oggSpeex:(id)oggSpeex recordDurationChanged:(NSTimeInterval)duration
{
    NSLog(@"录音时长变化：%f",duration);
}

- (void)oggSpeex:(id)oggSpeex proximityDeviceStateChanged:(BOOL)near
{
    NSLog(@"哈哈--RecorderDelegater");
}

@end
