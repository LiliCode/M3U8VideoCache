//
//  M3U8VideoDownloadTask.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8VideoDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN

@import AVFoundation;

@class M3U8VideoDownloadTask, M3U8VideoDownloadOperation;
@protocol M3U8VideoDownloadTaskDelegate <NSObject>
@optional
- (void)downloadTask:(M3U8VideoDownloadTask *)task didFailWithError:(NSError *)error;
- (void)didFinishDownloadingWithTask:(M3U8VideoDownloadTask *)task;

@end

@interface M3U8VideoDownloadTask : NSObject
@property (strong, nonatomic, readonly) M3U8VideoDownloadItem *item;
@property (weak, nonatomic) M3U8VideoDownloadOperation *operation;
@property (weak, nonatomic) id<M3U8VideoDownloadTaskDelegate> delegate;
@property (copy, nonatomic, readonly) NSString *taskIdenditifer;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* headers;   // 请求头信息{Headers}


/**
 初始化方法

 @param downloadItem 使用 M3U8VideoDownloadItem 的示例对象初始化一个下载任务
 @param identifier 任务标识，可以是视频链接，id...
 @return 返回下载任务对象
 */
- (instancetype)initWithItem:(M3U8VideoDownloadItem *)downloadItem taskIdentifier:(NSString *)identifier;

/**
 启动任务
 */
- (void)startTask;

/**
 暂停任务
 */
- (void)suspendTask;

/**
 继续任务
 */
- (void)resumeTask;

/**
 取消任务
 */
- (void)cancelTask;

@end

NS_ASSUME_NONNULL_END
