//
//  NSString+M3U8URLTool.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/15.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "NSString+M3U8URLTool.h"

@implementation NSString (M3U8URLTool)

- (NSString *(^)(NSString *string))append {
    return ^NSString *(NSString *string) {
        if (!string.length) {
            return self;
        }
        
        return [self stringByAppendingString:string];
    };
}


- (BOOL)m3u8URLString {
    return [self hasSuffix:@".m3u8"] || [self containsString:@".m3u8"];
}

- (BOOL)tsURLString {
    return [self hasSuffix:@".ts"] || [self containsString:@".ts"];
}

- (BOOL)keyURLString {
    return [self hasSuffix:@".key"] || [self containsString:@".key"];
}

+ (NSString *)stringWithbytes:(int)bytes {
    if (bytes < 1024) { // B
        return [NSString stringWithFormat:@"%dB", bytes];
    } else if (bytes >= 1024 && bytes < 1024 * 1024) { // KB
        return [NSString stringWithFormat:@"%.0fKB", (double)bytes / 1024];
    } else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) { // MB
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    } else { // GB
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

@end
