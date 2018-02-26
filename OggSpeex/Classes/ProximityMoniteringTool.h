//
//  ProximityMoniteringTool.h
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 com.flamegrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProximityMoniteringTool;

@protocol ProximityMoniteringToolDelegate <NSObject>

- (void)proximityMoniteringToolStateChange:(ProximityMoniteringTool *)tool;

@end

@interface ProximityMoniteringTool : NSObject

@property (weak, nonatomic) id <ProximityMoniteringToolDelegate> delegate;

@property (readonly, assign, nonatomic) BOOL proximityState;

- (void)startProximityMonitering;

- (void)stopProximityMonitering;

@end
