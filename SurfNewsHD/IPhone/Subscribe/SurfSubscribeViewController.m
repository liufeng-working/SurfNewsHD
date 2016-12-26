//
//  SurfSubscribeViewController.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfSubscribeViewController.h"
//#import "SubsTableViewCell.h"
#import "NewestManager.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelThreadsResponse.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"
#import "ThreadSummary.h"
#import "ThreadsManager.h"
#import "SNSubsThreadSummaryViewCell.h"
#import "SubsChannelSummaryViewController.h"
#import "LoadingView.h"
#import "SubsChannelsManager.h"
#import "FirstRunView.h"
#import "AppSettings.h"
#import "SubsChannelsView.h"

#define CellShowThreadSummaryCount 3    // cell显示帖子详情的个数


@implementation SurfSubscribeViewController
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
//        self.titleState = PhoneSurfControllerStateRoot;
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"冲浪订阅";
    
	// Do any additional setup after loading the view.
    CGRect viewRect = CGRectMake(0.f,
                                      [self StateBarHeight],
                                      kContentWidth,
                                      kContentHeight-kTabBarHeight-[self StateBarHeight]);
    _subsChannelsView = [[SubsChannelsView alloc] initWithFrame:viewRect];
    [_subsChannelsView loadSubsChannelsList];
    [self.view addSubview:_subsChannelsView];   
    
    
    // 添加按钮
    float addBtnW = 45.f, addBtnH = 45.f;
    float btnX = kContentWidth - addBtnW;
    float btnY = ([self StateBarHeight] - addBtnH) * 0.5f;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setFrame:CGRectMake(btnX, btnY, addBtnW, addBtnH)];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"navAddBtn"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addSubschannelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    // 添加一个分割线图片
    float divideH = 30.f;
    float divideW = 1.f;
    float divideY = ([self StateBarHeight] - divideH) * 0.5f;
    _topVLine = [[UIView alloc] initWithFrame:CGRectMake(btnX, divideY, divideW, divideH)];
    [self.view addSubview:_topVLine];
    
    
    // 添加一个简洁模式按钮
    float simpleBtnW = 45.f, simpleBtnH = 45.f;
    float simpleBtnX = kContentWidth - addBtnW - simpleBtnW - divideW;
    float simpleBtnY = ([self StateBarHeight] - simpleBtnH) * 0.5f;
    UIButton *simpleBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [simpleBt setFrame:CGRectMake(simpleBtnX, simpleBtnY, simpleBtnW, simpleBtnH)];
    [simpleBt setBackgroundImage:[UIImage imageNamed:@"unwrap"] forState:UIControlStateNormal];
    [simpleBt addTarget:self action:@selector(changeSubsShowMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:simpleBt];
    
    
    if (IOS7) {
        _topVLine.frame=CGRectMake(btnX, divideY+5, divideW, divideH);
        [addBtn setFrame:CGRectMake(btnX, btnY+5, addBtnW, addBtnH)];
        [simpleBt setFrame:CGRectOffset(simpleBt.frame, 0, 5)];
    }
    
    [[SubsChannelsManager sharedInstance] addChannelObserver:_subsChannelsView];
    
    // 增加一个底部菜单栏
    [self addBottomToolsBar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //推荐订阅界面
    if ([AppSettings boolForKey:BoolKeyShowSubsPrompt]) {
        if ([SubsChannelsManager sharedInstance].loadLocalSubsChannels.count > 0) {
            [AppSettings setBool:NO forKey:BoolKeyShowSubsPrompt];
            [recommendView removeFromSuperview];
            recommendView = nil;
            [recommendChannels removeAllObjects];
            recommendChannels = nil;
        } else {
            if (!recommendView) {
                recommendView = [[RecommendSubsChannelView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, kContentHeight - kTabBarHeight)];
                [self.view addSubview:recommendView];
                [recommendView applyTheme];
                recommendChannels = [NSMutableArray new];
            }
            
            if (recommendChannels.count == 0) {
                [self loadRecommendSubsChannel];
            }
            return;
        }
    } else {
        if (recommendView) {
            [recommendView removeFromSuperview];
            recommendView = nil;
            [recommendChannels removeAllObjects];
            recommendChannels = nil;
        }
    }
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    if (![[AppSettings stringForKey:StringLastSubsSlideGuideVersion] isEqualToString:version])
    {
        FirstRunView *view =[[FirstRunView alloc] initShowViewType:StringLastSubsSlideGuideVersion];
        view.hidden = NO;
        [self.view addSubview:view];
        [AppSettings setString:version forKey:StringLastSubsSlideGuideVersion];
    }
    
    
    [_subsChannelsView refreshSubsChannelsListForTimeInterval];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if ([AppSettings boolForKey:BoolKeyShowSubsPrompt]) {
        return;
    }
    
    //是否更新订阅频道新闻
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if ([tm isUpdateSubsChannelsLastNews]) {
        [tm cancelUpdateSubsChannelsNews:self];
    }
    
    // 取消加载状态
    [_subsChannelsView cancelLoadingState:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [PhoneNotification hideNotification];
}

// 添加订阅
- (void)addSubschannelClick:(id)sender{
    AddSubscribeController *addController = [[AddSubscribeController alloc] init];
    [self presentController:addController
                   animated:PresentAnimatedStateFromRight];
}

// 切换订阅频道显示模式
- (void)changeSubsShowMode:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        btn.tag = btn.tag == 0 ? 1 : 0;
        UIImage *bgImage = btn.tag == 1 ? [UIImage imageNamed:@"wrap"]:[UIImage imageNamed:@"unwrap"];
        [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
        [_subsChannelsView changeStyle];
    }
}
#pragma mark NightModeChangedDelegate
- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    if (night) {
        _topVLine.backgroundColor = [UIColor colorWithHexValue:0xFF19191A];
    }
    else{
        _topVLine.backgroundColor = [UIColor colorWithHexValue:0xFFDCDBDB];
    }
    
    [_subsChannelsView viewNightModeChanged:night];
    if (recommendView) {
        [recommendView applyTheme];
    }
}

