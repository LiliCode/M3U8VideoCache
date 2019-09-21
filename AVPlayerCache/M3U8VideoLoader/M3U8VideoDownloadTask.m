//
//  M3U8VideoDownloadTask.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoDownloadTask.h"
#import "M3U8VideoLoader.h"
#import "M3U8URLParse.h"

@interface M3U8VideoDownloadTask ()<M3U8VideoLoaderDelegate>
@property (strong, nonatomic) NSMutableArray<M3U8VideoLoader *> *loaders;
@property (strong, nonatomic) M3U8URLParse *urlParse;
@property (strong, nonatomic) M3U8VideoDownloadItem *downloadItem;
@property (copy, nonatomic) NSString *idenditifer;
@property (assign, nonatomic) NSInteger tsCount;    // ts 片段个数
@property (assign, nonatomic) NSInteger tsLoadCount;// ts 加载个数

@end

@implementation M3U8VideoDownloadTask

- (instancetype)initWithItem:(M3U8VideoDownloadItem *)downloadItem taskIdentifier:(nonnull NSString *)identifier {
    NSAssert(identifier != nil, @"taskIdentifier 不能为空!!!");
    if (self = [super init]) {
        self.downloadItem = downloadItem;
        self.idenditifer = identifier;
    }
    
    return self;
}

- (NSMutableArray<M3U8VideoLoader *> *)loaders {
    if (!_loaders) {
        _loaders = [NSMutableArray new];
    }
    
    return _loaders;
}

- (M3U8URLParse *)urlParse {
    if (!_urlParse) {
        _urlParse = [M3U8URLParse new];
    }
    
    return _urlParse;
}

- (M3U8VideoDownloadItem *)item {
    return _downloadItem;
}

- (NSString *)taskIdenditifer {
    return _idenditifer;
}

- (void)loadVideoWithURL:(NSURL *)URL {
    __weak typeof (self) weakSelf = self;
    // request header
    self.urlParse.headers = self.headers;
    // parse video URL
    [self.urlParse parseURL:URL resultCallback:^(NSArray<M3U8TSInfo *> * _Nonnull results) {
        if (results.count) {    // 已经解析出索引数据 (m3u8 文件中的数据)
            // 准备下载索引片段数据
            weakSelf.tsCount = results.count;
            for (M3U8TSInfo *info in results) {
                // Loader
                M3U8VideoLoader *loader = [[M3U8VideoLoader alloc] initWithURL:URL];
                loader.tsInfo = info;
                loader.headers = self.headers;
                loader.delegate = weakSelf;
                loader.tsDownloadProgressBlock = ^(double progress, int64_t bytesWritten) {
                    // 计算进度的百分比
                    weakSelf.downloadItem.progress = ((double)weakSelf.tsLoadCount + progress) / (double)weakSelf.tsCount;
                    if (progress >= 1.0f) {
                        weakSelf.tsLoadCount += (NSInteger)progress;
                    }
                    // 计算速度
                    weakSelf.item.intervalFileSize += bytesWritten;
                    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
                    NSTimeInterval interval = currentInterval - weakSelf.item.lastUpdataTime;
                    if (interval >= 1) {
                        weakSelf.item.speed = weakSelf.item.intervalFileSize / interval;
                        weakSelf.item.intervalFileSize = 0;
                        weakSelf.item.lastUpdataTime = currentInterval;
                    }
                };
                
                [weakSelf.loaders addObject:loader];
            }
            
            // 记录时间
            weakSelf.item.lastUpdataTime = [[NSDate date] timeIntervalSince1970];
            // 开始下载
            [weakSelf.loaders.firstObject startRequest];
            // 如果已经下载完成
            if (M3U8VideoDownloadStateFinish != weakSelf.downloadItem.state) {
                // 状态[下载中]
                weakSelf.downloadItem.state = M3U8VideoDownloadStateDownloading;
            }
        } else {
            // 未解析出数据
            weakSelf.downloadItem.state = M3U8VideoDownloadStateError;
        }
    }];
}

- (void)startTask {
    if (M3U8VideoDownloadStateDefault == self.downloadItem.state) {
        // 状态[等待]
        self.downloadItem.state = M3U8VideoDownloadStateWating;
        // 请求索引文件
        [self loadVideoWithURL:[NSURL URLWithString:self.downloadItem.URLString]];
    }
}

- (void)suspendTask {
    if (M3U8VideoDownloadStateDownloading == self.downloadItem.state) {
        [self.loaders.firstObject suspend];
        
        // 状态[暂停]
        self.downloadItem.state = M3U8VideoDownloadStatePaused;
    }
}

- (void)resumeTask {
    if (M3U8VideoDownloadStatePaused == self.downloadItem.state ||
        M3U8VideoDownloadStateError == self.downloadItem.state) {
        [self.loaders.firstObject resume];
        
        // 状态[暂停]
        self.downloadItem.state = M3U8VideoDownloadStateDownloading;
    }
}

- (void)cancelTask {
    [self.loaders.firstObject cancel];
}

#pragma mark - M3U8VideoLoaderDelegate

- (void)resourceLoader:(M3U8VideoLoader *)resourceLoader didFailWithError:(NSError *)error {
    // 遇到错误继续请求
//    [self.loaders.firstObject startRequest];
    // 状态[错误]
    self.downloadItem.state = M3U8VideoDownloadStateError;
    // 回调
    if ([self.delegate respondsToSelector:@selector(downloadTask:didFailWithError:)]) {
        [self.delegate downloadTask:self didFailWithError:error];
    }
}

- (void)didFinishedWithLoader:(M3U8VideoLoader *)resourceLoader {
    // 删除最顶部的 loader
    [self.loaders removeObject:resourceLoader];
    // 加载下一个 loader
    if (self.loaders.count) {
        [self.loaders.firstObject startRequest];
    } else {
        NSLog(@"视频缓存完毕");
        // 状态[完成]
        self.downloadItem.state = M3U8VideoDownloadStateFinish;
        // 回调
        if ([self.delegate respondsToSelector:@selector(didFinishDownloadingWithTask:)]) {
            [self.delegate didFinishDownloadingWithTask:self];
        }
    }
}

@end
