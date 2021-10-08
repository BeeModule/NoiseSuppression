//
//  VoiceTool.m
//  ASRDemo
//
//  Created by majianghai on 2019/3/28.
//  Copyright © 2019 cmcm. All rights reserved.
//

#import "VoiceTool.h"
#import <AVFoundation/AVFoundation.h>
#include "noise_suppression.h"

#define VOICE_RATE 16000
#define VOICE_RATE_UNIT 160

//#define VOICE_RATE 8000
//#define VOICE_RATE_UNIT 80


#ifndef nullptr
#define nullptr 0
#endif

@interface VoiceTool ()
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation VoiceTool


+ (NSString *)filePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    
    NSString *filePa = [NSString stringWithFormat:@"%@/voice.wav",docPath];
    
    return  filePa;
}


- (void)startRecorder {
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil) {
    }else{
        [session setActive:YES error:nil];
    }
    
    //录音设置
    NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式
    [recordSetting  setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率（HZ）
    [recordSetting setValue:[NSNumber numberWithFloat:VOICE_RATE] forKey:AVSampleRateKey];
    //录音通道数
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数
    [recordSetting  setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting  setValue:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
//    [recordSetting setObject:@(kAudioFileWAVEType) forKey:AVAudioFileTypeKey];
    
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:docPath]) {
        [fileManager createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSURL * url = [NSURL fileURLWithPath:[VoiceTool filePath]];//voice.aac
    NSError *error;
    //初始化AVAudioRecorder
    if(!self.recorder){
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
        //开启音量监测
        self.recorder.meteringEnabled = YES;
    }
    
    if(error){
        NSLog(@"创建录音对象时发生错误，错误信息：%@",error.localizedDescription);
    }
    
    [self.recorder record];
}

- (void)cancelRecorder {
    [self.recorder stop];
}


- (void)playVoice {
    NSError *error = nil;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
    NSURL * url = [NSURL fileURLWithPath:[VoiceTool filePath]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    [self.player prepareToPlay];
    [self.player play];
    if (error) {
        NSLog(@"%@", error);
    }
}


+ (int)voiceLength {
    
    NSString *filePath = [VoiceTool filePath];

    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    NSData *data = [NSData dataWithContentsOfURL:url];

    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    
    float duration = player.duration;

    float lengMs = duration * 1000;

    int len = lengMs * VOICE_RATE_UNIT / 10;
    
    return len;
}

@end
