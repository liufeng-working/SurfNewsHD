//
//  HotRootController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotRootController.h"
#import "GTMHTTPFetcher.h"
#import "EzJsonParser.h"
#import "ThreadsManager.h"
#import "AppDelegate.h"
#import "ReadNewsController.h"
#import "NSString+Extensions.h"


#define TopRefreshDateSpace 1

@implementation HotChannelItemView

@synthesize hotChannal;

- (id)initWithFrame:(CGRect)frame controller:(id)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = controller;
        
        selectedImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        selectedImageView.image = nil;
        [self addSubview:selectedImageView];
        
        channelItemLabel = [[UILabel alloc] initWithFrame:self.bounds];
        channelItemLabel.backgroundColor = [UIColor clearColor];
        channelItemLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        channelItemLabel.textColor = [UIColor blackColor];
        channelItemLabel.textAlignment = UITextAlignmentCenter;
        channelItemLabel.shadowColor = [UIColor whiteColor];
        channelItemLabel.shadowOffset = CGSizeMake(0, -1.0);
        [self addSubview:channelItemLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(channelItemDidTap:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setHotChannal:(HotChannel *)theHotchannel
{
    hotChannal = theHotchannel;
    channelItemLabel.text = hotChannal.name;
}

- (void)channelItemDidTap:(UITapGestureRecognizer*)gestureRecognizer
{
    [self.delegate channelItemDidSelected:hotChannal];
}

- (void)setItemSelected
{
    selectedImageView.image = [UIImage imageNamed:@"hotchannel_selected"];
    channelItemLabel.shadowColor = [UIColor whiteColor];
    channelItemLabel.shadowOffset = CGSizeMake(0.0, -1.0);
}

- (void)setItemUnselected
{
    selectedImageView.image = nil;
    channelItemLabel.shadowColor = nil;
    channelItemLabel.shadowOffset = CGSizeMake(0.0, 0.0);
}

@end

@implementation HotChannelScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//        scrollView.bounces = NO;
        scrollView.tag = 1000;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
    }
    return self;
}

- (void)reloadViewWithArray:(NSArray*)array controller:(id)controller
{
    for (UIView *view in [scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < [array count]; i ++) {
        HotChannelItemView *itemView = [[HotChannelItemView alloc] initWithFrame:CGRectMake(96.0f * i, 0.0f, 96.0f, 29.0f)
                                                                       controller:controller];
        itemView.hotChannal = [array objectAtIndex:i];
        itemView.tag = i;
        [scrollView addSubview:itemView];
    }
    
    //22.0f是最后会被盖住的宽度
    [scrollView setContentSize:CGSizeMake(96.0f * [array count] + 22.0f, 29.0f)];
}

- (void)setSelectedImageWithTag:(NSInteger)tag
{
    for (HotChannelItemView *view in [scrollView subviews]) {
        if (view.tag == tag) {
            [view setItemSelected];
        } else {
            [view setItemUnselected];
        }
    }
}

@end

@interface HotRootController ()

@end

@implementation HotRootController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.titleState = ViewTitleStateNormal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *titleLineTopView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 39.0f, kContentWidth, 2)];
    titleLineTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hotchannel_item_border"]];
    [self.view addSubview:titleLineTopView];
    
    headerScrollView = [[HotChannelScrollView alloc] initWithFrame:CGRectMake(0.0f, 39.0f, 96.0f * 9, 29.0f)];
    [self.view addSubview:headerScrollView];
    UIImageView *endView = [[UIImageView alloc] initWithFrame:CGRectMake(96.0f * 9 - 28.0f, 2.0f, 38.0f, 27.0f)];
    [endView setImage:[UIImage imageNamed:@"hot_channel_scrollview_end"]];
    [headerScrollView addSubview:endView];
    
    operateGridViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [operateGridViewButton setBackgroundImage:[UIImage imageNamed:@"hotchannel_expand"]
                                     forState:UIControlStateNormal];
    [operateGridViewButton setBackgroundImage:[UIImage imageNamed:@"hotchannel_expand"]
                                     forState:UIControlStateHighlighted];
    operateGridViewButton.frame = CGRectMake(1024 - kSplitDividerWidth - kSplitPositionMin - 70.0f, 2.0f, 60.0f, 65.0f);
    [operateGridViewButton addTarget:self
                              action:@selector(operateHotChannel:)
                    forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragInside];

    
    gridView = [[HotChannelGridView alloc] init];
    gridView.hidden = YES;
    gridView.delegate = self;
    gridView.dataSource = self;
    gridView.cellHorizontalSpacing = 25.0f;
    gridView.cellVerticalSpacing = 10.0f;
    gridView.widthOfView = 870.0f;
    gridView.edgeInsets = UIEdgeInsetsMake(10.0f, 20.0f, 15.0f, 0.0f);
    gridView.cellCountPerRow = 9;
