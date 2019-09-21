//
//  M3U8VideoCache.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/11.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MD5 加密函数

 @param string 需要 md5 加密的字符串
 @return 返回 md5 加密之后的大写字符串
 */
FOUNDATION_EXTERN NSString *MD5(NSString *string);

@interface M3U8VideoCacheTool : NSObject
/// 下载 ts 文件的队列
@property (nonatomic, strong, readonly) NSOperationQueue *downloadQueue;
/// 文件缓存的根目录
@property (nonatomic, copy, readonly) NSString *cacheRoot;



+ (instancetype)sharedCache;


/**
 保存数据

 @param data ts 视频片段或者 m3u8 索引文件
 @param URLString data 对应的 URL 链接
 */
- (void)setData:(NSData *)data forURL:(NSString *)URLString;

/**
 使用链接获取缓存数据

 @param URLString 链接
 @return 返回 ts 或者 m3u8索引文件
 */
- (NSData *)dataForURL:(NSString *)URLString;

/**
 使用key缓存URL到内存

 @param URL 需要缓存的URL
 @param key key
 */
- (void)setURL:(NSURL *)URL forKey:(id<NSCopying>)key;

/**
 通过key获取URL

 @param key key
 @return 返回URL
 */
- (NSURL *)URLForKey:(id<NSCopying>)key;

/**
 通过链接判断缓存中是否存在这个文件

 @param URLString URL链接
 @return YES 缓存中存在这个文件
 */
- (BOOL)isExists:(NSString *)URLString;

/**
 通过 URL 生成一个缓存文件夹名称，每一个 m3u8 视频对应一个文件夹

 @param URLString 视频链接
 @return 返回 MD5 加密完成的字符串
 */
- (NSString *)cacheNameForURL:(NSString *)URLString;

/**
 清除磁盘缓存数据

 @param callback 清除完成之后的回调
 */
- (void)cleanCacheWithCallback:(void (^)(void))callback;

/**
 清除磁盘缓存数据

 @param canRemoveBlock 是否可以清除该缓存
 @param callback 清除完成之后的回调
 */
- (void)cleanCache:(BOOL (^ _Nullable)(NSString *URLString))canRemoveBlock callback:(void (^)(void))callback;

/**
 根据链接保存 resumeData 数据

 @param resumeData NSURLSessionDownloadTask 下载中断的断点数据
 @param URLString NSURL 下载数据的链接
 */
- (void)setResumeData:(NSData *)resumeData forURL:(NSString *)URLString;

/**
 根据链接找到 resumeData

 @param URLString 下载数据的链接
 @return NSData
 */
- (NSData *)resumeDataForURL:(NSString *)URLString;

/**
 根据URL删除断点数据 resumeData

 @param URLString 下载数据的链接
 */
- (void)removeResumeDataForURL:(NSString *)URLString;

/**
 保存 videoInfo.json 数据

 @param videoInfoData JSON Data
 @param URLString 视频链接
 */
- (void)setVideoInfo:(NSData *)videoInfoData forURL:(NSString *)URLString;

/**
 获取 videoInfo 字典数据

 @param URLString 视频链接
 @return videoInfo 信息
 */
- (NSDictionary *)videoInfoForURL:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
