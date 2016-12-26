//
//  SearchChannelController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-6-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SearchChannelController.h"
#import "AppDelegate.h"
#define SearchViewHeight  45.0f
@interface SearchChannelController ()

@end

@implementation SearchChannelController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        searchResultArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    searchBoxViewY = 0.0f;
    if (IOS7) {
        searchBoxViewY = 15.0f;
    }
    searchBoxView = [[SearchBoxView alloc] initWithFrame:CGRectMake(0.0f, searchBoxViewY, kContentWidth, SearchViewHeight)];
    searchBoxView.delegate = self;
    [self.view addSubview:searchBoxView];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(320.f, searchBoxViewY + 2.0f, 67.0f, 39.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"cancel_search_channel"]
                          forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [backButton setTitleColor:[UIColor colorWithHexString:@"999292"]
                     forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didBack:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    CGRect subsViewRect = CGRectMake(0.0f, self.StateBarHeight,
                                     kContentWidth, kContentHeight - self.StateBarHeight);
    addSubscribeView = [[AddSubscribeView alloc] initWithFrame:subsViewRect search:YES];
    addSubscribeView.delegate = self;
    [self.view addSubview:addSubscribeView];
    
    [self nightModeChanged:[[ThemeMgr sharedInstance] isNightmode]];
    
    [self searchBoxViewAnimate];
    
    [self addBottomToolsBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [addSubscribeView loadSubsChannels:searchResultArray];
    
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    
    [notifyCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    isNightMode = night;
    [searchBoxView applyTheme:isNightMode];
    [addSubscribeView applyTheme:isNightMode];
}

- (void)searchBoxViewAnimate
{
    [UIView animateWithDuration:0.3f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         searchBoxView.frame = CGRectMake(0.0f, searchBoxViewY, 245.0f, 45.0f);
                         backButton.frame = CGRectMake(245.0f, searchBoxViewY + 2.0f, 67.0f, 39.0f);
                     }
                     completion:^(BOOL finished) {
                         [searchBoxView popupKeyboard];
                     }];
}

- (void)didBack:(id)sender
{
    //先隐藏键盘
    [searchBoxView hideKeyboard];
    
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

#pragma mark SearchBoxViewDelegate methods
- (void)doSearchAction:(NSString *)searchText showNotification:(BOOL)show
{
    addSubscribeView.showAllResult = NO;
    searchText_ = searchText;
    page = 1;
    
    if (!searchText || [searchText isEmptyOrBlank]) {
        [searchResultArray removeAllObjects];
        [addSubscribeView showTableFooterView:NO];
        [addSubscribeView loadSubsChannels:searchResultArray];
        return;
    }
    
    [searchResultArray removeAllObjects];
    
    @try {
        //SYZ -- 2014/08/11
        //不区分大小写
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchText];
        //区分大小写
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", searchText];
        NSArray *resultArray = [_allChannelsArray filteredArrayUsingPredicate:predicate];
        
        //去重操作
        for (SubsChannel *subs1 in resultArray) {
            bool isEquel = NO;
            for (SubsChannel *subs2 in searchResultArray) {
                if (subs1.channelId == subs2.channelId) {
                    isEquel = YES;
                }
            }
            if (!isEquel) {
                [searchResultArray addObject:subs1];
            }
        }
        
        if ([searchResultArray count] == 0 && show) {
            [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"非常抱歉,没有找到与\"%@\"相关的结果", searchText]];
            return;
        }
        [addSubscribeView showTableFooterView:YES];
        [addSubscribeView loadSubsChannels:searchResultArray];
        [addSubscribeView applyTheme:isNightMode];
    } @catch (NSException *exc) {
        [searchResultArray removeAllObjects];
        [addSubscribeView showTableFooterView:NO];
    }
}

- (void)doWebSearchAction:(NSString *)searchText
{
    if (!searchText || [searchText isEmptyOrBlank]) {
        [searchResultArray removeAllObjects];
        [addSubscribeView showTableFooterView:NO];
        [addSubscribeView loadSubsChannels:searchResultArray];
        return;
    }
    
    [searchResultArray removeAllObjects];
    
    [self loadMore];
}

#pragma mark AddSubscribeViewDelegate methods
- (void)channelSelected:(SubsChannel *)channel
{
    SubsChannelSummaryViewController *summaryController = [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummarySubs];
    [summaryController setSubsChannel:channel];
    [self presentController:summaryController
                   animated:PresentAnimatedStateFromRight];
}

- (void)searchSubsChannelByName
{
    if (isLoading) {
        return;
    }
    isLoading = YES;
    [PhoneNotification manuallyHideWithText:@"搜索中..." indicator:YES];
    [[SubsChannelsManager sharedInstance] loadSearchedSubsChannels:searchText_ page:page withCompletionHandler:^(BOOL success, NSArray *channels) {
        if (success) {
            if (channels) {
                if (page == 1) {
                    [searchResultArray removeAllObjects];
                }
                [searchResultArray addObjectsFromArray:channels];
                [addSubscribeView loadSubsChannels:searchResultArray];
                page ++;
                [addSubscribeView showTableFooterView:NO];
                [PhoneNotification hideNotification];
            } else {
                [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"非常抱歉,没有找到与\"%@\"相关的结果", searchText_]];
            }
        } else {
            [PhoneNotification autoHideWithText:@"网络请求错误,请重试"];
        }
        isLoading = NO;
    }];
}

- (void)loadMore
{
    [self searchSubsChannelByName];
}

- (void)viewScrolled
{
    if(addSubscribeView.frame.size.height < kContentHeight - self.StateBarHeight){
        [searchBoxView hideKeyboard];
    }
}

#pragma mark Observer methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (keyboardShowing) {
        return;
    }
    
    [super addMiniKeyBoard];
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (!keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect subsViewRect = CGRectMake(0.0f, self.StateBarHeight,
                                                              kContentWidth, kContentHeight - self.StateBarHeight - height);
                             addSubscribeView.frame = subsViewRect;
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y -= height;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = YES;

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!keyboardShowing){
        return;
    }

    [super dismissMiniKeyBoard];
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect subsViewRect = CGRectMake(0.0f, self.StateBarHeight,
                                                              kContentWidth, kContentHeight - self.StateBarHeight);
                             addSubscribeView.frame = subsViewRect;
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y += height;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = NO;
}

-(void)keyboardWillChangeFrame:(NSNotification*)notification
{
    if (!keyboardShowing) {
        return;
    }
    
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float btnW = CGRectGetWidth(toolsBottomBar.bounds);
    float btnH = CGRectGetHeight(toolsBottomBar.bounds);
    float btnY = kContentHeight - endRect.size.height - btnH;
    float btnX = endRect.origin.x + CGRectGetWidth(endRect) - btnW;
    toolsBottomBar.frame = CGRectMake(btnX, btnY, btnW, btnH);
}

- (void)dismissKeyboard:(id)sender
{
    [searchBoxView hideKeyboard];
}

@end
