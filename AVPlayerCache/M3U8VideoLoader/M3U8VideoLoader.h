//
//  M3U8VideoLoader.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8TSInfo.h"
#import <GCDWebServer/GCDWebServerDataResponse.h>

NS_ASSUME_NONNULL_BEGIN

@import AVFoundation;

FOUNDATION_EXTERN NSString *const kM3U8CacheScheme;

@class M3U8VideoLoader;
@protocol M3U8VideoLoaderDelegate <NSObject>
@optional
- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didFailWithError:(NSError *)error;
- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didReceiveData:(NSData *)data;
- (void)didFinishedWithLoader:(M3U8VideoLoader *)resourceLoader;
- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didReceiveCacheData:(NSData *)data;
@end

@interface M3U8VideoLoader : NSObject
@property (strong, nonatomic, readonly) NSURL *URL;
@property (strong, nonatomic) M3U8TSInfo *tsInfo;
@property (weak, nonatomic) id<M3U8VideoLoaderDelegate> delegate;
@property (assign, nonatomic) NSUInteger tryAgainCount; // 下载错误重试次数
@property (nonatomic, assign) BOOL isReadCache; // 是否读取缓存数据，如果在线缓存功能 isReadCache = YES
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* headers;   // 请求头信息{Headers}
@property (strong, nonatomic) NSHTTPURLResponse *response;  // 响应体
/// 回传代理服务器的数据回调
@property (strong, nonatomic) void (^gcdWebServerBodyReaderCompletionBlock)(GCDWebServerDataResponse *response);
/// 当前 TS 切片的下载进度
@property (strong, nonatomic) void (^tsDownloadProgressBlock)(double progress, int64_t bytesWritten);


/**
 初始化方法

 @param url 使用视频链接初始化
 @return M3U8VideoLoader
 */
- (instancetype)initWithURL:(NSURL *)url;


/**
 开始请求
 */
- (void)startRequest;

/**
 继续下载
 */
- (void)resume;

/**
 暂停下载
 */
- (void)suspend;

/**
 取消
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
