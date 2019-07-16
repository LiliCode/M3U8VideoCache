//
//  M3U8URLTableViewController.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8URLTableViewController.h"
#import "M3U8ParseViewController.h"
#import "M3U8VideoLoader/M3U8VideoCache.h"

@interface M3U8URLTableViewController ()
@property (strong, nonatomic) NSMutableArray *videoURLs;

@end

@implementation M3U8URLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoURLs = [NSMutableArray new];
    [self.videoURLs addObject:@"实例链接: http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
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
    
//    [self performSegueWithIdentifier:@"parse" sender:@{@"videoURL":self.videoURLs[indexPath.row]}];
    
    [self performSegueWithIdentifier:@"collect" sender:nil];
}

- (IBAction)clearCacheAction:(UIBarButtonItem *)sender {
    [M3U8VideoCache cleanCacheWithCallback:^{
        NSLog(@"清除缓存成功!!!");
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"parse"]) {
        M3U8ParseViewController *vc = segue.destinationViewController;
        vc.videoURL = [sender objectForKey:@"videoURL"];
    }
}

@end
