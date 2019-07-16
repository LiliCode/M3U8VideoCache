//
//  NSURL+M3U8URLTool.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/15.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+M3U8URLTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (M3U8URLTool)

/**
 是否是 m3u8 视频索引文件链接
 
 @return YES 是
 */
- (BOOL)m3u8URL;

/**
 是否式 m3u8 片段 ts 文件的链接
 
 @return YES 是
 */
- (BOOL)tsURL;

/**
 是否是 m3u8 视频密钥的链接
 
 @return YES 是
 */
- (BOOL)keyURL;

@end

NS_ASSUME_NONNULL_END
