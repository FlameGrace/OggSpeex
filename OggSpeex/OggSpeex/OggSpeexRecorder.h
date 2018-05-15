//
//  RecorderManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OggSpeexProtocol.h"

@interface OggSpeexRecorder : NSObject

@property (nonatomic, weak)  id<OggSpeexRecorderDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval maxRecordDuration;
@property (readonly, nonatomic, assign) BOOL isRecording;

- (void)startRecordInFilePath:(NSString *)filePath newDelegate:(id<OggSpeexRecorderDelegate>)newDelegate;

- (void)stopRecord;

- (void)cancelRecord;

- (NSTimeInterval)recordDuration;

@end
