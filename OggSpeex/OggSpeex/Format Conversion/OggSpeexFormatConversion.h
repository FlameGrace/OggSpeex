//
//  LMSpeexFormatConversion.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 17/1/9.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OggSpeexFormatConversionDomain (@"com.oggspeex.speexformatconversion")

typedef NS_ENUM(NSInteger, OggSpeexFormatConversion_ErrorCode)
{
    OggSpeexFormatConversion_StreamPageinError = 201701091, // ogg stream page in failed.;
    OggSpeexFormatConversion_FoundNoPCM , // found no pcm data in ogg file.;
    OggSpeexFormatConversion_InputFileNameError ,
    OggSpeexFormatConversion_OutputFileCreateFailed ,
    OggSpeexFormatConversion_OutputFileWriteFailed ,
};

@interface OggSpeexFormatConversion : NSObject

+ (instancetype)conversion;

//将ogg格式数据转换为pcm数据
- (NSData *)convertOggSppexToPCMWithData:(NSData *)oggSpeexData error:(NSError **)error;

+ (BOOL)conversionInputFile:(NSString *)intput outputFile:(NSString *)output error:(NSError **)error;

@end
