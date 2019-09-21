//
//  M3U8VideoCache.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/11.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoCacheTool.h"
#import "NSURL+M3U8URLTool.h"
#import <pthread.h>
#include <CommonCrypto/CommonDigest.h>

NSString *MD5(NSString *string) {
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return [digest uppercaseString];
}

@interface M3U8VideoCacheTool ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (copy, nonatomic) NSString *cacheRootFolder;
@property (strong, nonatomic) NSMutableDictionary *folderNameCache; // 每一个 m3u8 视频的索引文件夹名称缓存
@property (strong, nonatomic) NSMutableDictionary *URLCache;

@end

@implementation M3U8VideoCacheTool

+ (instancetype)sharedCache {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = @"queue_M3U8TSDownload";
#if TARGET_IPHONE_SIMULATOR
        _cacheRootFolder = @"/Users/mac/Documents/demo/proxy_m3u8VideoCache/";
#elif TARGET_OS_IPHONE
        _cacheRootFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject].append(@"/proxy_m3u8VideoCache/");
#endif
        // 创建文件夹
        [self createFilePath:_cacheRootFolder];
    }
    
    return self;
}

- (NSMutableDictionary *)folderNameCache {
    if (!_folderNameCache) {
        _folderNameCache = [NSMutableDictionary new];
    }
    
    return _folderNameCache;
}

- (NSMutableDictionary *)URLCache {
    if (!_URLCache) {
        _URLCache = [NSMutableDictionary new];
    }
    
    return _URLCache;
}

- (NSOperationQueue *)downloadQueue {
    return self.queue;
}

- (NSString *)cacheRoot {
    return _cacheRootFolder;
}

#pragma mark - 文件操作

- (BOOL)createFilePath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    BOOL isSuccess = YES;
    if (!isExist) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            isSuccess = YES;
        } else {
            NSLog(@"创建文件夹错误：%@", error);
            isSuccess = NO;
        }
    }
    
    return isSuccess;
}

#pragma mark - 缓存操作

- (void)setResumeData:(NSData *)resumeData forURL:(NSString *)URLString {
    if (!resumeData || !URLString.length) {
        NSLog(@"%s 保存 resumeData 参数错误!", __FUNCTION__);
        return;
    }
    
    NSString *resumeDataRoot = _cacheRootFolder.append(@"/").append(@"resumeData/");
    if ([self createFilePath:resumeDataRoot]) {
        [resumeData writeToFile:resumeDataRoot.append(MD5(URLString)) atomically:YES];
    }
}

- (NSData *)resumeDataForURL:(NSString *)URLString {
    if (!URLString.length) {
        NSLog(@"%s 获取 resumeData 参数错误!", __FUNCTION__);
        return nil;
    }
    
    NSString *resumeDataFilePath = _cacheRootFolder.append(@"/").append(@"resumeData/").append(MD5(URLString));
    // 判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:resumeDataFilePath]) {
        return nil;
    }
    
    // 读取文件
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:resumeDataFilePath];
    NSData *data = [handle readDataToEndOfFile];
    [handle closeFile];
    // 删除临时数据
    [self removeResumeDataForURL:URLString];
    
    return data;
}

- (void)removeResumeDataForURL:(NSString *)URLString {
    if (!URLString.length) {
        NSLog(@"%s 删除 resumeData 参数错误!", __FUNCTION__);
        return;
    }
    
    NSString *resumeDataFilePath = _cacheRootFolder.append(@"/").append(@"resumeData/").append(MD5(URLString));
    // 判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:resumeDataFilePath]) {
        return;
    }
    
    // 删除临时数据
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:resumeDataFilePath error:&error];
    if (error) {
        NSLog(@"删除 resumeData 临时数据失败: %@", error);
    } else {
        NSLog(@"删除 resumeData 临时数据成功");
    }
}

- (void)setURL:(NSURL *)URL forKey:(id<NSCopying>)key {
    if (!URL || !key) {
        return;
    }
    
    [self.URLCache setObject:URL forKey:key];
}

- (NSURL *)URLForKey:(id<NSCopying>)key {
    if (!key) {
        return nil;
    }
    
    return [self.URLCache objectForKey:key];
}

