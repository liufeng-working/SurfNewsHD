//
//  SubsThreadSummaryViewController.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelSummaryViewController.h"
#import "AppDelegate.h"
#import "DownLoadViewController.h"
#import "NetworkStatusDetector.h"
#import "ThreadsManager.h"
#import "UIAlertView+Blocks.h"


@interface SubsChannelSummaryViewController ()
@property(nonatomic,strong) subsChannelContentView *contentView;
@end

@implementation SubsChannelSummaryViewController

- (id)initWithStyle:(SubsChannelSummaryStyle)style_
{
    self = [super init];
    if (self) {
        style = style_;
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
//    self.title = _subsChannel.name;

    UIView *topView = [super topBarView];
    CGPoint centP = [super topGoBackView].center;
    
    //标题，限制最多显示8个字
    CGFloat titleW = 180.f;
    CGFloat titleH = 26.f;
    CGFloat titleX = CGRectGetWidth(topView.bounds) - titleW - 70 - 8;
    CGFloat titleY = CGRectGetHeight(topView.bounds) - titleH;
    CGRect titleR = CGRectMake(titleX, titleY, titleW, titleH);
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:titleR];
    CGPoint titleCentP = titleLabel.center;
    titleCentP.y = centP.y;
    titleLabel.center = titleCentP;
    titleLabel.text = _subsChannel.name;
    titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    titleLabel.textColor = [UIColor colorWithHexValue:0xffad2f2f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];

    
    // 添加一个取消订阅的按钮
    CGFloat btnWidth = 60.f;
    CGFloat btnHeight = 26.f;
    CGFloat btnX = CGRectGetWidth(topView.bounds)-btnWidth-10;
    CGFloat btnY = CGRectGetHeight(topView.bounds)-btnHeight;
    orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    orderButton.layer.cornerRadius = 2.0f;
    [orderButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [orderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    orderButton.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
    CGPoint btnCentP = orderButton.center;
    btnCentP.y = centP.y;
    orderButton.center = btnCentP;
    [topView addSubview:orderButton];
    [self changeOrderButtonStatus];
    
    CGFloat stateH = [self StateBarHeight];
    CGRect viewRect = CGRectMake(0.f, stateH, kContentWidth, kContentHeight-stateH);
    _contentView = [[subsChannelContentView alloc] initWithFrame:viewRect];
    [[self view] addSubview:_contentView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_contentView reloadSubsChannel:_subsChannel];
    
    
    ThreadSummary *thread = [[ThreadsManager sharedInstance] getLastReadThread];
    if(thread)
        [_contentView setScrollOfThread:thread];
    //复位，防止从其他画面进入该页面时乱跳
    [[ThreadsManager sharedInstance] setLastReadThread:nil];
}

- (void)setSubsFromStyle:(SubsChannelFromStyle)subsStyle
{
    stl = subsStyle;
}

//改变订阅按钮的状态
- (void)changeOrderButtonStatus
{
    SubsChannelsManager *sm = [SubsChannelsManager sharedInstance];
    if ([sm channelSubsStatus:_subsChannel.channelId]) {
        if(style != SubsChannelSummaryDownload){
//            orderButton.backgroundColor = [UIColor colorWithHexString:@"999292"];//要求不需要背景色，需要时在加上
        }
        [orderButton setTitle:@"取消订阅" forState:UIControlStateNormal];
        [orderButton removeTarget:self action:@selector(addChannelSubs:) forControlEvents:UIControlEventTouchUpInside];
        [orderButton addTarget:self action:@selector(removeChannelSubs:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        if(style != SubsChannelSummaryDownload){
//            orderButton.backgroundColor = [UIColor colorWithHexString:@"AD2F2F"];//要求不需要背景色，需要时在加上
        }
        [orderButton setTitle:@"添加订阅" forState:UIControlStateNormal];
        [orderButton removeTarget:self action:@selector(removeChannelSubs:) forControlEvents:UIControlEventTouchUpInside];
        [orderButton addTarget:self action:@selector(addChannelSubs:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addChannelSubs:(id)sender
{
    SubsChannelsManager *sm = [SubsChannelsManager sharedInstance];
    if (style == SubsChannelSummaryDownload) {
        [sm addSubscription:_subsChannel];
        
        // 弹出风火轮
        [PhoneNotification manuallyHideWithText:@"提交订阅关系" indicator:YES];
        [sm commitChangesWithHandler:^(BOOL succeeded) {
            [PhoneNotification hideNotification];
            if (succeeded) {
                [self changeOrderButtonStatus];
                [PhoneNotification autoHideWithText:@"操作成功"];
            }
            else{
                [PhoneNotification autoHideWithText:@"操作失败"];
            }
        }];
    } else if (style == SubsChannelSummarySubs) {
        if ([sm isChannelReadyToUnsubscribed:_subsChannel.channelId]) {
            [sm removeChannelFromToUnsubs:_subsChannel];
        } else if (![sm isChannelSubscribed:_subsChannel.channelId]){
            [sm addSubscription:_subsChannel];
        }
        [sm commitChangesWithHandler:^(BOOL succeeded) {
            if (succeeded) {
                [self changeOrderButtonStatus];
            }
        }];
    }
}

- (void)removeChannelSubs:(id)sender
{
    SubsChannelsManager *sm = [SubsChannelsManager sharedInstance];
    if ([sm.visibleSubsChannels count] + [sm countOfToSubs] == 1) {
        [PhoneNotification autoHideWithText:@"您必须保留至少一个订阅栏目"];
        return;
    }
    
    if (style == SubsChannelSummaryDownload) {
        // 弹出风火轮
        [PhoneNotification manuallyHideWithText:@"提交订阅关系" indicator:YES];
        [sm removeSubscription:_subsChannel];
        [sm commitChangesWithHandler:^(BOOL succeeded) {
            [PhoneNotification hideNotification];
            if (succeeded) {
                [self changeOrderButtonStatus];
                [PhoneNotification autoHideWithText:@"操作成功"];
            }
            else{
                [PhoneNotification autoHideWithText:@"操作失败"];
            }
        }];
    } else if (style == SubsChannelSummarySubs) {
        if ([sm isChannelReadyToSubscribed:_subsChannel.channelId]) {
            [sm removeChannelFromToSubs:_subsChannel];
        } else if ([sm isChannelSubscribed:_subsChannel.channelId]){
            [sm removeSubscription:_subsChannel];
        }
        [sm commitChangesWithHandler:^(BOOL succeeded) {
            if (succeeded) {
                [self changeOrderButtonStatus];
            }
        }];
    }
}


-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    [_contentView viewNightModeChanged:night];
}
@end
