//
//  M3U8VideoLoader.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoLoader.h"
#import "URLTool.h"
#import "NSURL+M3U8URLTool.h"
#import "M3U8IndexFileParse.h"
#import "M3U8VideoDownloader.h"
#import "M3U8VideoCacheTool.h"
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>


NSString *const kM3U8CacheScheme = @"__M3U8MediaCache___:";

@interface M3U8VideoLoader ()<M3U8VideoDownloaderDelegate>
@property (strong, nonatomic) NSURL *resourceURL;   // 当前视频地址 m3u8
@property (strong, nonatomic) M3U8VideoDownloader *downloader;
@property (strong, nonatomic) NSMutableData *streamData;

@end

@implementation M3U8VideoLoader

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.resourceURL = url;
    }
    
    return self;
}

- (NSURL *)URL {
    return self.resourceURL;
}

- (void)startRequest {
    if (self.tsInfo.encInfo) {  // 下载加密信息
        NSURLComponents *URLComponents = [NSURLComponents componentsWithString:self.resourceURL.absoluteString];
        self.tsInfo.tsIndexURL = [NSString stringWithFormat:@"%@://%@%@", URLComponents.scheme, URLComponents.host, self.tsInfo.encInfo[@"URI"]];
    } else if ([self.tsInfo.indexURL tsURLString]) {    // ts 片段
        // 构建完整的链接
        if (![self.tsInfo.tsIndexURL hasPrefix:@"http"]) {
            self.tsInfo.tsIndexURL = [self.resourceURL.absoluteString stringByReplacingOccurrencesOfString:self.resourceURL.lastPathComponent withString:self.tsInfo.indexURL];
        }
    } else if ([self.resourceURL m3u8URL]) {
        self.tsInfo.tsIndexURL = self.resourceURL.absoluteString;
    }
    
    self.downloader = [[M3U8VideoDownloader alloc] initWithURL:[NSURL URLWithString:self.tsInfo.tsIndexURL]];
    self.downloader.delegate = self;
    [self.downloader startDownload];
}

- (NSError *)loaderCancelledError {
    NSError *error = [[NSError alloc] initWithDomain:@"com.resourceloader"
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

#pragma mark - M3U8VideoLoaderDelegate

- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveCacheData:(NSData *)data {
    if ([self.tsInfo.tsIndexURL m3u8URLString]) {
        // 读取 key
        NSString *indexString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray<M3U8TSInfo *> *tsList = [M3U8IndexFileParse parseM3u8IndexString:indexString];
        for (M3U8TSInfo *tsInfo in tsList) {
            if (tsInfo.encInfo.count) {
                [[M3U8VideoCacheTool sharedCache] setURL:[NSURL URLWithString:self.tsInfo.tsIndexURL] forKey:tsInfo.encInfo[@"URI"]];
                break;
            }
        }
    }
    
    // 回调，传出响应
    if ([self.delegate respondsToSelector:@selector(resourceLoader:didReceiveCacheData:)]) {
        [self.delegate resourceLoader:self didReceiveCacheData:data];
    }
}

- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveData:(NSData *)data {
    // 数据量太大的时候，此方法会回调多次，所以在这里拼接数据流
    if (!self.streamData) {
        self.streamData = [data mutableCopy];
    } else {
        [self.streamData appendData:[data mutableCopy]];
    }
}

- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didFinishedWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if (!error) {
        // 数据持久
        if (![[M3U8VideoCacheTool sharedCache] isExists:self.tsInfo.tsIndexURL]) {
            [[M3U8VideoCacheTool sharedCache] setData:self.streamData forURL:self.tsInfo.tsIndexURL];
            
            if ([self.tsInfo.tsIndexURL m3u8URLString]) {
                // 读取 key
                NSString *indexString = [[NSString alloc] initWithData:self.streamData encoding:NSUTF8StringEncoding];
                NSArray<M3U8TSInfo *> *tsList = [M3U8IndexFileParse parseM3u8IndexString:indexString];
                for (M3U8TSInfo *tsInfo in tsList) {
                    if (tsInfo.encInfo.count) {
                        [[M3U8VideoCacheTool sharedCache] setURL:[NSURL URLWithString:self.tsInfo.tsIndexURL] forKey:tsInfo.encInfo[@"URI"]];
                        break;
                    }
                }
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(resourceLoader:didReceiveData:)]) {
            [self.delegate resourceLoader:self didReceiveData:self.streamData];
        }
        
        // 清空数据流
        self.streamData = nil;
        
        if ([self.delegate respondsToSelector:@selector(didFinishedWithLoader:)]) {
            [self.delegate didFinishedWithLoader:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(resourceLoader:didFailWithError:)]) {
            [self.delegate resourceLoader:self didFailWithError:error];
        }
    }
}


@end
