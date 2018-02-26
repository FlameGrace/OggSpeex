//
//  LMSpeexManager.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 16/12/21.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OggSpeexProtocol.h"
#import "AVAudioSessionPlayCateGoryTool.h"

@protocol OggSpeexManagerDelegate <OggSpeexRecorderDelegate, OggSpeexPlayerDelegate>

@end

@interface OggSpeexManager : NSObject

+ (instancetype)shareInstance;

@property (weak, nonatomic) id <OggSpeexManagerDelegate> delegate;

@end


@interface OggSpeexManager (Player)

@property (readonly, assign, nonatomic) BOOL proximityState;
@property (readonly, nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL autoSwitchPlayCateGory;

- (void)playAudioFile:(NSString *)filePath;
- (void)stopPlay;

@end

@interface OggSpeexManager (Recorder)

@property (nonatomic, assign) NSTimeInterval maxRecordDuration;
@property (readonly, nonatomic, assign) BOOL isRecording;
@property (readonly, nonatomic, assign) NSTimeInterval recordDuration;

- (void)startRecordInFilePath:(NSString *)filePath;
- (void)stopRecord;
- (void)cancelRecord;

@end


@interface OggSpeexManager (playCategory)

- (NSString *)playCategory;
- (void)switchToPlayAndRecord;
- (void)switchToPlayback;

@end
