//
//  M3U8URLParse.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8URLParse.h"
#import "M3U8IndexFileParse.h"
#import "M3U8VideoCacheTool.h"
#import "NSURL+M3U8URLTool.h"

@interface M3U8URLParse ()
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation M3U8URLParse

- (void)parseURL:(NSURL *)url resultCallback:(void (^)(NSArray<M3U8TSInfo *> *results))resultCallback {
    // 下载索引文集
    NSString *URLString = [url.absoluteString copy];
    // 检查缓存，如果缓存没有索引文件就下载
//    YYCache *cache = [YYCache cacheWithName:URLString];
    
    NSData *data = [[M3U8VideoCacheTool sharedCache] dataForURL:URLString];
    if (data && [URLString m3u8URLString]) {
        NSString *indexFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (resultCallback) {
            resultCallback([M3U8IndexFileParse parseM3u8IndexString:indexFile]);
        }
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg];
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                // 读取索引文件
                NSString *indexFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (resultCallback) {
                    resultCallback([M3U8IndexFileParse parseM3u8IndexString:indexFile]);
                }
                // 缓存索引文件
                [[M3U8VideoCacheTool sharedCache] setData:data forURL:URLString];
            }
        }];
        
        [task resume];
    }
}


@end
