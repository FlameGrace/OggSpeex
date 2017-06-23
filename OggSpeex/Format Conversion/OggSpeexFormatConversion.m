//
//  LMSpeexFormatConversion.m
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 17/1/9.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "OggSpeexFormatConversion.h"
#import <AVFoundation/AVFoundation.h>
#import "SpeexCodec.h"


#define DESIRED_BUFFER_SIZE 4096

@interface OggSpeexFormatConversion()
{
    ogg_stream_state oggStreamState;
    ogg_sync_state oggSyncState;
    int packetNo;
}
@end

@implementation OggSpeexFormatConversion

+ (instancetype)conversion
{
    return [[[self class] alloc]init];
}

+ (BOOL)conversionFileName:(NSString *)intput outPutFileName:(NSString *)output error:(NSError **)error
{
    return NO;
}

//将ogg格式数据转换为pcm数据
- (NSData *)convertOggSppexToPCMWithData:(NSData *)oggSpeexData error:(NSError *__autoreleasing *)error
{
    NSMutableData *pcmData = [NSMutableData data];
    
    const Byte *oggBytes = [oggSpeexData bytes];
    NSUInteger oggByteSize = [oggSpeexData length];
    int readedBytes = 0;
    NSUInteger decodedByteLength = 0;
    
    NSLog(@"开始解析一个ogg头");
    
    packetNo = 0;
    int pageNo = 0;
    
    ogg_sync_init(&oggSyncState);
    ogg_stream_init(&oggStreamState, 0);
    
    while (YES)
    {
        
        int byteSizeToRead = (int)oggByteSize - readedBytes;
        if (byteSizeToRead > DESIRED_BUFFER_SIZE)
        {
            byteSizeToRead = DESIRED_BUFFER_SIZE;
        }
        char *buffer = ogg_sync_buffer(&oggSyncState, DESIRED_BUFFER_SIZE);
        memcpy(buffer, oggBytes, byteSizeToRead);    //!!!
        oggBytes += byteSizeToRead;
        readedBytes += byteSizeToRead;
        NSLog(@"byteSizeToRead = %d, oggByteSize = %lu, readedBytes = %d", byteSizeToRead, (unsigned long)oggByteSize, readedBytes);
        //        oggSyncState.bodybytes = byteSizeToRead;
        
        int resultSyncWrote = ogg_sync_wrote(&oggSyncState, byteSizeToRead);
        if (resultSyncWrote == -1)
        {
            *error = [NSError errorWithDomain:OggSpeexFormatConversionDomain code:1 userInfo:@{@"description":@"error:the number of bytes written overflows the internal storage of the ogg_sync_state struct or an internal error occurred."}];
            return nil;
        }
        
        while (YES)
        {
            ogg_page oggPage;
            int resultSyncPageout= ogg_sync_pageout(&oggSyncState, &oggPage);
            if (resultSyncPageout == 1)
            {
                NSLog(@"to decode a page which was synced and returned");
                
                //检查header和comment
                if(packetNo == 0)
                {
                    NSLog(@"it's the header page, check the header later");
                    if ([self readOggHeaderToStreamState:&oggStreamState fromOggPage:&oggPage])
                    {
                        oggStreamState.packetno = packetNo ++;
                        pageNo ++;
                    }
                    else
                    {
                        packetNo = 0;
                    }
                    continue;
                }
                else if(packetNo == 1)
                {
                    NSLog(@"it's the comment");
                    oggStreamState.packetno = packetNo ++;
                    pageNo ++;
                    continue;
                }
                else
                {
                    oggStreamState.pageno = pageNo ++;
                }
                
                int resultStreamPagein = ogg_stream_pagein(&oggStreamState, &oggPage);
                if (resultStreamPagein == -1)
                {
                    if(error != NULL)
                    {
                        *error = [NSError errorWithDomain:OggSpeexFormatConversionDomain code:1 userInfo:@{@"description":@"ogg_stream_pagein failure"}];
                    }
                    
                    return nil;
                }
                
                SpeexCodec *codec = [[SpeexCodec alloc] init];
                [codec open:4];
                short decodedBuffer[1024];
                
                while (YES)
                {
                    ogg_packet oggPacket;
                    int packetResult = ogg_stream_packetout(&oggStreamState, &oggPacket);
                    if (packetResult == 1) {
                        //decode speex
                        //                        NSLog(@"to decode a packet");
                        packetNo ++;
                        int nDecodedByte = sizeof(short) * [codec decode:oggPacket.packet length:(int)oggPacket.bytes output:decodedBuffer];
                        decodedByteLength += nDecodedByte;
                        
                        [pcmData appendBytes:(Byte *)decodedBuffer length:nDecodedByte];
                    }
                    else if (packetResult == 0)
                    {
                        //need more
                        break;
                    }
                    else
                    {
                        break;
                    }
                }
                
                [codec close];
                codec = nil;
            }
            else if (resultSyncPageout == 0)
            {
                NSLog(@"not enough to decode a page or error");
                break;
            }
            else
            {
                NSLog(@"stream has not yet captured sync");
            }
        }
        
        if (byteSizeToRead < DESIRED_BUFFER_SIZE)
        {
            break;
        }
    }
    
    NSLog(@"decode ogg to pcm: %lu -> %lu", (unsigned long)[oggSpeexData length], (unsigned long)decodedByteLength);
    
    if(pcmData.length)
    {
        return pcmData;
    }
    else
    {
        if(error != NULL)
        {
             *error = [NSError errorWithDomain:OggSpeexFormatConversionDomain code:1 userInfo:@{@"description":@"ogg文件未解析到pcm数据"}];
        }
        return nil;
    }
}

- (BOOL)readOggHeaderToStreamState:(ogg_stream_state *)os fromOggPage:(ogg_page *)op {
    if (op->body_len != 80) {
        return NO;
    }
    os->serialno = ogg_page_serialno(op);
    return YES;
}


@end
