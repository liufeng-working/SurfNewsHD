//
//  PhoneBelleGirlViewController.m
//  SurfNewsHD
//
//  Created by yujiuyin on 15/1/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PhoneBelleGirlViewController.h"
#import "ThreadSummary.h"
#import "ThreadsManager.h"
#import "PathUtil.h"
#import "NSString+Extensions.h"
#import "ImageDownloader.h"
#import "SurfHtmlGenerator.h"
#import "RealTimeStatisticsRequest.h"
#import "EzJsonParser.h"
#import "UIView+NightMode.h"
#import "PhoneWeiboController.h"
#import "AppDelegate.h"
#import "ThreadsManager.h"
#import "BelleGirlScrollView.h"
#import "HotChannelsManager.h"
#import "SNNotificationUtils.h"






@implementation PhoneBelleGirlViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateDragOnly;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBelleGirlscrollView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // 通知美女新闻列表发生改变
    
    ThreadSummary *curTs = [belleGirlscrollView selectThread];
    if (curTs && curTs.threadId != _thread.threadId) {
        [SNNotificationUtils pushNotifyWithType:kNotifyType_BeautyList_Pointer_Changed object:curTs];
    }
}


- (void)initBelleGirlscrollView
{
    if (belleGirlscrollView) {
        return;
    }
    
    
    // 准备数据
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    NSArray *beauties = [tm getLocalThreadsForHotChannelId:self.thread.channelId];
    NSUInteger index = [beauties indexOfObject:self.thread];
    if ([beauties count] > 0 && index == NSNotFound) {
        index = 0;
    }
    
    
    
    CGRect belleR = self.view.bounds;
    belleGirlscrollView = [[BelleGirlScrollView alloc] initWithFrame:belleR];
    [belleGirlscrollView setDelegate:self];
    [belleGirlscrollView setBackgroundColor:[UIColor clearColor]];
    [belleGirlscrollView loadBeauties:beauties curIndex:index];
    [self.view addSubview:belleGirlscrollView];
    
    // 单击事件
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.numberOfTapsRequired = 1;
    [belleGirlscrollView addGestureRecognizer:singleFingerOne];
}

-(void)handleSingleFingerEvent:(UIGestureRecognizer *)gesture
{
    if (belleGirlscrollView.tipsView.alpha == 0.0) {
        [UIView animateWithDuration:0.4 animations:^{
            belleGirlscrollView.tipsView.alpha = 1.0;
            [belleGirlscrollView getSNToolBar].alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            belleGirlscrollView.tipsView.alpha = 0.0;
            [belleGirlscrollView getSNToolBar].alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - NightModeChangedDelegate
-(void)nightModeChanged:(BOOL)night
{
    self.view.backgroundColor = [UIColor colorWithHexValue:night?0xFF2D2E2F:0xFFF8F8F8];

}

#pragma mark BelleGirlScrollViewDelegate
- (void)didBackBt
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

- (void)didShareBt:(id)info
{
    [self showShareView:kWeiboView_Center shareInfo:info];
}
// 请求更多美女频道
- (void)snRequestMoreBeauties
{
    [self sendMoreBeautyNews];
}


// 加载更多美女新闻
-(void)sendMoreBeautyNews
{
    ThreadsManager *tm = [ThreadsManager sharedInstance]; // 帖子管理器
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
    HotChannel *beaautyChannel =
    [hcm hotChannelWithId:_thread.channelId];
    
    if (![tm isHotChannelInRefreshing:self hotChannel:beaautyChannel] &&
        ![tm isHotChannelInGettingMore:self hotChannel:beaautyChannel])
    {
        [PhoneNotification autoHideWithText:@"看累了吧，休息一会稍后再试"];
        [tm getMoreForHotChannel:self
                      hotChannel:beaautyChannel
           withCompletionHandler:^(ThreadsFetchingResult *result)
        {
            if ([result succeeded] && ![result noChanges]) {
                [belleGirlscrollView loadMoreBeauties:result.threads];
            }
        }];
    }
}
@end
