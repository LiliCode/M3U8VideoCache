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
@property (strong, nonatomic) void (^gcdWebServerBodyReaderCompletionBlock)(GCDWebServerDataResponse *response);

- (instancetype)initWithURL:(NSURL *)url;


/**
 开始请求
 */
- (void)startRequest;


@end

NS_ASSUME_NONNULL_END
