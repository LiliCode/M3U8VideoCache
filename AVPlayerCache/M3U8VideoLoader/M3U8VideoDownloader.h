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
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didReceiveCacheData:(NSData *)data;
- (void)mediaDownloader:(M3U8VideoDownloader *)downloader didFinishedWithError:(NSError *)error;

@end

@interface M3U8VideoDownloader : NSObject
@property (nonatomic, strong, readonly) NSURL *url;
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

@end

NS_ASSUME_NONNULL_END
