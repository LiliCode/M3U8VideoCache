//
//  NSURLSession+ResumeData.h
//  AVPlayerCache
//
//  Created by mac on 2019/7/18.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (ResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithIOS10ResumeData:(NSData *)resumeData;

@end

NS_ASSUME_NONNULL_END
