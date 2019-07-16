# AVPlayer => M3U8 视频播放缓存

## CocoaPods 集成方式

```ruby
pod 'M3U8VideoCache', :git=> 'https://github.com/LiliCode/M3U8VideoCache.git'
```
此框架依赖 GCDWebServer 第三方框架，在使用 pod 导入会自动导入 GCDWebServer

## 如何使用

1. 在 AppDelegate.m 中开启本地代理服务器
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [M3U8VideoCache proxyStartWithPort:9998 bonjourName:@"demo_proxy"];

    return YES;
}
```

2. 在播放视频的时候，生成一个代理链接给 AVPlayer 加载，AVPlayer 加载这个代理链接会自动被本地代理服务器拦截
```objc
    // 根据原视频链接生成一个代理链接
    NSURL *proxyURL = [M3U8VideoCache proxyURLWithOriginalURL:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"]];
    
    // 代理链接传给播放器
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:proxyURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
```

## 设计原理

1. 参考 [KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache) 
2. 参考资料：https://www.jianshu.com/p/2314782a16c3

## GCDWebServer

1. [GCDWebServer -> Github](https://github.com/swisspol/GCDWebServer)
2. GCDWebServer 使用方法中文版: https://www.jianshu.com/p/534632485234

## m3u8 原理及简介
1. https://www.jianshu.com/p/979af6f79c63
2. https://blog.csdn.net/liubangbo/article/details/87779996
