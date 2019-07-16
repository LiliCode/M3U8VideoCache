//
//  M3U8VideoHTTPServer.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 M3U8 视频缓存代理服务器
 */
@interface M3U8VideoHTTPServer : NSObject<NSCopying, NSMutableCopying>

/**
 静态实例对象，常驻内存的服务

 @return 返回一个 http server 实例
 */
+ (instancetype)server;

/**
 开启本地HTTP代理服务器

 @param port 代理服务器的的端口
 @param bonjourName bonjourName
 
 @return YES 开启成功
 */
- (BOOL)proxyStartWithPort:(NSUInteger)port bonjourName:(NSString *)bonjourName;

/**
 停止本地服务器
 */
- (void)stop;

/**
 是否在运行

 @return YES 正在运行
 */
- (BOOL)isRunning;

/**
 通过传入原始 URL 生成一个代理服务器可识别的URL

 @param URL 原始 URL
 @return 代理URL
 */
- (NSURL *)URLWithOriginalURL:(NSURL *)URL;


@end

NS_ASSUME_NONNULL_END
