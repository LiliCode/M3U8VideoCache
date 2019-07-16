//
//  M3U8VideoHTTPResponse.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/15.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GCDWebServer/GCDWebServerRequest.h>
#import <GCDWebServer/GCDWebServerResponse.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3U8VideoHTTPResponse : NSObject

/**
 处理 GCDWebDAVServer 发出的请求，手动重定向，缓存处理

 @param request GCDWebServerRequest 请求对象
 @param completionBlock 请求完成的回调
 */
- (void)request:(GCDWebServerRequest *)request completionBlock:(void (^)(GCDWebServerDataResponse * _Nullable response))completionBlock;

@end

NS_ASSUME_NONNULL_END
