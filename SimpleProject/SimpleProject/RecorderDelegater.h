//
//  RecorderDelegater.h
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OggSpeexManager.h"
#import "DelegaterProtocol.h"



@interface RecorderDelegater : NSObject <OggSpeexManagerDelegate>

@property (copy, nonatomic) RecordNewFileBlock newBlock;

@end
