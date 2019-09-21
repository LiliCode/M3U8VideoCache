//
//  M3U8URLParse.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8TSInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface M3U8URLParse : NSObject
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* headers;   // 请求头信息{Headers}

/**
 解析 m3u8 链接，获取 m3u8 视频索引文件

 @param url 视频链接
 @param resultCallback 解析完成之后的回调
 */
- (void)parseURL:(NSURL *)url resultCallback:(void (^)(NSArray<M3U8TSInfo *> *results))resultCallback;

@end

NS_ASSUME_NONNULL_END
