//
//  M3U8VideoDownloadItem.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/17.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, M3U8VideoDownloadState) {
    M3U8VideoDownloadStateDefault = 0,    /*默认*/
    M3U8VideoDownloadStateWating,         /*等待*/
    M3U8VideoDownloadStateDownloading,    /*正在下载*/
    M3U8VideoDownloadStatePaused,         /*暂停*/
    M3U8VideoDownloadStateFinish,         /*完成*/
    M3U8VideoDownloadStateError,          /*错误*/
};

typedef NS_ENUM(NSInteger, M3U8VideoDownloadError) {
    M3U8VideoDownloadErrorDefault = 0,      //默认状态
    M3U8VideoDownloadErrorExists = 1,       //任务已存在
    M3U8VideoDownloadErrorOngoing,          //任务进行中
    M3U8VideoDownloadErrorAccomplished,     //任务已完成
    M3U8VideoDownloadErrorNoNetwork,        //无网络
    M3U8VideoDownloadError4GNetworkDownloadsAreNotAllowed,  //不允许4G网络下载
    M3U8VideoDownloadErrorStorageFailure,   //下载完成，移动文件发生错误
    M3U8VideoDownloadManagerInsufficientStorageSpace,       //手机存储空间不足
};


@interface M3U8VideoDownloadItem : NSObject
@property (copy, nonatomic) NSString *vid;              // vid
@property (copy, nonatomic) NSString *URLString;        // 原始链接
@property (copy, nonatomic) NSString *fileName;         // 文件名
@property (copy, nonatomic) NSString *videoName;        // 视频名称
@property (assign, nonatomic) double progress;          // 下载进度 可以监听
@property (assign, nonatomic) double speed;             // 单位时间内的下载速度 可以监听
@property (assign,nonatomic) NSUInteger intervalFileSize;//单位时间内下载的大小，用于速度计算
@property (assign, nonatomic) NSTimeInterval lastUpdataTime;    // 最后更新时间
@property (assign, nonatomic) M3U8VideoDownloadState state;     // 下载状态 可以监听

/**
 初始化方法

 @param URLString 使用视频链接初始化
 @return M3U8VideoDownloadItem
 */
- (instancetype)initWithURL:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
