//
//  URLTool.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLTool : NSObject

/**
 对URL进行编码

 @param URLString 需要编码的URL
 @return 返回编码之后的URL
 */
+ (NSString *)URLEncode:(NSString *)URLString;

/**
 对编码过的URL进行解码

 @param URLString 需要解码的URL
 @return 解码过的URL
 */
+ (NSString *)URLDecode:(NSString *)URLString;

/**
 通过URL 获取对应的 content-Type 字符串

 @param URLString 加载之后的URL
 @return 返回 content-Type
 */
+ (NSString *)contentTypeForURL:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
