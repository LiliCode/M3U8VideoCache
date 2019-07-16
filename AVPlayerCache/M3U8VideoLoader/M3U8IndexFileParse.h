//
//  M3U8IndexFileParse.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/11.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class M3U8TSInfo;

@interface M3U8IndexFileParse : NSObject

/// 解析 index.m3u8 索引文件
+ (NSArray<M3U8TSInfo *> *)parseM3u8IndexFile:(NSString *)fileURLString;
/// 解析 index.m3u8 索引字符串
+ (NSArray<M3U8TSInfo *> *)parseM3u8IndexString:(NSString *)indexString;

@end

NS_ASSUME_NONNULL_END
