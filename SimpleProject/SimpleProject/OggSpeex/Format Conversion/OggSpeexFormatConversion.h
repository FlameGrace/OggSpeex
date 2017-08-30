//
//  LMSpeexFormatConversion.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 17/1/9.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OggSpeexFormatConversionDomain (@"com.oggspeex.speexformatconversion")

@interface OggSpeexFormatConversion : NSObject

+ (instancetype)conversion;

//将ogg格式数据转换为pcm数据
- (NSData *)convertOggSppexToPCMWithData:(NSData *)oggSpeexData error:(NSError **)error;

+ (BOOL)conversionFileName:(NSString *)intput outPutFileName:(NSString *)output error:(NSError **)error;

@end
