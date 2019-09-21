//
//  M3U8VideoDownloader.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class M3U8VideoDownloader;

@protocol M3U8VideoDownloaderDelegate <NSObject>
@optional
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveResponse:(NSURLResponse *)response;
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveData:(NSData *)data;
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveCacheData:( NSData * _Nullable)data;
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didWriteData:(int64_t)bytesWritten progress:(double)progress;
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didFinishedWithError:(NSError *)error;

@end

@interface M3U8VideoDownloader : NSObject
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign) BOOL isReadCache;     // 是否读取缓存数据，如果在线缓存功能 isReadCache = YES
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* headers;   // 请求头信息{Headers}
@property (strong, nonatomic) NSHTTPURLResponse *response;  // 响应体
@property (nonatomic, weak) id<M3U8VideoDownloaderDelegate> delegate;


/**
 初始化方法

 @param url 下载的链接
 @return instancetype
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 开启下载
 */
- (void)startDownload;

/**
 取消下载
 */
- (void)cancel;

/**
 继续下载
 */
- (void)resume;

/**
 暂停下载
 */
- (void)suspend;

@end

NS_ASSUME_NONNULL_END
