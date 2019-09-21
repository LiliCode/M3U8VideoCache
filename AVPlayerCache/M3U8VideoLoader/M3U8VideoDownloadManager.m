//
//  M3U8VideoDownloadManager.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/18.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoDownloadManager.h"
#import "M3U8VideoDownloadTask.h"
#import "M3U8VideoDownloadOperation.h"

@interface M3U8VideoDownloadManager ()<M3U8VideoDownloadTaskDelegate>
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (strong, nonatomic) NSMutableDictionary<NSString *, M3U8VideoDownloadOperation *> *downloadTasks;

@end

@implementation M3U8VideoDownloadManager

static M3U8VideoDownloadManager *_manager = nil;

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[M3U8VideoDownloadManager alloc] init];
    });
    
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t allocOnceToken;
    dispatch_once(&allocOnceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    
    return _manager;
}

- (id)copyWithZone:(NSZone *)zone {
    return _manager;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _manager;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 3;     // 默认并发
    }
    
    return _downloadQueue;
}

- (NSMutableDictionary<NSString *,M3U8VideoDownloadOperation *> *)downloadTasks {
    if (!_downloadTasks) {
        _downloadTasks = [NSMutableDictionary new];
    }
    
    return _downloadTasks;
}


#pragma mark - APIs

- (void)setMaxConcurrentOperationCount:(NSInteger)maxCount {
    if (maxCount >= 5) {
        self.downloadQueue.maxConcurrentOperationCount = 5;
    } else if (maxCount <= 0) {
        self.downloadQueue.maxConcurrentOperationCount = 1;
    } else {
        self.downloadQueue.maxConcurrentOperationCount = maxCount;
    }
}

- (BOOL)addDownloadTask:(M3U8VideoDownloadTask *)downloadTask {
    if (!downloadTask) {
        return NO;
    }
    
    // 判断是否存在此任务
    if ([self.downloadTasks objectForKey:downloadTask.taskIdenditifer]) {
        return NO;
    }
    
    downloadTask.delegate = self;   // 设置代理
    M3U8VideoDownloadOperation *operation = [[M3U8VideoDownloadOperation alloc] initWithTask:downloadTask];
    [self.downloadTasks setObject:operation forKey:downloadTask.taskIdenditifer];
    
    return YES;
}

- (void)startDownloadTaskWithIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        NSLog(@"%s identifier 不能为空!!!", __FUNCTION__);
        return;
    }
    
    M3U8VideoDownloadOperation *operation = (M3U8VideoDownloadOperation *)[self.downloadTasks objectForKey:identifier];
    // 加入队列前检测队列中是否存在任务
    BOOL flag = NO;
    for (NSOperation *op in self.downloadQueue.operations) {
        if ([operation isEqual:op]) {
            flag = YES;
            break;
        }
    }
    
    if (!flag) {
        // 加入到队列
        [self.downloadQueue addOperation:operation];
    }
}

- (void)resumeDownloadTaskWithIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        NSLog(@"%s identifier 不能为空!!!", __FUNCTION__);
        return;
    }
    
    M3U8VideoDownloadOperation *operation = (M3U8VideoDownloadOperation *)[self.downloadTasks objectForKey:identifier];
    [operation resumeTask];
}

- (void)suspendDownloadTaskWithIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        NSLog(@"%s identifier 不能为空!!!", __FUNCTION__);
        return;
    }
    
    M3U8VideoDownloadOperation *operation = (M3U8VideoDownloadOperation *)[self.downloadTasks objectForKey:identifier];
    [operation suspendTask];
}

- (void)cancelDownloadTaskWithIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        NSLog(@"%s identifier 不能为空!!!", __FUNCTION__);
        return;
    }
    
    M3U8VideoDownloadOperation *operation = (M3U8VideoDownloadOperation *)[self.downloadTasks objectForKey:identifier];
    [operation cancel];
    // 移除
    [self didFinishDownloadingWithTask:operation.downloadTask];
}

- (void)suspendAllDownloadTask {
    for (M3U8VideoDownloadOperation *operation in self.downloadTasks.allValues) {
        [operation suspendTask];
    }
}

- (void)resumeAllDownloadTask {
    for (M3U8VideoDownloadOperation *operation in self.downloadTasks.allValues) {
        [operation resumeTask];
    }
}

- (NSArray<M3U8VideoDownloadTask *> *)allDownloadTask {
    NSMutableArray *taskList = [NSMutableArray new];
    for (M3U8VideoDownloadOperation *op in self.downloadTasks.allValues) {
        [taskList addObject:op.downloadTask];
    }
    
    return [taskList copy];
}

#pragma mark - M3U8VideoDownloadTaskDelegate

- (void)didFinishDownloadingWithTask:(M3U8VideoDownloadTask *)task {
    // 从任务列表中移除
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.downloadTasks removeObjectForKey:task.taskIdenditifer];
    });
}


@end