- (NSString *)cacheNameForURL:(NSString *)URLString {
    if (!URLString.length) {
        return nil;
    }
    
    NSString *path = [URLString copy];
    if ([path rangeOfString:@"?"].length) {
        // 去掉后面的参数（鉴权的参数）
        path = [path componentsSeparatedByString:@"?"].firstObject;
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    path = [path stringByReplacingOccurrencesOfString:URL.lastPathComponent withString:@""];
    
    NSString *folderName = [self.folderNameCache objectForKey:path];
    if (!folderName.length) {
        folderName = MD5(path);
        [self.folderNameCache setObject:folderName forKey:path];
    }
    
    return folderName;
}

- (void)setData:(NSData *)data forURL:(NSString *)URLString {
    if (!data || !URLString.length) {
        NSLog(@"%s: 参数错误!!!", __FUNCTION__);
        return;
    }
    
    // 链接 md5 成一个没有特殊字符的字符串
    NSString *folderName = [self cacheNameForURL:URLString];
    NSString *path = [_cacheRootFolder stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = nil;
    // 判断文件类型
    if ([URLString m3u8URLString]) {
        NSURL *URL = [NSURL URLWithString:URLString];
        // 创建文件夹
        if (![self createFilePath:path]) {
            return;
        }
        // 写入数据
        filePath = [NSString stringWithFormat:@"%@/%@", path, URL.lastPathComponent];
    } else if ([URLString tsURLString]) {
        // 创建文件夹
        if (![self createFilePath:path]) {
            return;
        }
        // 获取文件名
        NSURL *tsURL = [NSURL URLWithString:URLString];
        // 写入数据
        filePath = [NSString stringWithFormat:@"%@/%@", path, tsURL.lastPathComponent];
    } else if ([URLString keyURLString]) {
        // m3u8 密钥
        NSURLComponents *URLComponents = [NSURLComponents componentsWithString:URLString];
        NSString *host = [NSString stringWithFormat:@"%@://%@/", URLComponents.scheme, URLComponents.host];
        NSString *path = [URLString stringByReplacingOccurrencesOfString:host withString:@""];
        NSMutableArray *pathComponents = [[path componentsSeparatedByString:@"/"] mutableCopy];
        NSString *encName = [pathComponents.lastObject copy];
        if ([encName rangeOfString:@"?"].location != NSNotFound) {
            encName = [encName componentsSeparatedByString:@"?"].firstObject;
        }
        [pathComponents removeLastObject];
        // 建立文件夹
        NSString *encPath = [NSString stringWithFormat:@"%@%@", _cacheRootFolder, [pathComponents componentsJoinedByString:@"/"]];
        if (![self createFilePath:encPath]) {
            return;
        }
        
        filePath = [NSString stringWithFormat:@"%@/%@", encPath, encName];
    } else {
        NSLog(@"%s: 不能识别的文件类型", __FUNCTION__);
        return;
    }
    
    // 按照划分好的路径创建文件并写入数据
    BOOL isSuccess = [fileManager createFileAtPath:filePath contents:data attributes:nil];
    if (isSuccess) {
        NSLog(@"文件创建成功: %@", filePath);
    } else {
        NSLog(@"文件创建失败: %@", filePath);
    }
}

- (NSData *)dataForURL:(NSString *)URLString {
    if (!URLString.length) {
        return nil;
    }
    
    // 拼接路径
    NSString *folderName = [self cacheNameForURL:URLString];
    NSString *path = [_cacheRootFolder stringByAppendingPathComponent:folderName];
    NSString *filePath = nil;
    // 判断是否存在根目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path] && ![URLString keyURLString]) {
        return nil; // 不存在这个视频的根目录，就说明没有缓存
    }
    
    // 判断文件类型
    if ([URLString m3u8URLString]) {
        // 写入数据
        NSURL *URL = [NSURL URLWithString:URLString];
        filePath = [NSString stringWithFormat:@"%@/%@", path, URL.lastPathComponent];
        // 兼容其他数据
        NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString *fileName in array) {
            if ([fileName m3u8URLString]) {
                filePath = [NSString stringWithFormat:@"%@/%@", path, fileName];
                break;
            }
        }
    } else if ([URLString tsURLString]) {
        // 获取文件名
        NSURL *tsURL = [NSURL URLWithString:URLString];
        filePath = [NSString stringWithFormat:@"%@/%@", path, tsURL.lastPathComponent];
    } else if ([URLString keyURLString]) {
        // 读取密钥
        NSURLComponents *URLComponents = [NSURLComponents componentsWithString:URLString];
        NSString *host = [NSString stringWithFormat:@"%@://%@/", URLComponents.scheme, URLComponents.host];
        NSString *path = [URLString stringByReplacingOccurrencesOfString:host withString:@""];
        NSMutableArray *pathComponents = [[path componentsSeparatedByString:@"/"] mutableCopy];
        NSString *encName = [pathComponents.lastObject copy];
        if ([encName rangeOfString:@"?"].location != NSNotFound) {
            encName = [encName componentsSeparatedByString:@"?"].firstObject;
        }
        [pathComponents removeLastObject];
        // 密钥文件夹
        NSString *encPath = [NSString stringWithFormat:@"%@/%@", _cacheRootFolder, [pathComponents componentsJoinedByString:@"/"]];
        if (![fileManager fileExistsAtPath:encPath]) {
            return nil; // 不存在key目录，就说明没有缓存
        }
        
        filePath = [NSString stringWithFormat:@"%@/%@", encPath, encName];
    } else {
        NSLog(@"%s: 不能识别的文件类型", __FUNCTION__);
        return nil;
    }
    
    // 读取文件
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [handle readDataToEndOfFile];
    [handle closeFile];
    
    return data;
}

