//
//  PhotoCollectionContent.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionContentController.h"
#import "PhotoCollectionData.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "PhotoCollectionResponse.h"
#import "EzJsonParser.h"
#import "PhotoCollectionManager.h"
#import "ThreadsManager.h"


@implementation PhotoCollectionContentController

- (id)init
{
    if (self = [super init]) {
        
         self.titleState = PhoneSurfControllerStateNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 背景
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentWidth, kContentHeight)];
    bg.backgroundColor = [UIColor blackColor];// 这个色值和PictureBox一样
    [self.view addSubview:bg];
    
    
    // 底部工具栏，没有用父类的，因改变不了图集颜色[self addBottomToolsBar];
    // tabBar 背景
    float bgH = 49.f; // 底部状态栏高度
    float ctrlWidth = kContentWidth;
    float ctrlHeight = kContentHeight;
    UIView *customTabBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, ctrlHeight - bgH, ctrlWidth, bgH)];
    customTabBar.backgroundColor = [[UIColor alloc] initWithRed:0.f green:0.f blue:0.f alpha:0.6];
    [self.view addSubview:customTabBar];
    {
        // 返回按钮
        UIImage *backImage = [UIImage imageNamed:@"backBar"];
        float bW = backImage.size.width;
        float bH = backImage.size.height;
        float bY = (bgH - bH) * 0.5;
        CGRect bRect = CGRectMake(0.f, bY, bW, bH);
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = bRect;
        [backBtn setBackgroundImage:backImage forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(goBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customTabBar addSubview:backBtn];
    }

    
    // 大图模式控件
    CGRect pbRect = CGRectMake(0, 0, kContentWidth, kContentHeight);
    _pictureBox = [[PictureBox alloc] initWithFrame:pbRect];
    _pictureBox.delegate = self;
    _pictureBox.backgroundColor = [UIColor blackColor];
    _pictureBox.hidden = YES;
    [self loadPicureBoxDate];    
    [self.view addSubview:_pictureBox];    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    _pcc = nil;
    _photoColl = nil;
}

- (void)loadPicureBoxDate{
    if (!_photoColl) {
        return;
    }
    
    _pictureBox.hidden = YES;
    
    // 拿本地缓存
    NSArray *photoList = 
    [[PhotoCollectionManager sharedInstance] getPhotoInfoListWithPhotoCollection:_photoColl];
    if (photoList != nil && photoList.count > 0) {
        _pictureBox.hidden = NO;        
        if (_photoColl.isTempData) {
            for (PhotoData *pd in photoList) {
                pd.isCacheData = YES;
            }
        }
        [_pictureBox reloadDataWithPhotoDateArray:_photoColl];
    }
    else{
        // 请求服务器
        // 添加一个风火轮控件
        float midX = CGRectGetMidX(_pictureBox.bounds);
        float midY = (CGRectGetHeight(_pictureBox.bounds) - kTabBarHeight)/2;
        CGRect hotwheelRect = CGRectMake(midX-20, midY-20, 40, 40);
        UIActivityIndicatorView *hotwheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        hotwheel.frame = hotwheelRect;
        [hotwheel startAnimating];
        [self.view addSubview:hotwheel];
        
        // 本地没有缓存，向服务器拿数据
        [[PhotoCollectionManager sharedInstance] requestPhotoCollectionContent:_photoColl
                                                         withCompletionHandler:^(ThreadsFetchingResult *result)
        {
            if (result.succeeded && result.channelId == _photoColl.pcId) {
                _pictureBox.hidden = NO;
                
                if (_photoColl.isTempData) {
                    for (PhotoData *pd in result.threads) {
                        pd.isCacheData = YES;
                    }
                }
                [_pictureBox reloadDataWithPhotoDateArray:_photoColl];
            }
            else{
                [PhoneNotification autoHideWithText:@"网络异常"];
            }
                
            // 移除风火轮
            [hotwheel stopAnimating];
            [hotwheel removeFromSuperview];
        }];
    }
}


-(void)goBackButtonClicked:(id)sender
{
    [self pictureBoxShowFinish];
}

#pragma mark PictureBoxDelegate
- (void)pictureBoxShowFinish
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

@end
