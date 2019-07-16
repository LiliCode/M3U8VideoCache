//
//  M3U8ParseViewController.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8ParseViewController.h"
#import "M3U8URLParse.h"

@interface M3U8ParseViewController ()

@end

@implementation M3U8ParseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"videoURL: %@", self.videoURL);
    
//    NSString *indexFileURLString = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"m3u8"];
//    // 解析 index.m3u8 索引文件，得到视频d片段的相对路径
//    NSArray *indexURLList = [M3U8URLParse parseM3u8IndexFile:indexFileURLString];
//    NSLog(@"indexs: %@", indexURLList);
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