- (BOOL)isExists:(NSString *)URLString {
    NSString *folderName = [self cacheNameForURL:URLString];
    NSString *path = [_cacheRootFolder stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = nil;
    // 判断文件类型
    if ([URLString m3u8URLString]) {
        // 写入数据
        NSURL *URL = [NSURL URLWithString:URLString];
        filePath = [NSString stringWithFormat:@"%@/%@", path, URL.lastPathComponent];
        if (![fileManager fileExistsAtPath:filePath]) {
            // 如果不存在这个文件，检测是否有 .m3u8 后缀的文件
            // 兼容其他数据
            NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
            for (NSString *fileName in array) {
                if ([fileName m3u8URLString]) {
                    filePath = [NSString stringWithFormat:@"%@/%@", path, fileName];
                    break;
                }
            }
        }
    } else if ([URLString tsURLString]) {
        // 获取文件名
        NSURL *tsURL = [NSURL URLWithString:URLString];
        // 写入数据
        filePath = [NSString stringWithFormat:@"%@/%@", path, tsURL.lastPathComponent];
    } else if ([URLString keyURLString]) {
        // m3u8 密钥
        NSURLComponents *URLComponents = [NSURLComponents componentsWithString:URLString];
        NSString *host = [NSString stringWithFormat:@"%@://%@/", URLComponents.scheme, URLComponents.host];
        NSString *path = [URLString stringByReplacingOccurrencesOfString:host withString:@""];
        NSMutableArray *pathComponents = [[path componentsSeparatedByString:@"/"] mutableCopy];
        NSString *encName = [pathComponents.lastObject copy];
        if ([encName rangeOfString:@"?"].location != NSNotFound) {
            encName = [encName componentsSeparatedByString:@"?"].firstObject;
        }
        [pathComponents removeLastObject];
        // 建立文件夹
        NSString *encPath = [NSString stringWithFormat:@"%@/%@", _cacheRootFolder, [pathComponents componentsJoinedByString:@"/"]];
        
        filePath = [NSString stringWithFormat:@"%@/%@", encPath, encName];
    } else {
        NSLog(@"%s: 不能识别的文件类型", __FUNCTION__);
        return NO;
    }
    
    return [fileManager fileExistsAtPath:filePath];
}

- (void)setVideoInfo:(NSData *)videoInfoData forURL:(NSString *)URLString {
    if (!videoInfoData || !URLString.length) {
        NSLog(@"%s: 保存视频信息失败", __FUNCTION__);
        return;
    }
    
    NSString *folderName = [self cacheNameForURL:URLString];
    NSString *path = [_cacheRootFolder stringByAppendingPathComponent:folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    path = path.append(@"/").append(@"videoInfo.json");
    // 按照划分好的路径创建文件并写入数据
    BOOL isSuccess = [fileManager createFileAtPath:path contents:videoInfoData attributes:nil];
    if (isSuccess) {
        NSLog(@"写入视频信息 videoInfo.json 成功: %@", path);
    } else {
        NSLog(@"写入视频信息 videoInfo.json 失败: %@", path);
    }
}

- (NSDictionary *)videoInfoForURL:(NSString *)URLString {
    if (!URLString.length) {
        NSLog(@"%s 读取视频信息文件失败: 参数错误", __FUNCTION__);
        return nil;
    }
    
    return [self videoInfoForFolder:[self cacheNameForURL:URLString]];
}

- (NSDictionary *)videoInfoForFolder:(NSString *)folderName {
    NSString *path = [_cacheRootFolder stringByAppendingPathComponent:folderName];
    path = path.append(@"/").append(@"videoInfo.json");
    // 读取文件
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [handle readDataToEndOfFile];
    [handle closeFile];
    if (!data) {
        NSLog(@"读取视频信息文件 videoInfo.json 失败");
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"视频信息文件 videoInfo.json 转码失败");
        return nil;
    }
    
    return info;
}

- (void)cleanCacheWithCallback:(void (^)(void))callback {
    [self cleanCache:nil callback:callback];
}

- (void)cleanCache:(BOOL (^)(NSString * _Nonnull))canRemoveBlock callback:(void (^)(void))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.cacheRootFolder]) {
            NSEnumerator* chileFilesEnumerator = [[fileManager subpathsAtPath:self.cacheRootFolder] objectEnumerator];
            NSString* fileName = nil;
            while ((fileName = [chileFilesEnumerator nextObject]) !=nil) {
                NSString* fileAbsolutePath = [self.cacheRootFolder stringByAppendingPathComponent:fileName];
                if (canRemoveBlock) {
                    // 读取 videoInfo.json
                    NSDictionary *info = [self videoInfoForFolder:fileName];
                    if (!canRemoveBlock(info[@"videoURL"])) {
                        [fileManager removeItemAtPath:fileAbsolutePath error:NULL];
                    }
                } else {
                    [fileManager removeItemAtPath:fileAbsolutePath error:NULL];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback();
            }
        });
    });
}

@end
