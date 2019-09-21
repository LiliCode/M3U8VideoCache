//
//  M3U8VideoDownloader.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoDownloader.h"
#import "M3U8VideoCacheTool.h"
#import "NSURLSession+ResumeData.h"
#import <UIKit/UIDevice.h>


#define kTimeoutInterval (15)

/// TS 片段下载状态
typedef NS_ENUM(NSInteger, TSDownloadState) {
    TSDownloadStateDefault = 0,    /*默认*/
    TSDownloadStateWating,         /*等待*/
    TSDownloadStateDownloading,    /*正在下载*/
    TSDownloadStatePaused,         /*暂停*/
    TSDownloadStateFinish,         /*完成*/
    TSDownloadStateError,          /*错误*/
};

@interface M3U8VideoDownloader ()<NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURL *videoURL;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSData *resumeData;       // 存储中断数据
@property (assign, nonatomic) TSDownloadState state;    // 下载状态

@end

@implementation M3U8VideoDownloader

- (NSURL *)url {
    return self.videoURL;
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.videoURL = url;
    }
    
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[M3U8VideoCacheTool sharedCache].downloadQueue];
    }
    
    return _session;
}

- (NSData *)resumeData {
    if (!_resumeData) {
        _resumeData = [[M3U8VideoCacheTool sharedCache] resumeDataForURL:self.url.absoluteString];
    } else {
        // 删除临时数据
        [[M3U8VideoCacheTool sharedCache] removeResumeDataForURL:self.url.absoluteString];
    }
    
    return _resumeData;
}

- (NSMutableURLRequest *)downloadRequestWithURL:(NSURL *)URL headers:(NSDictionary<NSString *, NSString *> *)headers {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInterval];
    // 设置请求头 Headers
    for (NSString *key in headers.allKeys) {
        if ([key isEqualToString:@"Host"]) {
            // 将 Host 替换成原始链接的 Host，否则无法请求
            [request setValue:URL.host forHTTPHeaderField:key];
            continue;
        }
        
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    // 检测是否存在 Host 字段
    if (!request.allHTTPHeaderFields[@"Host"]) {
        [request setValue:URL.host forHTTPHeaderField:@"Host"];
    }
    
    return request;
}

- (void)startDownload {
    // 状态改变[等待]
    self.state = TSDownloadStateWating;
    // 检查是否存在缓存
    if (![[M3U8VideoCacheTool sharedCache] isExists:self.url.absoluteString]) {
        if (self.resumeData) {
            self.task = [self.session downloadTaskWithResumeData:self.resumeData];
            [self.task resume];
        } else {
            NSMutableURLRequest *request = [self downloadRequestWithURL:self.url headers:self.headers];
            self.task = [self.session downloadTaskWithRequest:request];
            [self.task resume];
        }
        
        // 状态改变[下载中]
        self.state = TSDownloadStateDownloading;
    } else {
        NSLog(@"存在这个视频片段");
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveCacheData:)]) {
            // 状态改变[下载中]
            self.state = TSDownloadStateDownloading;
            // 构建响应体
            self.response = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:200 HTTPVersion:nil headerFields:self.headers];
            // 判断是否读取缓存
            if (_isReadCache) {
                // 从缓存中获取
                NSData *data = [[M3U8VideoCacheTool sharedCache] dataForURL:self.url.absoluteString];
                if (data) {
                    // 状态改变[完成]
                    self.state = TSDownloadStateFinish;
                    NSLog(@"读取缓存成功");
                    [self.delegate mediaDownloader:self didReceiveCacheData:data];
                }
            } else {
                // 仅仅是下载功能，遇到缓存可以不用读取
                // 模拟进度
                double progress = 1.0f;
                if ([self.delegate respondsToSelector:@selector(mediaDownloader:didWriteData:progress:)]) {
                    [self.delegate mediaDownloader:self didWriteData:1 progress:progress];
                }
                
                // 状态改变[完成]
                self.state = TSDownloadStateFinish;
                NSLog(@"TS片段存在缓存");
                [self.delegate mediaDownloader:self didReceiveCacheData:nil];
            }
        }
    }
}

