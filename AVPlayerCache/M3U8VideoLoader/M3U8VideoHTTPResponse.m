//
//  M3U8VideoHTTPResponse.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/15.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoHTTPResponse.h"
#import "URLTool.h"
#import "M3U8VideoLoader.h"
#import "M3U8VideoCacheTool.h"
#import "NSURL+M3U8URLTool.h"
#import <pthread.h>

@interface M3U8VideoHTTPResponse ()<M3U8VideoLoaderDelegate> {
    pthread_mutex_t _lock;
}
@property (strong, nonatomic) NSMutableArray<M3U8VideoLoader *> *loaders;

@end

@implementation M3U8VideoHTTPResponse

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
    }
    
    return self;
}

- (NSMutableArray<M3U8VideoLoader *> *)loaders {
    if (!_loaders) {
        _loaders = [NSMutableArray new];
    }
    
    return _loaders;
}

- (void)request:(GCDWebServerRequest *)request completionBlock:(void (^)(GCDWebServerDataResponse * _Nullable))completionBlock {
    
    NSMutableArray *paths = [[request.URL.path componentsSeparatedByString:@"/"] mutableCopy];
    for (NSString *component in paths) {
        if (!component.length) {
            [paths removeObject:component];
            break;
        }
    }
    
    M3U8TSInfo *tsInfo = [[M3U8TSInfo alloc] init];
    
    if ([request.URL m3u8URL]) {
        
    } else if ([request.URL tsURL]) {
        tsInfo.indexURL = [request.URL.lastPathComponent copy];
    } else if ([request.URL keyURL]) {
        tsInfo.encInfo = @{@"URI":request.URL.path};
    }
    
    NSURL *URL = nil;
    if ([request.URL keyURL]) {
        URL = [[M3U8VideoCacheTool sharedCache] URLForKey:request.URL.path];
    } else {
        URL = [[M3U8VideoCacheTool sharedCache] URLForKey:paths.firstObject];
    }
    
    // 添加 loader
    M3U8VideoLoader *loader = [[M3U8VideoLoader alloc] initWithURL:URL];
    loader.delegate = self;
    loader.tsInfo = tsInfo;
    loader.gcdWebServerBodyReaderCompletionBlock = completionBlock;
    pthread_mutex_lock(&_lock);
    [self.loaders addObject:loader];
    pthread_mutex_unlock(&_lock);
    [loader startRequest];
}


#pragma mark - M3U8VideoLoaderDelegate

- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didFailWithError:(NSError *)error {
    [self.loaders removeObject:resourceLoader];
    if (resourceLoader.gcdWebServerBodyReaderCompletionBlock) {
        GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithData:[NSData data] contentType:[URLTool contentTypeForURL:resourceLoader.tsInfo.tsIndexURL]];
        resourceLoader.gcdWebServerBodyReaderCompletionBlock(response);
    }
}

- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didReceiveData:(NSData *)data {
    // 回传数据
    if (resourceLoader.gcdWebServerBodyReaderCompletionBlock) {
        GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithData:data contentType:[URLTool contentTypeForURL:resourceLoader.tsInfo.tsIndexURL]];
        resourceLoader.gcdWebServerBodyReaderCompletionBlock(response);
    }
}

- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didReceiveCacheData:(NSData *)data {
    [self resourceLoader:resourceLoader didReceiveData:data];
}

- (void)didFinishedWithLoader:(M3U8VideoLoader *)resourceLoader {
    // 删除最顶部的 loader
    pthread_mutex_lock(&_lock);
    [self.loaders removeObject:resourceLoader];
    pthread_mutex_unlock(&_lock);
    // 加载下一个 loader
    if (self.loaders.count) {
        
    }
}


@end
