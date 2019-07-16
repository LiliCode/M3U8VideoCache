//
//  M3U8VideoCollectionViewController.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/16.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoCollectionViewController.h"
#import "M3U8VideoCollectionViewCell.h"

@interface M3U8VideoCollectionViewController ()
@property (strong, nonatomic) NSMutableArray *videoURLs;

@end

@implementation M3U8VideoCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.videoURLs = [NSMutableArray new];
    [self.videoURLs addObject:@"http://cdn-168.bmxjgp.com/uploads/km3u8/c0c/c0c15ff225fde2e997248644e518480a/index.m3u8"];
    [self.videoURLs addObject:@"http://cdn-168.bmxjgp.com/uploads/km3u8/932/93202544212b352259a27cec20a56537/index.m3u8"];
    [self.videoURLs addObject:@"http://cdn-168.bmxjgp.com/uploads/km3u8/847/8473b3a649c08ef8b36628ac9b9f2f45/index.m3u8"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/video-preview/751/7516619b4d580d3b25383c4d34679d93/perview.m3u8"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/km3u8/696/69668f435db7b4ae57de39d9e9b8fa81/index.m3u8?_v=20190322"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/video-preview/e5c/e5c801c0959a2a78f7ddff9212d28d92/perview.m3u8?_v=20190322"];
    [self.videoURLs addObject:@"http://cdn-09.gxgjmsj.com/media/km3u8/427/4278b6f894f7966302cab06900db24a5/index.m3u8?_v=20190322"];
    [self.videoURLs addObject:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    M3U8VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.videoURL = [self.videoURLs objectAtIndex:indexPath.row];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(size.width / 2.0f - 6.0f, (size.width / 2.0f - 6.0f) * (9.0f / 16.0f));
}


@end
