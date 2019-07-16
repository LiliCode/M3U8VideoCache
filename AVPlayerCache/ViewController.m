//
//  ViewController.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerViewController.h"

#import "M3U8VideoLoader/M3U8VideoCache.h"

@interface ViewController ()
//@property (strong, nonatomic) GCDWebDAVServer *webServer;
@property (strong, nonatomic) NSMutableArray *videoURLs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
#if 1

    [M3U8VideoCache proxyStartWithPort:9999 bonjourName:@"m3u8VideoProxy"];
    
#endif
    
    // http://192.168.1.120:9999/4306189C7E66899DB58BE8564F642C1E/index.m3u8
    self.videoURLs = [NSMutableArray new];
    [self.videoURLs addObject:@"http://cdn-168.bmxjgp.com/uploads/km3u8/c0c/c0c15ff225fde2e997248644e518480a/index.m3u8"];
    [self.videoURLs addObject:@"http://cdn-168.bmxjgp.com/uploads/km3u8/932/93202544212b352259a27cec20a56537/index.m3u8"];
    [self.videoURLs addObject:@"http://cdn-168.bmxjgp.com/uploads/km3u8/847/8473b3a649c08ef8b36628ac9b9f2f45/index.m3u8"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/video-preview/751/7516619b4d580d3b25383c4d34679d93/perview.m3u8"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/km3u8/696/69668f435db7b4ae57de39d9e9b8fa81/index.m3u8?_v=20190322"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/video-preview/e5c/e5c801c0959a2a78f7ddff9212d28d92/perview.m3u8?_v=20190322"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/km3u8/427/4278b6f894f7966302cab06900db24a5/index.m3u8?_v=20190322"];
    [self.videoURLs addObject:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
    [self.videoURLs addObject:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    
}

- (IBAction)playVideoAction:(UIButton *)sender {
    [self performSegueWithIdentifier:@"player" sender:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoURLs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.videoURLs objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"player" sender:@{@"videoURL":self.videoURLs[indexPath.row]}];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"player"]) {
        VideoPlayerViewController *playerVC = segue.destinationViewController;
//        playerVC.videoURL = [NSURL URLWithString:@"http://cdn-168.bmxjgp.com/uploads/km3u8/c0c/c0c15ff225fde2e997248644e518480a/index.m3u8"];
        // http://cdn-168.bmxjgp.com/uploads/km3u8/932/93202544212b352259a27cec20a56537/index.m3u8
        // http://cdn-168.bmxjgp.com/uploads/km3u8/847/8473b3a649c08ef8b36628ac9b9f2f45/index.m3u8
//        playerVC.videoURL = [NSURL URLWithString:@"http://lzaiuw.changba.com/userdata/video/940071102.mp4"];
        
//        playerVC.videoURL = [M3U8VideoCache proxyURLWithOriginalURL:[NSURL URLWithString:sender[@"videoURL"]]];
        playerVC.videoURL = [NSURL URLWithString:sender[@"videoURL"]];
        
//        playerVC.videoURL = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
    }
}

@end
