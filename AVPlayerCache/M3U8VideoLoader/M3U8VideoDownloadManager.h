//
//  M3U8VideoDownloadManager.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/18.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8VideoDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface M3U8VideoDownloadManager : NSObject<NSCopying, NSMutableCopying>

/**
 获取一个单利对象

 @return M3U8VideoDownloadManager *
 */
+ (instancetype)manager;

/**
 设置最大并发

 @param maxCount 这里上限设置5个，下限1个，不设置默认3个
 */
- (void)setMaxConcurrentOperationCount:(NSInteger)maxCount;

/**
 添加一个下载任务到队列

 @param downloadTask 下载任务
 @return YES: 添加任务成功，NO：添加失败（存在这个任务）
 */
- (BOOL)addDownloadTask:(M3U8VideoDownloadTask *)downloadTask;

/**
 开始任务

 @param identifier 任务标识
 */
- (void)startDownloadTaskWithIdentifier:(NSString *)identifier;

/**
 恢复下载任务

 @param identifier 任务标识
 */
- (void)resumeDownloadTaskWithIdentifier:(NSString *)identifier;

/**
 暂停下载任务

 @param identifier 任务标识
 */
- (void)suspendDownloadTaskWithIdentifier:(NSString *)identifier;

/**
 取消任务

 @param identifier 任务标识
 */
- (void)cancelDownloadTaskWithIdentifier:(NSString *)identifier;

/**
 暂停/挂起全部下载任务
 */
- (void)suspendAllDownloadTask;

/**
 恢复全部下载任务
 */
- (void)resumeAllDownloadTask;

/**
 获取下载任务列表

 @return 返回未下载完成的任务列表 (下载完成的任务会从任务列表中移除)
 */
- (NSArray<M3U8VideoDownloadTask *> *)allDownloadTask;

@end

NS_ASSUME_NONNULL_END
