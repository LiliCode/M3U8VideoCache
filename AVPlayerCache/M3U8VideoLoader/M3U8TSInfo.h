//
//  M3U8TSInfo.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3U8TSInfo : NSObject
@property (assign, nonatomic) double timeLength;    // ts 片段时间长度
@property (copy, nonatomic) NSString *indexURL;     // 相对路径
@property (copy, nonatomic) NSString *tsIndexURL;   // 完整的绝对路径
@property (strong, nonatomic) NSDictionary *encInfo;// m3u8 加密信息

@end

NS_ASSUME_NONNULL_END
