//
//  M3U8VideoLoaderManager.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@import AVFoundation;

@protocol M3U8VideoLoaderManager <NSObject>
@optional
- (void)m3u8VideoLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface M3U8VideoLoaderManager : NSObject
@property (weak, nonatomic) id<M3U8VideoLoaderManager> delegate;


- (instancetype)initWithURL:(NSURL *)URL;


/**
 清除缓存
 */
- (void)cleanCache;

/**
 取消正在下载的视频
 */
- (void)cancelLoaders;

@end

NS_ASSUME_NONNULL_END