//    [self.view addSubview:gridView];

    
    CGRect tempRect = CGRectMake(0.0f, kPaperTopY, kPaperLeftWidth, kContentHeight-kPaperTopY-kPaperBottomY);
    leftNewsView =[[HotChannelsView alloc] initWithFrame:tempRect];
    leftNewsView.delegate = self;
    leftNewsView.refreshDelegate = self;
    [self.view addSubview:leftNewsView];
    
    tempRect.origin.x += tempRect.size.width + kPaperWhiteWidth;
    tempRect.size.width = kHotInformationWidth;

    rightNewsView =[[HotInfomationInChannelView alloc] initWithFrame:tempRect];
    [rightNewsView setReadThreadDelegate:self];
    [rightNewsView setRefreshDelegate:self];    
    [self.view addSubview:rightNewsView];
    [self.view addSubview:gridView];
    [self.view addSubview:operateGridViewButton];
    
    // 频道详情数组
    threads = [NSMutableArray arrayWithCapacity:20];
    
    // 请求频道列表
    [self requestHotChannelsList];
    // hotChannelsList
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults floatForKey:kWeather_Guide])
    {
        weather_Guide = [UIButton buttonWithType:UIButtonTypeCustom];
        [weather_Guide setBackgroundImage:[UIImage imageNamed:@"weather_Guide"]
                                 forState:UIControlStateNormal];
        weather_Guide.frame = CGRectMake(tempRect.origin.x - 60.0f, 0, 350.0f, 230.0f);
        [weather_Guide addTarget:self action:@selector(hiddenWeather_Guide)
                forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:weather_Guide];
        [defaults setBool:YES forKey:kWeather_Guide];
        [defaults synchronize];
    }

    
}
-(void)hiddenWeather_Guide
{
    //隐藏天气引导
    [weather_Guide removeFromSuperview];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self foldHotChannels];
    
    
    // 添加夜间模式
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    [mgr registerNightmodeChangedNotification:self];
    
    
    if (currentHotChannel == nil) {
        [self requestHotChannelsList];
        return;
    }
    
    // 需要刷新数据，防止数据在其它的界面刷新。
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if (currentHotChannel != nil && leftNewsView != nil) {
        BOOL isRefresh = NO;
        NSArray *tempArray = [tm getLocalThreadsForHotChannel:currentHotChannel];        
        
        if ([tempArray count] != [threads count]) {
            isRefresh = YES;
        }
        else if([threads count] > 0){
            id obj = [threads objectAtIndex:0];
            if ([tempArray indexOfObject:obj] != 0) {
                 isRefresh = YES;
            }
        }        
        
        if (isRefresh) {
            [threads removeAllObjects];
            [threads addObjectsFromArray:tempArray];
            NSDate *date = [tm lastRefreshDateOfHotChannel:currentHotChannel];
            [leftNewsView reloadChannels:currentHotChannel array:threads date:date];
        }
    }
    // 刷新频道的热门资讯
    if (currentSubsChannel != nil && rightNewsView != nil){
        NSArray *tempArray = [tm getLocalThreadsForSubsChannel:currentSubsChannel];
        NSDate *date = [tm lastRefreshDateOfSubsChannel:currentSubsChannel];
        [rightNewsView loadHotInfomationWithArray:tempArray updateTime:date];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // 取消注册夜间模式
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    [mgr unregisterNightmodeChangedNotification:self];
}
#pragma mark - 

