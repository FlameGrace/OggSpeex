//
//  Decapsulator.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SpeexCodec.h"

@class RawAudioDataPlayer;

@protocol DecapsulatingDelegate <NSObject>

- (void)decapsulatingAndPlayingOver;

@end

@interface Decapsulator : NSObject 

@property (atomic, strong) RawAudioDataPlayer *player;
@property (nonatomic, weak) id<DecapsulatingDelegate> delegate;

//生成对象
- (id)initWithFileName:(NSString *)filename;

- (void)play;

- (BOOL)isPlaying;

- (void)stopPlaying;

@end