//加载推荐订阅栏目
- (void)loadRecommendSubsChannel
{
    [PhoneNotification manuallyHideWithIndicator];
    [[SubsChannelsManager sharedInstance] loadRecommendSubsChannelsWithCompletionHandler:^(NSArray *channels) {
        if (channels) {
            [recommendChannels removeAllObjects];
            [recommendChannels addObjectsFromArray:channels];
            [recommendView loadScrollView:recommendChannels];
            [PhoneNotification hideNotification];
        } else {
            [PhoneNotification autoHideWithText:@"推荐订阅获取失败,请稍后重试"];
        }
    }];
}

//提交选择的推荐订阅
- (void)commitRecommendController
{
    NSMutableArray *commitChannels = [NSMutableArray new];
    
    for (SubsChannel *channel in recommendChannels) {
        if (channel.isSelected == 1) {
            [commitChannels addObject:channel];
        }
    }
    
    if (commitChannels.count == 0) {
        [PhoneNotification autoHideWithText:@"请至少选择一个订阅栏目"];
        return;
    }
    
    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    for (SubsChannel *channel in commitChannels) {
        [scm addSubscription:channel];
    }
    [scm commitChangesWithHandler:^(BOOL succeeded) {
        if (succeeded) {
            [AppSettings setBool:NO forKey:BoolKeyShowSubsPrompt];
            [recommendView removeFromSuperview];
            recommendView = nil;
            [recommendChannels removeAllObjects];
            recommendChannels = nil;
            NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
            if (![[AppSettings stringForKey:StringLastSubsSlideGuideVersion] isEqualToString:version])
            {
                FirstRunView *view =[[FirstRunView alloc] initShowViewType:StringLastSubsSlideGuideVersion];
                view.hidden = NO;
                [self.view addSubview:view];
                [AppSettings setString:version forKey:StringLastSubsSlideGuideVersion];
            }
        } else {
            [PhoneNotification autoHideWithText:@"订阅栏目失败,请重试"];
            [commitChannels removeAllObjects];
        }
    }];
}

@end