// 请求频道列表
-(void)requestHotChannelsList
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];

    if ([manager.visibleHotChannels count]>0) {
        [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
        [headerScrollView setSelectedImageWithTag:0];
        currentHotChannel = [manager.visibleHotChannels objectAtIndex:0]; //默认刚启动的是热推频道
        [self requestHotChannels:currentHotChannel];
        [self requestHotInfomation:currentHotChannel];
    }
    [manager refreshWithCompletionHandler:^(BOOL succeeded,BOOL noChanges) {
        if (succeeded && !noChanges) {
            [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
            [headerScrollView setSelectedImageWithTag:0];
            currentHotChannel = [manager.visibleHotChannels objectAtIndex:0];
            [self requestHotChannels:currentHotChannel];
            [self requestHotInfomation:currentHotChannel];
        }
    }];
}

// 请求频道详情
-(void)requestHotChannels:(HotChannel *)channel
{
    // 检测是否需要刷新，如何正在刷新，就取消刷新
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if(channel == nil || [tm isHotChannelInRefreshing:self hotChannel:channel])
        return;    
    
    BOOL isLoading = NO;
    // 帖子管理器, 删除旧数据, 加载缓存数据
    [threads removeAllObjects];
    [threads addObjectsFromArray:[tm getLocalThreadsForHotChannel:channel]];
    NSDate* updateTime = [tm lastRefreshDateOfHotChannel:channel];      // 最后刷新时间
    [leftNewsView reloadChannels:channel array:threads date:updateTime];// 加载旧数据
    
    if (updateTime == nil) {
        isLoading = YES;
    }
    else{
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
        NSDateComponents *dateComponents = [calendar components:flags fromDate:updateTime toDate:[NSDate date] options:0];
        
        if (dateComponents.minute > TopRefreshDateSpace || dateComponents.hour != 0 ||
            dateComponents.day != 0 || dateComponents.month != 0 || dateComponents.year != 0 ) {
            isLoading = YES;
        }
    }
    
    // 开始加载数据
    if (isLoading) {
        [leftNewsView setLoadingState]; // 设置加载状态
        // 刷新频道详情
        [tm refreshHotChannel:self hotChannel:channel withCompletionHandler:^(ThreadsFetchingResult* result){
            if (result.channelId == currentHotChannel.channelId &&
                [result succeeded] && ![result noChanges]) {
                [threads removeAllObjects]; // 删除旧数据
                NSDate* update = [tm lastRefreshDateOfHotChannel:channel];
                [threads addObjectsFromArray:[result threads]];
                [leftNewsView reloadChannels:channel array:threads date:update];
            }
            
            // 这个顺序必须在reloadChannels 函数之后执行
            [leftNewsView cancelLoadingState];
        }];
    }
}

// 请求频道中的热门资讯
- (void)requestHotInfomation:(HotChannel *)channel{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    SubsChannel *subsChannel = [tm getAboutHotChannel:channel];//获取相关热门资讯
    if (subsChannel != nil) {
        currentSubsChannel = subsChannel;
        NSArray *localThreads = [tm getLocalThreadsForSubsChannel:subsChannel];
        if ([localThreads count]>0) {
            NSDate* update = [tm lastRefreshDateOfSubsChannel:currentSubsChannel];
            [rightNewsView loadHotInfomationWithArray:localThreads updateTime:update];
        }else{
            [rightNewsView loadHotInfomationWithArray:nil updateTime:nil];
        }
        
        
        if([tm isSubsChannelInGettingMore:subsChannel]){
            return;
        }
        if([tm isSubsChannelInRefreshing:subsChannel]){
            [tm cancelRefreshSubsChannel:self subsChannel:subsChannel];
        }
        
        [tm refreshSubsChannel:self subsChannel:subsChannel withCompletionHandler:^(ThreadsFetchingResult * result)
         {
             NSDate* update = [tm lastRefreshDateOfSubsChannel:currentSubsChannel];
             [rightNewsView cancelLoading];
             if (result.succeeded && [result.threads count] > 0) {
                 [rightNewsView loadHotInfomationWithArray:result.threads updateTime:update];
             }
         }];
    }
}


#pragma mark - ReadThreadContentDelegate
- (void)readThreadContent:(id)sender
            threadSummary:(ThreadSummary *)thread
{
    if (sender == nil || thread == nil)  return;
    
    if (![thread isUrlOpen]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        ReadNewsController *viewController = [[ReadNewsController alloc] init];
        viewController.webUrl = [thread.newsUrl completeUrl];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.modalPresentationStyle = UIModalPresentationCurrentContext;
        UIViewController *rootController = appDelegate.window.rootViewController;
        [rootController presentModalViewController:nav animated:YES];
    }
    else
    {
        NewsWebController *viewController = [[NewsWebController alloc] init];
        if (sender == leftNewsView) {
            viewController.hotChannel = currentHotChannel;
            viewController.webStyle = NewsWebrStyleHot;
        }
        else if (sender == rightNewsView){
            viewController.subsChannel = currentSubsChannel;
            viewController.webStyle = NewsWebrStyleSubs;
        }

        viewController.currentThread = thread;
        viewController.title = [NSString stringWithFormat:@"冲浪%@",currentHotChannel.name];
        [self pushViewController:viewController animated:YES];
    }
}


#pragma mark HotChannelItemViewDelegate methods
- (void)channelItemDidSelected:(HotChannel *)channel
{
    if (channel == currentHotChannel) {//再次选择当前频道,不做操作
        return;
    }
    
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSInteger index = [manager.visibleHotChannels indexOfObject:channel];
    [headerScrollView setSelectedImageWithTag:index];
    currentHotChannel = channel;
    [self requestHotChannels:channel];  // 请求频道
    [self requestHotInfomation:channel];// 请求频道的热门资讯
}



#pragma mark LoadContentDelegate
// 刷新频道内容
- (void)refreshContent:(id)sender{    
    ThreadsManager *tm = [ThreadsManager sharedInstance]; // 帖子管理器
    if (sender == leftNewsView) {
        if([tm isHotChannelInRefreshing:self hotChannel:currentHotChannel] ||
           [tm isHotChannelInGettingMore:self hotChannel:currentHotChannel]){
            [leftNewsView cancelLoadingState];
        }
        else{
            // 请求刷新热门帖子
            [tm refreshHotChannel:self hotChannel:currentHotChannel withCompletionHandler:^(ThreadsFetchingResult* result){
                if (currentHotChannel.channelId == result.channelId && [result succeeded])
                {
                    NSDate* update = [tm lastRefreshDateOfHotChannel:currentHotChannel];
                    if(![result noChanges]){
                        [threads removeAllObjects]; // 删除旧的频道详情                       
                        [threads addObjectsFromArray:[result threads]];
                        [leftNewsView reloadChannels:currentHotChannel array:threads date:update];
                    }
                    else{
                        // 提示数据是最新的
                        [leftNewsView updateRefreshDate:update];
                        [SurfNotification surfNotification:@"现在是最新数据"];
                    }
                } else
                {
                    [SurfNotification surfNotification:@"网络异常!"];
                }
                [leftNewsView cancelLoadingState];
            }];
        }   
    }
    else if (sender == rightNewsView){
        if([tm isSubsChannelInRefreshing:currentSubsChannel] ||
           [tm isSubsChannelInGettingMore:currentSubsChannel]){
            [rightNewsView cancelLoading];
        }
        else{
            [tm refreshSubsChannel:self subsChannel:currentSubsChannel withCompletionHandler:^(ThreadsFetchingResult* result){
                [rightNewsView cancelLoading];
                if (currentSubsChannel.channelId == result.channelId && [result succeeded])
                {
                    NSDate* update = [tm lastRefreshDateOfSubsChannel:currentSubsChannel];
                    if(![result noChanges]){                        
                        [rightNewsView loadHotInfomationWithArray:[result threads] updateTime:update];
                    }
                    else{
                        // 提示数据是最新的
                        [rightNewsView updateRefreshDate:update];
                        [SurfNotification surfNotification:@"现在是最新数据"];
                    }
                }
                else
                {
                    [SurfNotification surfNotification:@"网络异常!"];
                }
            }];
        }
    }
}

// 加载更多频道内容
- (void)loadMoreContent:(id)sender
{
    if (sender == nil) { return; }
    
    // 帖子管理器
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if (sender == leftNewsView) {
        if ([tm isHotChannelInRefreshing:self hotChannel:currentHotChannel] ||
            [tm isHotChannelInGettingMore:self hotChannel:currentHotChannel]) {
            [leftNewsView cancelLoadingState];
        }
        else{
            [tm getMoreForHotChannel:self hotChannel:currentHotChannel
               withCompletionHandler:^(ThreadsFetchingResult *result)
            {
                if (currentHotChannel.channelId == result.channelId && [result succeeded])
                {
                    NSDate* update = [tm lastGetMoreDateOfHotChannel:currentHotChannel];
                    if (![result noChanges]) {
                        [threads addObjectsFromArray:[result threads]];
                        [leftNewsView moreChannels:currentHotChannel array:[result threads] date:update];
                    }else{
                        [leftNewsView updateMoreDate:update];
                        [SurfNotification surfNotification:@"现在没有更多数据"];
                    }
                }
                [leftNewsView cancelLoadingState]; 
            }];
        }
    }   
    else if (sender == rightNewsView){
        ThreadsManager *tm = [ThreadsManager sharedInstance];
        if ([tm isSubsChannelInRefreshing:currentSubsChannel]||
            [tm isSubsChannelInGettingMore:currentSubsChannel]) {
            [rightNewsView cancelLoading];
        }
        else{
            [tm getMoreForSubsChannel:self subsChannel:currentSubsChannel withCompletionHandler:^(ThreadsFetchingResult *result)
             {
                 if (currentSubsChannel.channelId == result.channelId && [result succeeded])
                 {
                     NSDate* update = [tm lastGetMoreDateOfSubsChannel:currentSubsChannel];
                     if (![result noChanges]) {                         
                         [rightNewsView loadMoreThreadsSummary:[result threads] updateTime:update];
                     }else{
                         [rightNewsView updateMoreDate:update];
                         [SurfNotification surfNotification:@"现在没有更多数据"];
                     }
                 }
                 [rightNewsView cancelLoading];
             }];
        }        
    }
}


-(void)pushByLayerDown
{
    float height = 120.0f;
    headerScrollView.hidden = YES;
    [UIView animateWithDuration:0.5f animations:^{    
        rightNewsView.frame =
        CGRectMake(rightNewsView.frame.origin.x, rightNewsView.frame.origin.y + height, rightNewsView.frame.size.width, rightNewsView.frame.size.height);
        leftNewsView.frame =
        CGRectMake(leftNewsView.frame.origin.x, leftNewsView.frame.origin.y + height, leftNewsView.frame.size.width, leftNewsView.frame.size.height);
        
    } completion:^(BOOL finished) {
        rightNewsView.userInteractionEnabled = NO;
    }];
}

#pragma mark HotChannelGridViewDataSource methods
- (NSMutableArray*)arrayOfInvisibleCell
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    return manager.invisibleHotChannels;
}

