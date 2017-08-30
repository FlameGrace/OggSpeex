//
//  LMSpeexManager.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 16/12/21.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class OggSpeexManager;

@protocol OggSpeexManagerDelegate <NSObject>

@optional
/**
 录音文件保存完成
 */
- (void)speexManager:(OggSpeexManager *)speex didRecordSuccessfulWithFileName:(NSString *)filePath time:(NSTimeInterval)interval;
/**
 录音超出最大时间
 */
- (void)speexManagerDidRecordTimeout:(OggSpeexManager *)speex;
/**
 录音结束
 */
- (void)speexManagerDidStopRecord:(OggSpeexManager *)speex;
/**
 录音失败
 */
- (void)speexManager:(OggSpeexManager *)speex didRecordFailure:(NSString *)errorDesciption;
/**
 录音时音量变化
 @param levelMeter 音量等级
 */
- (void)speexManager:(OggSpeexManager *)speex recordingLeverMeterUpdated:(float)levelMeter;

/**
 录音时，录音时间更新，1s更新一次
 @param interval 当前已录音时间
 */
- (void)speexManager:(OggSpeexManager *)speex recordingTimeUpdated:(NSTimeInterval)interval;
/**
 播放结束
 */
- (void)speexManagerDidStopPlay:(OggSpeexManager *)speex;
/**
 播放时接近设备，已自动切换听筒模式
 */
- (void)speexManagerDidCloseToDevice:(OggSpeexManager *)speex;
/**
 播放时远离设备，已自动切换扬声器模式
 */
- (void)speexManagerDidFarAwayToDevice:(OggSpeexManager *)speex;
//播放模式切换
- (void)speexManagerPlayCategoryChanged:(OggSpeexManager *)speex;
@end


@interface OggSpeexManager : NSObject

+ (instancetype)shareInstance;

@property (weak, nonatomic) id <OggSpeexManagerDelegate> delegate;

@property (assign, nonatomic) NSTimeInterval maxRecorderDuration;


- (void)playAudioWithFilePath:(NSString *)filePath;

- (void)stopPlaying;

- (void)startRecordingInFilePath:(NSString *)filePath;

- (void)stopRecording;

- (void)cancelRecording;

- (BOOL)isPlaying;

- (BOOL)isRecording;

- (NSString *)playCategory;

- (void)switchToPlayAndRecord;

- (void)switchToPlayback;

@end