- (void)cancel {
    [self.task cancel];
    self.task = nil;
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)resume {
    if (TSDownloadStateDefault == self.state || TSDownloadStateDownloading == self.state) {
        return;
    }
    
    if (self.resumeData) {
        double version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 10.0 && version < 10.2) {
            self.task = [self.session downloadTaskWithIOS10ResumeData:self.resumeData];
        }else {
            self.task = [self.session downloadTaskWithResumeData:self.resumeData];
        }
        
        [self.task resume];
    } else {
        // 防止 Error Domain=NSPOSIXErrorDomain Code=14 "Bad address"
        NSMutableURLRequest *request = [self downloadRequestWithURL:self.url headers:self.headers];
        self.task = [self.session downloadTaskWithRequest:request];
        [self.task resume];
    }
    
    // 状态改变[下载中]
    self.state = TSDownloadStateDownloading;
}

- (void)suspend {
    if (TSDownloadStateDefault == self.state || TSDownloadStatePaused == self.state) {
        return;
    }
    
    __weak typeof (self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        [[M3U8VideoCacheTool sharedCache] setResumeData:resumeData forURL:self.url.absoluteString];
        weakSelf.task = nil;
    }];
    
    // 状态改变[暂停]
    self.state = TSDownloadStatePaused;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSString *mimeType = response.MIMEType;
    // Only download video/audio data
    if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
        [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
        [mimeType rangeOfString:@"application"].location == NSNotFound &&
        [mimeType rangeOfString:@"text/plain"].location == NSNotFound) {
        completionHandler(NSURLSessionResponseCancel);
    } else {
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveResponse:)]) {
            [self.delegate mediaDownloader:self didReceiveResponse:response];
        }
        
        completionHandler(NSURLSessionResponseAllow);
    }
}

#if 0

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveData:)]) {
        [self.delegate mediaDownloader:self didReceiveData:data];
    }
}

#else

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // 下载进度
    double progress = (double)(1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didWriteData:progress:)]) {
        [self.delegate mediaDownloader:self didWriteData:bytesWritten progress:progress];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    //下载完成调用
    NSLog(@"TS片段下载完成调用: %@", downloadTask.response.suggestedFilename);
    // 判断是否请求成功，状态码 200
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)downloadTask.response;
    self.response = response;
    if (200 == response.statusCode) {
        // 读取存放在 tmp 文件夹中的下载数据
        NSData *data = [NSData dataWithContentsOfURL:location];
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveData:)]) {
            [self.delegate mediaDownloader:self didReceiveData:data];
        }
        
        if (self.resumeData) {
            self.resumeData = nil;
        }
    } else {
        // 状态改变[错误]
        self.state = TSDownloadStateError;
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishedWithError:)]) {
            NSError *error = [NSError errorWithDomain:response.URL.absoluteString code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"下载出错，code = %ld", response.statusCode]}];
            [self.delegate mediaDownloader:self didFinishedWithError:error];
        }
    }
}

#endif

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    // 错误对象
    NSError *downloadError = error;
    // 判断是否请求成功，状态码 200
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    self.response = response;
    if (200 == response.statusCode && !error) {
        // 状态改变[完成]
        self.state = TSDownloadStateFinish;
    } else {
        // 状态改变[错误]
        self.state = TSDownloadStateError;
        // 保存恢复数据
        if (error) {
            self.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            NSLog(@"下载出错：%@ 状态码：%ld", error, response.statusCode);
        } else {
            downloadError = [NSError errorWithDomain:response.URL.absoluteString code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"下载出错，code = %ld", response.statusCode]}];
            NSLog(@"下载出错：%@ 状态码：%ld", downloadError, response.statusCode);
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishedWithError:)]) {
        [self.delegate mediaDownloader:self didFinishedWithError:downloadError];
    }
}


@end

