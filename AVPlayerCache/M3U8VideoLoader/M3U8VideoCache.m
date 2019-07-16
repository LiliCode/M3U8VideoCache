//
//  M3U8VideoCache.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoCache.h"
#import "M3U8VideoCacheTool.h"
#import "M3U8VideoHTTPServer.h"
#import "M3U8VideoLoaderManager.h"

@implementation M3U8VideoCache

+ (NSURL *)proxyURLWithOriginalURL:(NSURL *)URL {
    return [[M3U8VideoHTTPServer server] URLWithOriginalURL:URL];;
}

+ (BOOL)proxyStartWithPort:(NSUInteger)port bonjourName:(NSString *)bonjourName {
    return [[M3U8VideoHTTPServer server] proxyStartWithPort:port bonjourName:bonjourName];
}

+ (void)proxyStop {
    [[M3U8VideoHTTPServer server] stop];
}

+ (BOOL)proxyIsRunning {
    return [[M3U8VideoHTTPServer server] isRunning];
}

+ (void)cleanCache {
    [self cleanCacheWithCallback:nil];
}

+ (void)cleanCacheWithCallback:(void (^)(void))callback {
    [[M3U8VideoCacheTool sharedCache] cleanCacheWithCallback:callback];
}

@end
