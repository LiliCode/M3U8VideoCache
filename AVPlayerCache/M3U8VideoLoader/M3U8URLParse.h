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

/// 解析链接
- (void)parseURL:(NSURL *)url resultCallback:(void (^)(NSArray<M3U8TSInfo *> *results))resultCallback;

@end

NS_ASSUME_NONNULL_END
