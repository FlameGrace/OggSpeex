//
//  PlayCateGoryTool.h
//  SimpleProject
//
//  Created by Flame Grace on 2017/6/23.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVAudioSessionPlayCateGoryTool : NSObject


+ (NSString *)category;

+ (NSError *)switchToPlayAndRecord;

+ (NSError *)switchToPlayback;



@end
