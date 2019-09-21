//
//  NSString+M3U8URLTool.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/15.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (M3U8URLTool)


/**
 字符串拼接，使用链式语法
 例如：NSString *string = @"my name is";
 string = string.append(@" ").append(@"qiyue").append(@"!");
 输出：my name is qiyue!
 @return 返回一个block, block 的返回值为 NSString
 */
- (NSString *(^)(NSString *string))append;

/**
 是否是 m3u8 视频索引文件链接

 @return YES 是
 */
- (BOOL)m3u8URLString;

/**
 是否式 m3u8 片段 ts 文件的链接

 @return YES 是
 */
- (BOOL)tsURLString;

/**
 是否是 m3u8 视频密钥的链接

 @return YES 是
 */
- (BOOL)keyURLString;

/**
 网速装换成可视化的字符串

 @param bytes 网速
 @return 可读取的网速字符串（例如：28KB/s）
 */
+ (NSString *)stringWithbytes:(int)bytes;

@end

NS_ASSUME_NONNULL_END
