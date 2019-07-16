//
//  M3U8VideoCache.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3U8VideoCache : NSObject


#pragma mark - proxy server

/**
 通过原始链接生成一个代理服务器链接
 返回链接示例: http://localHost:9999/EF7882CD987FCEA9810CBE8D/index.m3u8?_v=20190222
 EF7882CD987FCEA9810CBE8D 是原始链接 MD5 之后的值
 localHost:9999 是本地缓存根目录的域名

 @param URL 视频原始链接
 @return 返回代理服务器链接
 */
+ (NSURL *)proxyURLWithOriginalURL:(NSURL *)URL;

/**
 开启一个代理服务器

 @param port 代理服务器的端口号
 @param bonjourName 代理服务器的bonjourName
 @return YES 开启成功
 */
+ (BOOL)proxyStartWithPort:(NSUInteger)port bonjourName:(NSString *)bonjourName;

/**
 停止代理服务器
 */
+ (void)proxyStop;

/**
 代理服务器是否在运行

 @return YES 运行
 */
+ (BOOL)proxyIsRunning;


#pragma mark - cache

/**
 清除缓存
 */
+ (void)cleanCache;

/**
 清除缓存

 @param callback 清除完成之后的回调
 */
+ (void)cleanCacheWithCallback:(void (^)(void))callback;

@end

NS_ASSUME_NONNULL_END
