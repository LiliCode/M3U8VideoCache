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
    
    [self.videoURLs addObject:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
    [self.videoURLs addObject:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
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
