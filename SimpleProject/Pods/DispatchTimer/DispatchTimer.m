//
//  DispatchTimer.m
//  flamegrace
//
//  Created by Flame Grace on 2017/7/31.
//  Copyright © 2017年 Flame Grace. All rights reserved.
//

#import "DispatchTimer.h"

@interface DispatchTimer()

@property (strong, nonatomic) dispatch_source_t timer;
@property (copy, nonatomic) DispatchTimerHandle handle;
@property (readwrite,assign, nonatomic) NSTimeInterval duration;
@property (readwrite,assign, nonatomic) BOOL isValid;

@end

@implementation DispatchTimer

- (instancetype)initWithDuration:(NSTimeInterval)duration handleBlock:(DispatchTimerHandle)handleBlock
{
    
    if(self = [super init])
    {
        self.duration = duration;
        self.handle = handleBlock;
    }
    return self;
}


- (NSTimeInterval)duration
{
    NSTimeInterval duration = _duration;
    if(duration<=0)
    {
        duration = 1;
    }
    return duration;
}

- (void)startTimer
{
    if(self.timer && self.isValid)
    {
        return;
    }
    [self endTimer];
    self.isValid = YES;
    if(self.handle)
    {
        self.handle();
    }
    NSTimeInterval period = self.duration; //设置时间间隔
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{ //在这里执行事件
        if(weakSelf.handle)
        {
            weakSelf.handle();
        }
    });
    dispatch_resume(timer);
    self.timer = timer;
}

- (void)endTimer
{
    if(self.timer)
    {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    self.isValid = NO;
}

@end
