//
//  VideoPlayerViewController.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "M3U8VideoLoader/M3U8VideoLoaderManager.h"
#import "M3U8VideoLoader/M3U8VideoCacheTool.h"
#import "M3U8VideoLoader/M3U8VideoHTTPServer.h"
#import "M3U8VideoLoader/M3U8VideoCache.h"

@interface VideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIView *playerView1;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider1;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL isChangeValue;

@property (strong, nonatomic) AVPlayer *player1;
@property (strong, nonatomic) AVPlayerLayer *playerLayer1;
@property (strong, nonatomic) AVPlayerItem *playerItem1;
@property (assign, nonatomic) BOOL isPlaying1;
@property (assign, nonatomic) BOOL isChangeValue1;

@property (strong, nonatomic) M3U8VideoLoaderManager *loaderManager;

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // m3u8 视频缓存，边下边播
    self.playerItem = [AVPlayerItem playerItemWithURL:[M3U8VideoCache proxyURLWithOriginalURL:self.videoURL]];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer addSublayer:self.playerLayer];
    self.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    
    
    
    
    self.playerItem1 = [AVPlayerItem playerItemWithURL:[M3U8VideoCache proxyURLWithOriginalURL:[NSURL URLWithString:@"http://cdn-09.gxgjmsj.com/media/km3u8/5b6/5b60ac39a4062bc0bec1ee9c7d7d379e/index.m3u8?_v=20190322"]]];
    
    self.player1 = [AVPlayer playerWithPlayerItem:self.playerItem1];
    self.playerLayer1 = [AVPlayerLayer playerLayerWithPlayer:self.player1];
    
    self.playerLayer1.frame = self.playerView1.bounds;
    [self.playerView1.layer addSublayer:self.playerLayer1];
    self.playerLayer1.backgroundColor = [[UIColor blackColor] CGColor];
    
    
    
    // 监听进度
    __weak typeof (self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.5f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.isChangeValue) {
            CGFloat progress = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) / CMTimeGetSeconds(weakSelf.player.currentItem.duration);
            weakSelf.progressSlider.value = progress;
        }
    }];
    
    [self.player1 addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.5f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.isChangeValue1) {
            CGFloat progress = CMTimeGetSeconds(weakSelf.player1.currentItem.currentTime) / CMTimeGetSeconds(weakSelf.player1.currentItem.duration);
            weakSelf.progressSlider1.value = progress;
        }
    }];
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.playerItem1 addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.playerLayer.frame = self.playerView.bounds;
    self.playerLayer1.frame = self.playerView1.bounds;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = (AVPlayerItemStatus)[change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                
                break;
            case AVPlayerItemStatusReadyToPlay:
                [self.player play];
                [self.player1 play];
                break;
            case AVPlayerItemStatusFailed:
                [self.player pause];
                [self.player1 pause];
                break;
                
            default:
                break;
        }
    }
}

- (IBAction)sliderAction:(UISlider *)sender {
    //拖拽的时候先暂停
    BOOL isPlaying = false;
    if (self.player.rate > 0) {
        isPlaying = true;
        [self.player pause];
    }
    // 先不跟新进度
    self.isChangeValue = true;
    
//    float fps = [[[self.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration) * sender.value, 30);
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        if (isPlaying) {
            [weakSelf.player play];
        }
        weakSelf.isChangeValue = false;
    }];
}

- (IBAction)slider1Action:(UISlider *)sender {
    //拖拽的时候先暂停
    BOOL isPlaying = false;
    if (self.player1.rate > 0) {
        isPlaying = true;
        [self.player1 pause];
    }
    // 先不跟新进度
    self.isChangeValue1 = true;
    
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player1.currentItem.duration) * sender.value, 30);
    __weak typeof(self) weakSelf = self;
    [self.player1 seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        if (isPlaying) {
            [weakSelf.player1 play];
        }
        weakSelf.isChangeValue1 = false;
    }];
}

- (IBAction)playAction:(UIBarButtonItem *)sender {
    if (self.isPlaying) {
        [self.player pause];
        self.isPlaying = NO;
        sender.style = UIBarButtonSystemItemPlay;
    } else {
        [self.player play];
        self.isPlaying = YES;
        sender.style = UIBarButtonSystemItemPause;
    }
}


- (void)dealloc {
    NSLog(@"视频页面销毁!!!");
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}

@end
