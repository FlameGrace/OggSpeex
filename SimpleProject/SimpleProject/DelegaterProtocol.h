//
//  DelegaterProtocol.h
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^StopPlayedBlock)(void);
typedef void(^RecordNewFileBlock)(NSString *filePath, NSTimeInterval duration);
