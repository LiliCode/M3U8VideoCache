//
//  M3U8VideoDownloadOperation.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/18.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoDownloadOperation.h"
#import "M3U8VideoDownloadTask.h"

@interface M3U8VideoDownloadOperation () {
    BOOL executing;
    BOOL finished;
}
@property (strong, nonatomic) M3U8VideoDownloadTask *task;

@end

@implementation M3U8VideoDownloadOperation

- (instancetype)initWithTask:(M3U8VideoDownloadTask *)task {
    if (self = [super init]) {
        _task = task;
        _task.operation = self;
        executing = NO;
        finished = NO;
        
        // 监听下载状态
        [_task.item addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        M3U8VideoDownloadState state = (M3U8VideoDownloadState)[change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (M3U8VideoDownloadStateFinish == state) {
            [self completion];
        }
    }
}

- (M3U8VideoDownloadTask *)downloadTask {
    return _task;
}

- (void)resumeTask {
    [self willChangeValueForKey:@"isExecuting"];
    [self.task resumeTask];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)suspendTask {
    [self willChangeValueForKey:@"isExecuting"];
    [self.task suspendTask];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)start {
    // 检测是否被取消
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // 如果没被取消，开始执行任务
    [self willChangeValueForKey:@"isExecuting"];
    [self.task startTask];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [super cancel];
    [self.task cancelTask];
//    self.task = nil;
    [self didChangeValueForKey:@"isCancelled"];
    // 完成
    [self completion];
}

- (void)completion {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}



- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}


- (void)dealloc {
    [_task.item removeObserver:self forKeyPath:@"state"];
    NSLog(@"下载操作将要释放...");
}



@end
