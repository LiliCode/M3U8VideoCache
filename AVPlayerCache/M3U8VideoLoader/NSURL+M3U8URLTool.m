//
//  NSURL+M3U8URLTool.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/15.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "NSURL+M3U8URLTool.h"

@implementation NSURL (M3U8URLTool)

- (BOOL)m3u8URL {
    return [self.absoluteString m3u8URLString];
}

- (BOOL)tsURL {
    return [self.absoluteString tsURLString];
}

- (BOOL)keyURL {
    return [self.absoluteString keyURLString];
}

@end
