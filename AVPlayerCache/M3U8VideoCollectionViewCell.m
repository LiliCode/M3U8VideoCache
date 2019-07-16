//
//  M3U8VideoCollectionViewCell.m
//  AVPlayerCache
//
//  Created by mac on 2019/7/16.
//  Copyright © 2019 Qiyue. All rights reserved.
//

#import "M3U8VideoCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "M3U8VideoLoader/M3U8VideoCache.h"

@interface M3U8VideoCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@end

@implementation M3U8VideoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setVideoURL:(NSString *)videoURL {
    if (_videoURL.length) {
        return;
    }
    
    _videoURL = videoURL;
    
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[M3U8VideoCache proxyURLWithOriginalURL:[NSURL URLWithString:self.videoURL]]];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];

    self.playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer addSublayer:self.playerLayer];

    __weak typeof (self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.5f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat progress = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) / CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        weakSelf.progressView.progress = progress;
        
        if (progress >= 1.0f) {
            [weakSelf rerunPlayVideo];
        }
    }];

    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.playerView.bounds;
}


- (void)rerunPlayVideo {
    CGFloat a = 0;
    NSInteger dragedSeconds = floorf(a);
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [self.player seekToTime:dragedCMTime];
    [self.player play];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = (AVPlayerItemStatus)[change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                
                break;
            case AVPlayerItemStatusReadyToPlay:
                [self.player play];
                break;
            case AVPlayerItemStatusFailed:
                [self.player pause];
                break;
                
            default:
                break;
        }
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}

@end


