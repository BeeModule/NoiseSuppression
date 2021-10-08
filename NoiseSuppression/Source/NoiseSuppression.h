//
//  NoiseSuppression.h
//  降噪
//  
//  Created  by 张绍平 on 2021/10/8
//  Copyright © 2021 com.cmcmid. All rights reserved.
//  
	

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoiseSuppression : NSObject

+ (BOOL)denoise:(NSString *)inPath outPath:(NSString *)outPath;

@end

NS_ASSUME_NONNULL_END
