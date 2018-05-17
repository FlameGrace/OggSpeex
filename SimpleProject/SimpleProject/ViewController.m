//
//  ViewController.m
//  SimpleProject
//
//  Created by Flame Grace on 2017/6/23.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "ViewController.h"
#import "OggSpeexManager.h"
#import "RecorderDelegater.h"
#import "PlayerDelegater.h"
#import "AudioSessionNotificationTool.h"

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


@interface ViewController () <UITableViewDelegate,UITableViewDataSource,AudioSessionNotificationToolDelegate>

@property (strong, nonatomic) NSMutableArray <RecordObject *> *records;

@property (weak, nonatomic) OggSpeexManager *speex;

@property (strong, nonatomic) UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIButton *playbackButton;

@property (strong, nonatomic) RecordObject *playingModel;


/**
 用于检验切换新代理，旧代理是否能收到结束方法回调
 */
@property (strong, nonatomic) RecorderDelegater *recordDelegater;
@property (strong, nonatomic) PlayerDelegater *playDelegater;

@property (strong, nonatomic) AudioSessionNotificationTool *audioTool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioTool = [[AudioSessionNotificationTool alloc]init];
    self.audioTool.delegate = self;
    [self.audioTool startListen];
    
    __weak typeof(self) weakSelf = self;
    self.recordDelegater = [[RecorderDelegater alloc]init];
    self.recordDelegater.newBlock = ^(NSString *filePath, NSTimeInterval duration) {
        [weakSelf recordNewFile:filePath recordDuration:duration];
    };
    
    self.playDelegater = [[PlayerDelegater alloc]init];
    self.playDelegater.stopBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    };
    self.speex = [OggSpeexManager shareInstance];
    self.speex.delegate = self.recordDelegater;
    self.records = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self showCategory];
}

- (void)audioSessionNotificationTool:(AudioSessionNotificationTool *)tool audioSessionRouteChange:(NSUInteger)reason
{
    if(reason == 3)
    {
        [self showCategory];
    }
}

- (void)recordNewFile:(NSString *)filePath recordDuration:(NSTimeInterval)duration
{
    RecordObject *object = [RecordObject object];
    object.localPath = filePath;
    object.duration = duration;
    [self.records addObject:object];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    RecordObject *object = self.records[indexPath.row];
    NSString *title = [object.localPath lastPathComponent];
    if(self.playingModel && [self.playingModel isEqual:object]&&[self.speex isPlaying])
    {
        title = [title stringByAppendingString:@"   正在播放"];
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",object.duration];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.speex.delegate = self.playDelegater;
    RecordObject *object = self.records[indexPath.row];
    if(self.speex.isRecording)
    {
        [self.speex stopRecord];
    }
    if(self.playingModel && [self.playingModel isEqual:object]&&self.speex.isPlaying)
    {
        [self.speex stopPlay];
    }
    else
    {
        self.playingModel = object;
        [self.speex playAudioFile:object.localPath];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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



- (IBAction)record:(id)sender
{
    self.speex.delegate = self.recordDelegater;
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%f.spx",[NSDate date].timeIntervalSince1970]];
    [self.speex startRecordInFilePath:filePath];
    [self showCategory];
}

- (IBAction)stop:(id)sender
{
    [self.speex stopRecord];
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

- (void)showCategory
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.speex.playCategory isEqualToString:AVAudioSessionCategoryPlayback])
        {
            //听筒模式
            [self.playbackButton setTitle:@"Playback" forState:UIControlStateNormal];
            return;
        }
        if([self.speex.playCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord])
        {
            //扬声器模式
            [self.playbackButton setTitle:@"PlayAndRecord" forState:UIControlStateNormal];
            return;
        }
        //未知模式
        [self.playbackButton setTitle:@"Unkown" forState:UIControlStateNormal];
    });
}


@end
