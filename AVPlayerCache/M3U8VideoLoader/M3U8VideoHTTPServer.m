//
//  M3U8VideoHTTPServer.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoHTTPServer.h"
#import "URLTool.h"
#import "NSURL+M3U8URLTool.h"
#import "M3U8VideoCacheTool.h"
#import "M3U8VideoHTTPResponse.h"
#import <GCDWebServer/GCDWebDAVServer.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerStreamedResponse.h>

@interface M3U8VideoHTTPServer ()
@property (strong, nonatomic) GCDWebDAVServer *webServer;
@property (strong, nonatomic) M3U8VideoHTTPResponse *httpResponse;

@end

@implementation M3U8VideoHTTPServer

static M3U8VideoHTTPServer *_httpServer = nil;

+ (instancetype)server {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _httpServer = [[[self class] alloc] init];
    });
    
    return _httpServer;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t allocOnceToken;
    dispatch_once(&allocOnceToken, ^{
        _httpServer = [super allocWithZone:zone];
    });
    
    return _httpServer;
}

- (id)copyWithZone:(NSZone *)zone {
    return _httpServer;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _httpServer;
}

- (instancetype)init {
    if (self = [super init]) {
        _httpResponse = [[M3U8VideoHTTPResponse alloc] init];
    }
    
    return self;
}

#pragma mark - APIs

- (BOOL)proxyStartWithPort:(NSUInteger)port bonjourName:(NSString *)bonjourName {
    if (!self.webServer) {
        self.webServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:[[M3U8VideoCacheTool sharedCache] cacheRoot]];
    }
    
    __weak typeof (self) weakSelf = self;
    [self.webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        NSLog(@"本地代理服务器 -> 拦截请求：%@", request.URL.absoluteString);
        // 发出异步请求
        [weakSelf.httpResponse request:request completionBlock:completionBlock];
    }];
    
    return [self.webServer startWithPort:port bonjourName:bonjourName];
}


- (void)stop {
    [self.webServer stop];
}

- (BOOL)isRunning {
    return self.webServer.isRunning;
}

- (NSURL *)URLWithOriginalURL:(NSURL *)URL {
    if (!URL || URL.isFileURL || URL.absoluteString.length == 0) {
        return URL;
    }
    if (!self.webServer.isRunning) {
        return URL;
    }
    
    if (![URL m3u8URL]) {
        return URL; // 如果不是 m3u8 视频，就返回原链接
    }
    
    // 生成一个缓存代理服务器的地址
    NSString *cacheBoxName = [[M3U8VideoCacheTool sharedCache] cacheNameForURL:URL.absoluteString];
    // 使用当前视频本地根目录缓存原地址
    [[M3U8VideoCacheTool sharedCache] setURL:URL forKey:cacheBoxName];
    
    // 生成本地代理地址
    NSString *filePath = [NSString stringWithFormat:@"http://localhost:%lu/%@/%@", self.webServer.port, cacheBoxName, URL.lastPathComponent];
    if (URL.query.length) {
        filePath = filePath.append(@"?").append(URL.query);
    }
    
    return [NSURL URLWithString:filePath];
}

@end
