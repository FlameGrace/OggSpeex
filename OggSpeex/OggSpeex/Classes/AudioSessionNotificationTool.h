//
//  AudioSessionNotificationTool.h
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AudioSessionNotificationTool;

@protocol AudioSessionNotificationToolDelegate <NSObject>

@optional
- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionInterruption:(NSUInteger)type;
- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionRouteChange:(NSUInteger)reason;

@end

@interface AudioSessionNotificationTool : NSObject

@property (weak, nonatomic) id <AudioSessionNotificationToolDelegate> delegate;

- (void)startListen;
- (void)stopListen;

@end
