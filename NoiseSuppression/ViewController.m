//
//  ViewController.m
//  降噪
//
//  Created by majianghai on 2019/5/9.
//  Copyright © 2019 com.cmcmid. All rights reserved.
//

#import "ViewController.h"
#import "VoiceTool.h"
#import "NoiseSuppression.h"

@interface ViewController ()
@property (nonatomic, strong) VoiceTool *tool;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tool = [[VoiceTool alloc] init];
}


/// 开始说话
- (IBAction)startTalk:(UIButton *)sender {
    
    NSLog(@"开始录音");
    [self.tool startRecorder];
    
}

- (IBAction)cancelTalk:(UIButton *)sender {
    NSLog(@"结束录音");
    [self.tool cancelRecorder];
}

- (IBAction)playVoice:(UIButton *)sender {
    [self.tool playVoice];
}

- (IBAction)denoise {
    NSString *filePath = [VoiceTool filePath];
//    [NoiseSuppression denoise:filePath];
//    [self.tool denoise];
    if (![NoiseSuppression denoise:filePath outPath:filePath]) {
        NSLog(@"denoise error");
    }
}


@end
