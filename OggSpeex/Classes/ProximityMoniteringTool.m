//
//  ProximityMoniteringTool.m
//  SimpleProject
//
//  Created by MAC on 2018/2/7.
//  Copyright © 2018年 flamegrace@hotmail.com. All rights reserved.
//

#import "ProximityMoniteringTool.h"
#import <UIKit/UIKit.h>

@interface ProximityMoniteringTool()

@property (assign, nonatomic) BOOL isMonitering;

@end

@implementation ProximityMoniteringTool

- (BOOL)proximityState
{
    return [[UIDevice currentDevice] proximityState];
}

- (void)sensorStateChange:(NSNotification *)notification
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(proximityMoniteringToolStateChange:)])
    {
        [self.delegate proximityMoniteringToolStateChange:self];
    }
}

- (void)startProximityMonitering
{
    if(!self.isMonitering)
    {
        self.isMonitering = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        });
    }
}

- (void)stopProximityMonitering
{
    if(self.isMonitering)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        });
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}


- (void)dealloc
{
    [self stopProximityMonitering];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
