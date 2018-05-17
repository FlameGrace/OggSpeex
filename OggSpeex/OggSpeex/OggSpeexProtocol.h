//
//  OggSpeexProtocol.h
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OggSpeexPlayerDelegate <NSObject>

@optional

- (void)oggSpeexStartPlay:(id)oggSpeex;
- (void)oggSpeexStopedPlay:(id)oggSpeex;

@end

@protocol OggSpeexRecorderDelegate <NSObject>

@optional
- (void)oggSpeex:(id)oggSpeex recordNewFile:(NSString *)filePath recordDuration:(NSTimeInterval)duration;
- (void)oggSpeexDidReachMaxRecordDuration:(id)oggSpeex;
- (void)oggSpeexStopedRecord:(id)oggSpeex isCanceled:(BOOL)isCanceled;
- (void)oggSpeexRecordFailed:(id)oggSpeex;
- (void)oggSpeex:(id)oggSpeex recordLevelMeterChanged:(float)level;
- (void)oggSpeex:(id)oggSpeex recordDurationChanged:(NSTimeInterval)duration;

@end
