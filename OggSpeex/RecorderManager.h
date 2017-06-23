//
//  RecorderManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AQRecorder.h"


@protocol RecordingDelegate <NSObject>

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval;
- (void)recordingTimeout;
- (void)recordingStopped;  //录音机停止采集声音
- (void)recordingFailed:(NSString *)failureInfoString;

@optional
- (void)levelMeterChanged:(float)levelMeter;

- (void)recorderTimeChanged:(NSTimeInterval)time;

@end

@interface RecorderManager : NSObject

@property (nonatomic, weak)  id<RecordingDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval maxRecorderDuration;
@property (nonatomic, assign) BOOL isRecording;

+ (RecorderManager *)sharedManager;

- (void)startRecordingInFilePath:(NSString *)filePath;

- (void)stopRecording;

- (void)cancelRecording;

- (NSTimeInterval)recordedTimeInterval;

@end
