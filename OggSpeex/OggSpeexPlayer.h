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
@property (nonatomic, weak)  id<OggSpeexPlayerDelegate> delegate;
@property (readonly, nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL autoSwitchPlayCateGory;

- (void)playAudioFile:(NSString *)filePath newDelegate:(id<OggSpeexPlayerDelegate>)newDelegate;
- (void)stopPlay;

@end
