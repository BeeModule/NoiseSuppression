//
//  NoiseSuppression.m
//  降噪
//
//  Created  by 张绍平 on 2021/10/8
//  Copyright © 2021 com.cmcmid. All rights reserved.
//  https://github.com/guoxiucai/AudioAndVideo
    

#import "NoiseSuppression.h"

#define DR_WAV_IMPLEMENTATION

#import "dr_wav.h"
#import "timing.h"
#import "noise_suppression.h"

#ifndef nullptr
#define nullptr 0
#endif

#ifndef MIN
#define MIN(A, B)        ((A) < (B) ? (A) : (B))
#endif

enum nsLevel {
    kLow,
    kModerate,
    kHigh,
    kVeryHigh
};

@implementation NoiseSuppression

+ (BOOL)denoise:(NSString *)inPath outPath:(NSString *)outPath {
    return [self noise_suppression:inPath.UTF8String and:outPath.UTF8String] == 0;
}

+ (int)noise_suppression:(const char *)in_file and:(const char *)out_file {
    //音频采样率
    uint32_t sampleRate = 0;
    //总音频采样数
    uint64_t inSampleCount = 0;
    
    int16_t *inBuffer = [self wavRead_int16:in_file :&sampleRate :&inSampleCount];
    
    //如果加载成功
    if (inBuffer != nullptr) {
        double startTime = now();
        [self nsProcess:inBuffer :sampleRate :(int)inSampleCount :kHigh];
        double time_interval = calcElapsed(startTime, now());
        printf("time interval: %d ms\n ", (int) (time_interval * 1000));
        int ret = [self wavWrite_int16:out_file :inBuffer :sampleRate :inSampleCount];
        free(inBuffer);
        return ret;
    }
    return 1;
}

//写wav文件
+ (int)wavWrite_int16:(const char *)filename :(int16_t *)buffer :(size_t)sampleRate :(size_t)totalSampleCount {
    drwav_data_format format = {};
    format.container = drwav_container_riff;     // <-- drwav_container_riff = normal WAV files, drwav_container_w64 = Sony Wave64.
    format.format = DR_WAVE_FORMAT_PCM;          // <-- Any of the DR_WAVE_FORMAT_* codes.
    format.channels = 1;
    format.sampleRate = (drwav_uint32)sampleRate;
    format.bitsPerSample = 16;
    drwav *pWav = drwav_open_file_write(filename, &format);
    if (pWav) {
        drwav_uint64 samplesWritten = drwav_write(pWav, totalSampleCount, buffer);
        drwav_uninit(pWav);
        if (samplesWritten != totalSampleCount) {
            return 1;
        }
    }
    return 0;
}

//读取wav文件
+ (int16_t *)wavRead_int16:(const char *)filename :(uint32_t *)sampleRate :(uint64_t *)totalSampleCount{
    unsigned int channels;
    int16_t *buffer = drwav_open_and_read_file_s16(filename, &channels, sampleRate, totalSampleCount);
    if (buffer == nullptr) {
        printf("ERROR.");
    }
    return buffer;
}

+ (int)nsProcess:(int16_t *)buffer :(uint32_t)sampleRate :(int)samplesCount :(enum nsLevel)level {
    if (buffer == nullptr) return -1;
    if (samplesCount == 0) return -1;
    size_t samples = MIN(160, sampleRate / 100);
    if (samples == 0) return -1;
    uint32_t num_bands = 1;
    int16_t *input = buffer;
    size_t nTotal = (samplesCount / samples);
    NsHandle *nsHandle = WebRtcNs_Create();
    int status = WebRtcNs_Init(nsHandle, sampleRate);
    if (status != 0) {
        printf("WebRtcNs_Init fail\n");
        return -1;
    }
    status = WebRtcNs_set_policy(nsHandle, level);
    if (status != 0) {
        printf("WebRtcNs_set_policy fail\n");
        return -1;
    }
    for (int i = 0; i < nTotal; i++) {
        int16_t *nsIn[1] = {input};   //ns input[band][data]
        int16_t *nsOut[1] = {input};  //ns output[band][data]
        WebRtcNs_Analyze(nsHandle, nsIn[0]);
        WebRtcNs_Process(nsHandle, (const int16_t *const *) nsIn, num_bands, nsOut);
        input += samples;
    }
    WebRtcNs_Free(nsHandle);
    
    return 1;
}

@end
