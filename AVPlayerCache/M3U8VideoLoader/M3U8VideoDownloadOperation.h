//
//  M3U8VideoDownloadOperation.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/18.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class M3U8VideoDownloadTask;

@interface M3U8VideoDownloadOperation : NSOperation
@property (strong, nonatomic, readonly) M3U8VideoDownloadTask *downloadTask;

/**
 使用 M3U8VideoDownloadTask 下载任务初始化一个 Operation

 @param task M3U8VideoDownloadTask 下载任务
 @return M3U8VideoDownloadOperation 对象
 */
- (instancetype)initWithTask:(M3U8VideoDownloadTask *)task;


/**
 继续任务
 */
- (void)resumeTask;

/**
 暂停任务
 */
- (void)suspendTask;


@end

NS_ASSUME_NONNULL_END