- (NSMutableArray*)arrayOfVisibleCell
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    return manager.visibleHotChannels;
}

- (CGSize)sizeForCell
{
    return CGSizeMake(70, 30);
}

- (HotChannelGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    
    CGSize cellSize = [self sizeForCell];
    HotChannelGridViewCell *cell = [[HotChannelGridViewCell alloc] init];
    cell.frame = CGRectMake(0.0f, 0.0f, cellSize.width, cellSize.height);
    
    if (indexPath.section == 0) {
        cell.hotChannel = [manager.invisibleHotChannels objectAtIndex:indexPath.row];
        [cell setCellBackground:@"invisible_hot_channel" textColor:@"B4CBD3"];
    } else if (indexPath.section == 1) {
        cell.hotChannel = [manager.visibleHotChannels objectAtIndex:indexPath.row];
        [cell setCellBackground:@"visible_hot_channel" textColor:@"000000"];
    }
    
    return cell;
}

#pragma mark HotChannelGridViewDelegate methods
- (void)removeCurrentHotChannel:(HotChannel *)channel
{
    if (channel == currentHotChannel) {//如果移除当前频道
        HotChannelsManager *manager = [HotChannelsManager sharedInstance];
        currentHotChannel = [manager.visibleHotChannels objectAtIndex:0];
        [self requestHotChannels:currentHotChannel];
    }
}

- (void)operateHotChannel:(UIButton*)button
{
    [gridView reloadView];
    
    operateGridViewButton.hidden = YES;
    headerScrollView.hidden = YES;
    gridView.hidden = NO;
    gridView.frame = CGRectMake(0.0f, 9.0f, 887.0f, gridView.heightOfView);
}

//隐藏gridview
- (void)foldHotChannels
{
    gridView.hidden = YES;
    operateGridViewButton.hidden = NO;
    headerScrollView.hidden = NO;
    
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
    NSInteger index = [manager.visibleHotChannels indexOfObject:currentHotChannel];
    [headerScrollView setSelectedImageWithTag:index];
}


#pragma mark NightModeChangedDelegate
-(void)nightModeChanged:(BOOL)night{

}
@end
