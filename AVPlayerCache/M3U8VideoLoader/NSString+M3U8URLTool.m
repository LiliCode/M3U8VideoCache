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

@end
