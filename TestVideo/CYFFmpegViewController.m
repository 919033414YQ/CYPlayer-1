//
//  CYFFmpegViewController.m
//  CYPlayer
//
//  Created by 黄威 on 2018/7/19.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import "CYFFmpegViewController.h"
#import "CYFFmpegPlayer.h"
#import "Cyonry.h"
#import "UIViewController+CYExtension.h"

#define kiPad  ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) //ipad

@interface CYFFmpegViewController ()
{
    NSArray *_localMovies;
    NSArray *_remoteMovies;
    CYFFmpegPlayer *vc;
}

@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIButton * infoBtn;

@end

@implementation CYFFmpegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self openLandscape];

    _remoteMovies = @[
                      
                      //            @"http://eric.cast.ro/stream2.flv",
                      //            @"http://liveipad.wasu.cn/cctv2_ipad/z.m3u8",
                      @"http://www.wowza.com/_h264/BigBuckBunny_175k.mov",
                      // @"http://www.wowza.com/_h264/BigBuckBunny_115k.mov",
                      @"rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov",
                      @"http://santai.tv/vod/test/test_format_1.3gp",
                      @"http://santai.tv/vod/test/test_format_1.mp4",
                      @"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov",
                      @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4",
                      @"rtmp://live.hkstv.hk.lxdns.com/live/hks",
                      @"rtmp://rtmp.yayiguanjia.com/dentalshow/1231244_lld?auth_key=1532686852-0-0-d5bc9fd0b5f48950464b48d7f3b37afd",
                      //@"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov",
                      //@"http://santai.tv/vod/test/BigBuckBunny_175k.mov",
                      
                      //            @"rtmp://aragontvlivefs.fplive.net/aragontvlive-live/stream_normal_abt",
                      //            @"rtmp://ucaster.eu:1935/live/_definst_/discoverylacajatv",
                      //            @"rtmp://edge01.fms.dutchview.nl/botr/bunny.flv"
                      ];
    
    NSString *path;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
//    path = _remoteMovies[4];
    path = self.path.length > 0 ? self.path :  _remoteMovies[6];
    
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([path.pathExtension isEqualToString:@"wmv"])
        parameters[CYPlayerParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[CYPlayerParameterDisableDeinterlacing] = @(YES);
    
    
    UIView * contentView = [UIView new];
    contentView.backgroundColor = [UIColor blackColor];
    self.contentView = contentView;
    [self.view addSubview:contentView];
    [contentView cy_makeConstraints:^(CYConstraintMaker *make) {
        make.center.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(contentView.cy_width).multipliedBy(9.0 / 16.0);
    }];
    
    vc = [CYFFmpegPlayer movieViewWithContentPath:path parameters:parameters];
    vc.autoplay = YES;
    vc.generatPreviewImages = YES;
    [contentView addSubview:vc.view];
    
    [vc.view cy_makeConstraints:^(CYConstraintMaker *make) {
        if (kiPad)
        {
            make.center.offset(0);
            make.leading.trailing.offset(0);
            make.height.equalTo(vc.view.cy_width).multipliedBy(9.0 / 16.0);
        }
        else
        {
            make.center.offset(0);
            make.top.bottom.offset(0);
            make.width.equalTo(vc.view.cy_height).multipliedBy(16.0 / 9.0);
        }
    }];
    
    
     __weak __typeof(&*self)weakSelf = self;
    vc.lockscreen = ^(BOOL isLock) {
        if (isLock)
        {
            [weakSelf lockRotation];
        }
        else
        {
            [weakSelf unlockRotation];
        }
    };
    
    [self addInfoBtn];
}

- (void)addInfoBtn
{
    self.infoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.infoBtn setTitle:@"info" forState:UIControlStateNormal];
    [self.view addSubview:self.infoBtn];
    [self.infoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.infoBtn addTarget:self action:@selector(onInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoBtn cy_makeConstraints:^(CYConstraintMaker *make) {
        make.centerX.equalTo(self.infoBtn.superview.cy_centerX);
        make.width.height.equalTo(@50);
        make.top.equalTo(self.contentView.cy_bottom).offset(20);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [vc stop];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

# pragma mark - Event
- (void)onInfoBtnClick:(UIButton *)sender
{
    if (vc.decoder)
    {
        NSString * info = [[vc.decoder info] description];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Info" message:(info.length ? info : @"") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


# pragma mark - 系统横竖屏切换调用

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (size.width > size.height)
    {
        [self.contentView cy_remakeConstraints:^(CYConstraintMaker *make) {
            make.top.bottom.equalTo(@(0));
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
        }];
    }
    else
    {
        [self.contentView cy_remakeConstraints:^(CYConstraintMaker *make) {
            make.center.offset(0);
            make.leading.trailing.offset(0);
            make.height.equalTo(self.contentView.cy_width).multipliedBy(9.0 / 16.0);
        }];
    }
}

@end
