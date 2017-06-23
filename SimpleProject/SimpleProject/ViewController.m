//
//  ViewController.m
//  SimpleProject
//
//  Created by Flame Grace on 2017/6/23.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "ViewController.h"
#import "OggSpeexManager.h"

@interface RecordObject : NSObject

@property (strong, nonatomic) NSString *localPath;

@property (assign, nonatomic) NSTimeInterval duration;

@end

@implementation RecordObject

+ (instancetype)object
{
    return [[self alloc]init];
}

@end


@interface ViewController () <UITableViewDelegate,UITableViewDataSource,OggSpeexManagerDelegate>

@property (strong, nonatomic) NSMutableArray <RecordObject *> *records;

@property (weak, nonatomic) OggSpeexManager *speex;

@property (strong, nonatomic) UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
- (IBAction)switchCategory:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.speex = [OggSpeexManager shareInstance];
    self.speex.delegate = self;
    self.records = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (void)speexManager:(OggSpeexManager *)speex didRecordSuccessfulWithFileName:(NSString *)filePath time:(NSTimeInterval)interval
{
    NSLog(@"已获得录音文件");
    RecordObject *object = [RecordObject object];
    object.localPath = filePath;
    object.duration = interval;
    [self.records addObject:object];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)speexManagerDidRecordTimeout:(OggSpeexManager *)speex
{
    NSLog(@"已超出最大录音时间");
}
- (void)speexManagerDidStopRecord:(OggSpeexManager *)speex
{
    NSLog(@"已停止录音");
}
- (void)speexManager:(OggSpeexManager *)speex didRecordFailure:(NSString *)errorDesciption
{
    NSLog(@"录音失败:%@",errorDesciption);
}
- (void)speexManager:(OggSpeexManager *)speex recordingLeverMeterUpdated:(float)levelMeter
{
    NSLog(@"录音音量变化：%f",levelMeter);
}
- (void)speexManager:(OggSpeexManager *)speex recordingTimeUpdated:(NSTimeInterval)interval
{
    NSLog(@"录音时长变化：%f",interval);
}

- (void)speexManagerDidStopPlay:(OggSpeexManager *)speex
{
    NSLog(@"停止播放");
}

- (void)speexManagerPlayCategoryChanged:(OggSpeexManager *)speex
{
    [self switchCategory];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    RecordObject *object = self.records[indexPath.row];
    cell.textLabel.text = [object.localPath lastPathComponent];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",object.duration];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RecordObject *object = self.records[indexPath.row];
    [self.speex playAudioWithFilePath:object.localPath];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.records.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



- (IBAction)record:(id)sender {
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%f.spx",[NSDate date].timeIntervalSince1970]];
    [self.speex startRecordingInFilePath:filePath];
    [self switchCategory];
}

- (IBAction)stop:(id)sender {
    [self.speex stopRecording];
}

- (IBAction)switchCategory:(id)sender {
    
    if([self.speex.playCategory isEqualToString:AVAudioSessionCategoryPlayback])
    {
        [self.speex switchToPlayAndRecord];
    }
    else
    {
        [self.speex switchToPlayback];
    }
}

- (void)switchCategory
{
    
    if([self.speex.playCategory isEqualToString:AVAudioSessionCategoryPlayback])
    {
        //听筒模式
        [self.playbackButton setTitle:@"Receiver" forState:UIControlStateNormal];
        return;
    }
    //扬声器模式
    [self.playbackButton setTitle:@"Speaker" forState:UIControlStateNormal];
}


@end
