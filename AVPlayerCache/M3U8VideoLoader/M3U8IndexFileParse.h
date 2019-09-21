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

/**
 通过index.m3u8索引文件的路径来解析文件

 @param fileURLString 文件路径
 @return 返回解析之后的片段信息
 */
+ (NSArray<M3U8TSInfo *> *)parseM3u8IndexFile:(NSString *)fileURLString;

/**
 解析 index.m3u8 索引字符串

 @param indexString 索引文件的字符串
 @return 返回解析之后的片段信息
 */
+ (NSArray<M3U8TSInfo *> *)parseM3u8IndexString:(NSString *)indexString;

@end

NS_ASSUME_NONNULL_END
