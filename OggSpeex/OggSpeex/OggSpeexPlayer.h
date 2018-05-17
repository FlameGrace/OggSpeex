//
//  PlayerManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OggSpeexProtocol.h"

@interface OggSpeexPlayer : NSObject 

@property (readonly, assign, nonatomic) BOOL proximityState;
@property (nonatomic, assign) BOOL playAndRecordMode; //是否是听筒模式，YES：听筒模式，NO：扬声器模式
@property (nonatomic, assign) BOOL autoSwitchPlayCateGory;//自动根据距离感应器切换听筒模式和扬声器模式
@property (nonatomic, weak)  id<OggSpeexPlayerDelegate> delegate;
@property (readonly, nonatomic, assign) BOOL isPlaying;
@property (readonly, nonatomic, copy) NSString *playingFilePath;

/**
 播放文件

 @param filePath 文件路径
 @param newDelegate 新的代理
 @param playAndRecordMode 是否是听筒模式，YES：听筒模式，NO：扬声器模式
 */
- (void)playAudioFile:(NSString *)filePath newDelegate:(id<OggSpeexPlayerDelegate>)newDelegate playAndRecordMode:(BOOL)playAndRecordMode;

/**
 停止播放
 */
- (void)stopPlay;

@end
