//
//  M3U8VideoDownloader.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoDownloader.h"
#import "M3U8VideoCacheTool.h"

@interface M3U8VideoDownloader ()<NSURLSessionDelegate>
@property (strong, nonatomic) NSURL *videoURL;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (strong, nonatomic) NSURLSession *session;

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

- (void)startDownload {
    if (![[M3U8VideoCacheTool sharedCache] isExists:self.url.absoluteString]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[M3U8VideoCacheTool sharedCache].downloadQueue];
        self.task = [self.session dataTaskWithRequest:request];
        [self.task resume];
    } else {
        NSLog(@"存在这个视频片段");
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveCacheData:)]) {
            NSData *data = [[M3U8VideoCacheTool sharedCache] dataForURL:self.url.absoluteString];
            if (data) {
                NSLog(@"读取缓存成功");
                [self.delegate mediaDownloader:self didReceiveCacheData:data];
            }
        }
    }
}

- (void)cancel {
    self.delegate = nil;
    // .....
    [self.task cancel];
    self.task = nil;
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark - URLSessionDelegateObjectDelegate

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
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveData:)]) {
            [self.delegate mediaDownloader:self didReceiveResponse:response];
        }
        
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveData:)]) {
        [self.delegate mediaDownloader:self didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishedWithError:)]) {
        [self.delegate mediaDownloader:self didFinishedWithError:error];
    }
}


@end

