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
    
    self.videoURLs = [NSMutableArray new];
    
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

        playerVC.videoURL = [NSURL URLWithString:sender[@"videoURL"]];
    }
}

@end
