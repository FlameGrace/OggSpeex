//
//  LMSpeexWavConversion.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 17/1/9.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "OggSpeexWavConversion.h"


#include <stdio.h>
#include <string.h>



typedef int       DWORD;
typedef char       BYTE;
typedef short      WORD;

int a_law_pcm_to_wav(const char *pcm_file, const char *wav);

//wav头的结构如下所示：

struct tagHXD_WAVFLIEHEAD
{
    char RIFFNAME[4];
    DWORD nRIFFLength;
    char WAVNAME[4];
    char FMTNAME[4];
    DWORD nFMTLength;
    WORD nAudioFormat;
    
    WORD nChannleNumber;
    DWORD nSampleRate;
    DWORD nBytesPerSecond;
    WORD nBytesPerSample;
    WORD    nBitsPerSample;
    char    DATANAME[4];
    DWORD   nDataLength;
};
typedef struct tagHXD_WAVFLIEHEAD HXD_WAVFLIEHEAD;

@implementation OggSpeexWavConversion

+ (BOOL)conversionFileName:(NSString *)intput outPutFileName:(NSString *)output error:(NSError *__autoreleasing *)error
{
    
    NSData *oggData = [NSData dataWithContentsOfFile:intput];
    if(!oggData.length)
    {
        *error = [NSError errorWithDomain:OggSpeexFormatConversionDomain code:1 userInfo:@{@"description":@"输入文件为空，请检查路径"}];
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager createFileAtPath:output contents:nil attributes:nil])
    {
        *error = [NSError errorWithDomain:OggSpeexFormatConversionDomain code:1 userInfo:@{@"description":@"输出文件创建失败，请检查路径"}];
        return NO;
    }
    
    
    OggSpeexWavConversion *conversion = [OggSpeexWavConversion conversion];
    
    NSData *pcmData = [conversion convertOggSppexToPCMWithData:oggData error:nil];
    if(pcmData == nil)
    {
        return NO;
    }
    int len = (int) pcmData.length;
    
    int totalDataLen = len + 36;
    int longSampleRate = 8000;
    int totalAudioLen = len;
    int byteRate = 16 * longSampleRate * 1 / 8;
    
    Byte header[44];
    header[0] = 'R'; // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f'; // 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16; // 4 bytes: size of 'fmt ' chunk
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1; // format = 1
    header[21] = 0;
    header[22] = 1;
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (2 * 16 / 8); // block align
    header[33] = 0;
    header[34] = 16; // bits per sample
    header[35] = 0;
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (totalAudioLen & 0xff);
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:output];
    if(!handle)
    {
        *error = [NSError errorWithDomain:OggSpeexFormatConversionDomain code:1 userInfo:@{@"description":@"输出文件写入失败，请检查路径"}];
        return NO;
    }
    NSData *headerData = [NSData dataWithBytes:header length:44];
    [handle writeData:headerData];
    [handle writeData:pcmData];
    [handle closeFile];
    
    return YES;
}

@end
