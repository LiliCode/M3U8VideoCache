//
//  URLTool.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "URLTool.h"
#import "NSURL+M3U8URLTool.h"

@implementation URLTool

+ (NSString *)URLEncode:(NSString *)URLString {
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = [URLString length];
    const char *c = [URLString UTF8String];
    NSString *resultString = @"";
    for(int i = 0; i < length; i++) {
        @autoreleasepool {
            switch (*c) {
                case '/':
                    resultString = [resultString stringByAppendingString:@"%2F"];
                    break;
                case '\'':
                    resultString = [resultString stringByAppendingString:@"%27"];
                    break;
                case ';':
                    resultString = [resultString stringByAppendingString:@"%3B"];
                    break;
                case '?':
                    resultString = [resultString stringByAppendingString:@"%3F"];
                    break;
                case ':':
                    resultString = [resultString stringByAppendingString:@"%3A"];
                    break;
                case '@':
                    resultString = [resultString stringByAppendingString:@"%40"];
                    break;
                case '&':
                    resultString = [resultString stringByAppendingString:@"%26"];
                    break;
                case '=':
                    resultString = [resultString stringByAppendingString:@"%3D"];
                    break;
                case '+':
                    resultString = [resultString stringByAppendingString:@"%2B"];
                    break;
                case '$':
                    resultString = [resultString stringByAppendingString:@"%24"];
                    break;
                case ',':
                    resultString = [resultString stringByAppendingString:@"%2C"];
                    break;
                case '[':
                    resultString = [resultString stringByAppendingString:@"%5B"];
                    break;
                case ']':
                    resultString = [resultString stringByAppendingString:@"%5D"];
                    break;
                case '#':
                    resultString = [resultString stringByAppendingString:@"%23"];
                    break;
                case '!':
                    resultString = [resultString stringByAppendingString:@"%21"];
                    break;
                case '(':
                    resultString = [resultString stringByAppendingString:@"%28"];
                    break;
                case ')':
                    resultString = [resultString stringByAppendingString:@"%29"];
                    break;
                case '*':
                    resultString = [resultString stringByAppendingString:@"%2A"];
                    break;
                default:
                    resultString = [resultString stringByAppendingFormat:@"%c", *c];
            }
            c++;
        }
    }
    return resultString;
}

+ (NSString *)URLDecode:(NSString *)URLString {
//    if (@available(iOS 9.0, *)) {
//        return [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    }
    
    return [URLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)contentTypeForURL:(NSString *)URLString {
    NSString *contentType = nil;
    if ([URLString m3u8URLString]) {
        contentType = @"application/vnd.apple.mpegurl";
    } else if ([URLString tsURLString]) {
        contentType = @"video/mp2t";
    } else if ([URLString keyURLString]) {
        contentType = @"application/octet-stream";
    }
    
    return contentType;
}

@end

