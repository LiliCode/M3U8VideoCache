//
//  M3U8IndexFileParse.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/11.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8IndexFileParse.h"
#import "M3U8TSInfo.h"
#import "NSURL+M3U8URLTool.h"

@implementation M3U8IndexFileParse


+ (NSArray<M3U8TSInfo *> *)parseM3u8IndexFile:(NSString *)fileURLString {
    if (!fileURLString.length) {
        return nil;
    }
    
    // 读取索引文件
    NSString *content = [NSString stringWithContentsOfFile:fileURLString encoding:NSUTF8StringEncoding error:nil];
    // 解析
    return [self.class parseM3u8IndexString:content];
}

+ (NSArray<M3U8TSInfo *> *)parseM3u8IndexString:(NSString *)indexString {
    // 按照 \n 换行符号分割
    NSArray *array = [indexString componentsSeparatedByString:@"\n"];
    // 筛选出 .ts 文件
    NSMutableArray *tsList = [NSMutableArray arrayWithCapacity:array.count];
    
    M3U8TSInfo *info = nil;
    for (NSString *tsURLString in array) {
        if (!info) {
            info = [M3U8TSInfo new];
        }
        
        // 加密信息
        if ([tsURLString hasPrefix:@"#EXT-X-KEY:"]) {
            NSString *encInfoString = [tsURLString componentsSeparatedByString:@"#EXT-X-KEY:"].lastObject;
            NSMutableDictionary *encInfoDic = [NSMutableDictionary new];
            NSArray *array = [encInfoString componentsSeparatedByString:@","];
            for (NSString *keyValue in array) {
                NSArray *keyValueList = [keyValue componentsSeparatedByString:@"="];
                if ([keyValueList.firstObject isEqualToString:@"URI"]) {
                    // 删除字符串中的引号
                    NSMutableString *value = [keyValueList.lastObject mutableCopy];
                    [encInfoDic setObject:[value stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:keyValueList.firstObject];
                } else {
                    [encInfoDic setObject:keyValueList.lastObject forKey:keyValueList.firstObject];
                }
            }
            
            info.encInfo = [encInfoDic copy];
            [tsList addObject:info];
            info = nil;
            
            continue;
        }
        
        // ts 片段信息
        if ([tsURLString hasPrefix:@"#EXTINF:"]) {
            NSString *timeString = [tsURLString componentsSeparatedByString:@"#EXTINF:"].lastObject;
            info.timeLength = [[timeString stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
            continue;   // 为了把下一行索引路径读取在同一个 info 中
        }
        
        if ([tsURLString tsURLString]) {
            info.indexURL = tsURLString;
        }
        
        if (info.indexURL.length && info.timeLength) {
            [tsList addObject:info];
            info = nil;
        }
    }
    
    return [tsList copy];
}

@end
