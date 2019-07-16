//
//  M3U8VideoLoaderManager.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoLoaderManager.h"
#import "M3U8VideoLoader.h"
#import "M3U8URLParse.h"

@interface M3U8VideoLoaderManager ()<M3U8VideoLoaderDelegate>
@property (strong, nonatomic) NSMutableArray<M3U8VideoLoader *> *loaders;
@property (strong, nonatomic) M3U8URLParse *urlParse;

@end

@implementation M3U8VideoLoaderManager

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        [self loadVideoWithURL:URL];
    }
    
    return self;
}

/**
 清除缓存
 */
- (void)cleanCache {
    
}

/**
 取消正在下载的视频
 */
- (void)cancelLoaders {
//    for (M3U8VideoLoader *loader in self.loaders) {
//
//    }
}

- (NSMutableArray<M3U8VideoLoader *> *)loaders {
    if (!_loaders) {
        _loaders = [NSMutableArray new];
    }
    
    return _loaders;
}

- (M3U8URLParse *)urlParse {
    if (!_urlParse) {
        _urlParse = [M3U8URLParse new];
    }
    
    return _urlParse;
}


- (void)loadVideoWithURL:(NSURL *)URL {
    __weak typeof (self) weakSelf = self;
    [self.urlParse parseURL:URL resultCallback:^(NSArray<M3U8TSInfo *> * _Nonnull results) {
        // 准备下载索引片段数据
        for (M3U8TSInfo *info in results) {
            // Loader
            M3U8VideoLoader *loader = [[M3U8VideoLoader alloc] initWithURL:URL];
            loader.tsInfo = info;
            loader.delegate = weakSelf;
            [weakSelf.loaders addObject:loader];
        }
        
        // 开始下载
        [weakSelf.loaders.firstObject startRequest];
    }];
}

#pragma mark - M3U8VideoLoaderDelegate

- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didFailWithError:(NSError *)error {
    // 遇到错误继续请求
    [self.loaders.firstObject startRequest];
}

- (void)didFinishedWithLoader:(M3U8VideoLoader *)resourceLoader {
    // 删除最顶部的 loader
    [self.loaders removeObject:resourceLoader];
    // 加载下一个 loader
    if (self.loaders.count) {
        [self.loaders.firstObject startRequest];
    } else {
        NSLog(@"视频缓存完毕");
    }
}


#pragma mark - Helper

- (M3U8VideoLoader *)loaderForRequest:(AVAssetResourceLoadingRequest *)request {
    M3U8VideoLoader *loader = nil;
    for (M3U8VideoLoader *l in self.loaders) {
        if ([l.URL.absoluteString isEqualToString:request.request.URL.absoluteString]) {
            loader = l;
            break;
        }
    }
    
    return loader;
}

@end
