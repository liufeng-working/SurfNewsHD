 //
//  HotChannelsScrollView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelsScrollScreenView.h"
#import "HotChannelsView.h"
#import "HotChannelsManager.h"
#import "ThreadsManager.h"
#import "UIView+NightMode.h"
#import "HotChannelsListResponse.h"
#import "PhoneHotRootcontroller.h"
#import "PhoneReadController.h"
#import "PhotoCollectionContentController.h"
#import "PhotoCollectionManager.h"
#import "PhotoCollectionData.h"
#import "WebPeriodicalController.h"
#import "NotificationManager.h"
#import "UIFloatingViewController.h"
#import "RealTimeStatisticsRequest.h"
#import "SNNewsCommentViewController.h"


#define TopRefreshDateSpace 15

@interface HotChannelsScrollScreenView () {
    HotChannelsView *_oneView;
    HotChannelsView *_twoView;
    HotChannelsView *_threeView;
    NSUInteger _curHotChannelIndex;
    HotChannel* stockChannel;
}
@end


@implementation HotChannelsScrollScreenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.bounces = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3.f, self.bounds.size.height);
        [self addSubview:_scrollView];
        
        
        CGRect viewRect = self.bounds;
        _oneView =[[HotChannelsView alloc] initWithFrame:viewRect];
        _oneView.delegate = self;
        _oneView.refreshDelegate = self;
        [_scrollView addSubview:_oneView];
        
        viewRect.origin.x += viewRect.size.width;
        _twoView = [[HotChannelsView alloc] initWithFrame:viewRect];
        _twoView.delegate = self;
        _twoView.refreshDelegate = self;
        [_scrollView addSubview:_twoView];
        
        viewRect.origin.x += viewRect.size.width;
        _threeView = [[HotChannelsView alloc] initWithFrame:viewRect];
        _threeView.delegate = self;
        _threeView.refreshDelegate = self;
        [_scrollView addSubview:_threeView];
        
        _curHotChannelIndex = 0;
    }
    return self;
}

- (void)reloadHotChannels:(BOOL)isTop
  isReloadEqualHotchannel:(BOOL)isEqualHotChannel
{
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
    NSUInteger hotCount = hcm.visibleHotChannels.count;
    if (hotCount < 3)
        return;
    if (isTop) {
        for (HotChannel *hc in hcm.visibleHotChannels) {
            hc.listScrollOffsetY = 0;
        }
    }
    
    if (_curHotChannelIndex >= hotCount) {
        _curHotChannelIndex = 0;
    }
  
    NSUInteger idx1=0,idx2=0,idx3=0;
    if (_curHotChannelIndex == 0) {
        idx1 = _curHotChannelIndex;
        idx2 = _curHotChannelIndex + 1;
        idx3 = _curHotChannelIndex + 2;
        _scrollView.contentOffset = CGPointZero;
    }
    else if(_curHotChannelIndex == hotCount-1){
        idx1 = _curHotChannelIndex - 2;
        idx2 = _curHotChannelIndex - 1;
        idx3 = _curHotChannelIndex;
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds)*2.f, 0.f);
    }
    else{
        idx1 = _curHotChannelIndex -1;
        idx2 = _curHotChannelIndex;
        idx3 = _curHotChannelIndex + 1;
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds), 0.f);
    }

    HotChannel *hot1 = hcm.visibleHotChannels[idx1];
    HotChannel *hot2 = hcm.visibleHotChannels[idx2];
    HotChannel *hot3 = hcm.visibleHotChannels[idx3];
    
    _oneView.tag = idx1;
    _twoView.tag = idx2;
    _threeView.tag = idx3;
    
    
    if (_twoView.hotChannel.channelId != hot2.channelId ||
        isEqualHotChannel) {
        [self reloadSubViewDate:_twoView hotChannel:hot2];
    }
    if (_oneView.hotChannel.channelId != hot1.channelId ||
        isEqualHotChannel) {
        [self reloadSubViewDate:_oneView hotChannel:hot1];
    }
    if (_threeView.hotChannel.channelId != hot3.channelId || isEqualHotChannel) {
         [self reloadSubViewDate:_threeView hotChannel:hot3];
    }
}

// 设置当前显示的热门帖子内容
- (void)setCurrentHotChannel:(HotChannel*)hotchannel{
    if (hotchannel == nil)
        return;
    
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
    NSUInteger idex = [hcm.visibleHotChannels indexOfObject:hotchannel];
    if (idex != NSNotFound) {
        _curHotChannelIndex = idex;
        [self reloadHotChannels:NO isReloadEqualHotchannel:NO];
    }
}

// 给一个子屏幕加载数据
-(void)reloadSubViewDate:(HotChannelsView*)hotView
              hotChannel:(HotChannel*)hotCnl
{
    // 先加载本地数据
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    NSDate *refreshDate = [tm lastRefreshDateOfHotChannel:hotCnl];
    NSArray *threads = [tm getLocalThreadsForHotChannel:hotCnl];
    
    // 加载数据
    [hotView reloadChannels:hotCnl array:threads date:refreshDate];
    
    // 滑动到上次用户浏览的大概位置
    [hotView setScrollOffsetY:hotCnl.listScrollOffsetY];
    
    
    // 更新时间大于我们设定的时间段，就更新    
    NSDate *lastDate = [tm lastRefreshDateOfHotChannel:hotCnl];
    BOOL isLoad = (lastDate == nil) ? YES : NO;
    if (!isLoad){
        NSTimeInterval timeInterval =
        [[NSDate date] timeIntervalSinceDate:lastDate];
        NSInteger minute = ((NSInteger)timeInterval)/60;
        if (minute > TopRefreshDateSpace) {
            isLoad = YES;
        }
    }
    
    if (isLoad) {
        [hotView setLoadingState:NO];
        [self refreshNewList:hotCnl]; // 刷新新闻列表
    }
}


-(HotChannelsView*)curHotChannelsView
{
    CGFloat width = CGRectGetWidth(_scrollView.bounds);
    NSInteger viewIndex = floor((_scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    if (viewIndex == 0)
        return _oneView;
    else if (viewIndex == 1)
        return _twoView;
    else if (viewIndex == 2)
        return _threeView;
    return nil;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollBeginX = scrollView.contentOffset.x;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if ([scrollView isDragging] || [scrollView isDecelerating]) {
        CGFloat width = CGRectGetWidth(scrollView.bounds);
        CGFloat endX = scrollView.contentOffset.x;
        CGFloat percent = (endX - _scrollBeginX) / width;
        [_hotChannelChangedDelegate headerViewScrollPercent:percent];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    NSStringFromCGPoint(targetContentOffset);
//    DJLog();
}

// 滚动窗口滑动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat width = CGRectGetWidth([scrollView bounds]);
    NSInteger viewIndex = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    if (viewIndex == 0) {
        if (_curHotChannelIndex != _oneView.tag) {
            _curHotChannelIndex = _oneView.tag;
            [self pageMoveToRight:scrollView];
            [self notifyHotChannelChanged];
        }       
    }
    else if (viewIndex == 2) {
        if (_curHotChannelIndex != _threeView.tag) {
            _curHotChannelIndex = _threeView.tag;
            [self pageMoveToLeft:scrollView];
            [self notifyHotChannelChanged];
        }        
    }
    else{
        if (_curHotChannelIndex != _twoView.tag) {
            _curHotChannelIndex = _twoView.tag;
            [self notifyHotChannelChanged];
        }
    }
}

-(void)notifyHotChannelChanged{
    if ([_hotChannelChangedDelegate respondsToSelector:@selector(hotchannelScrollChanged:)]) {
        HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
        HotChannel *hotchannel = [hcm.visibleHotChannels objectAtIndex:_curHotChannelIndex];
        if (hotchannel) {
            [_hotChannelChangedDelegate hotchannelScrollChanged:hotchannel];
        }
    }
}

-(NSUInteger)snThreadsCount
{
    return [[[ThreadsManager sharedInstance] getLocalThreadsForHotChannelId:4061] count];
}
-(ThreadSummary*)snThreadAtIndex:(NSInteger)idx
{
    return [[[ThreadsManager sharedInstance] getLocalThreadsForHotChannelId:4061] objectAtIndex:idx];
}
-(NSUInteger)snIndexOfThread:(ThreadSummary*)t
{
    return [[[ThreadsManager sharedInstance] getLocalThreadsForHotChannelId:4061] indexOfObject:t];
}

- (void)readThreadContent:(id)sender
            threadSummary:(ThreadSummary *)thread
{
    if (sender == nil || thread == nil)  return;
    
    PhoneSurfController *psc = [self findUserObject:[PhoneSurfController class]];
    if (![psc isKindOfClass:[PhoneSurfController class]]) {
        return;
    }
    
    // 新增段子频道
    if ([[self curHotChannelsView].hotChannel isJokeChannel]) {
        RealTimeStatisticType rtsType = kRTS_NewsList_TextNews;
        if (thread.webView == 1) {
            rtsType = kRTS_NewsList_UrlNews;
        }
        [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:thread andWithType:rtsType and:nil];
        
        SNThreadViewerController* vc = [[SNThreadViewerController alloc] initWithThread:thread];
        
        HotChannelsView *hotView = (HotChannelsView *)sender;
        // 如果cell上点击了评论
        if (hotView.commented) {
            // 展示评论界面
            if (!thread) return;
            SNNewsCommentViewController *newsComment =
            [SNNewsCommentViewController new];
            newsComment.thread = thread;
            [psc presentController:newsComment animated:PresentAnimatedStateFromRight];
            
            hotView.commented = NO;
            return;
        }
        
        // 展示段子正文界面
        [psc presentController:vc
                      animated:PresentAnimatedStateFromRight];
        [self.hotChannelChangedDelegate disapperPresentController];
        
        // 如果cell上点击了分享
        if (hotView.shared) {
            // 展示分享
            [vc performSelector:@selector(toolBarActionShare:) withObject:thread afterDelay:0.5f];
            hotView.shared = NO;
        }
        
        return;
    }
    
    if ([[self curHotChannelsView].hotChannel isBeautifulChannel]) {
        [[RealTimeStatisticsManager sharedInstance] sendRealTimeBelleGirlActionStatistics:thread andWithType:kBelleGirl_Click and:^(BOOL succeeded) {
            
        }];
        
        PhoneBelleGirlViewController *belleGirlViewCrl = [PhoneBelleGirlViewController new];
        belleGirlViewCrl.thread = thread;
        [psc presentController:belleGirlViewCrl animated:PresentAnimatedStateFromRight];
        [self.hotChannelChangedDelegate disapperPresentController];
    }
    else {

        RealTimeStatisticType rtsType = kRTS_NewsList_TextNews;
        if (thread.webView == 1) {
            rtsType = kRTS_NewsList_UrlNews;
        }
        [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:thread andWithType:rtsType and:nil];
        
        
        SNThreadViewerController* vc = [[SNThreadViewerController alloc] initWithThread:thread];
        [psc presentController:vc
                      animated:PresentAnimatedStateFromRight];
        [self.hotChannelChangedDelegate disapperPresentController];
    }
}

-(void)addStockUrlWithTag:(stockTag)tag
{
    if ([_hotChannelChangedDelegate respondsToSelector:@selector(addStockWebUrlWithTag:)]) {
        [_hotChannelChangedDelegate addStockWebUrlWithTag:tag];
    }
}


#pragma mark LoadContentDelegate
// 回调函数刷新频道内容
- (void)refreshContent:(id)sender
{
    if ([sender isKindOfClass:[HotChannelsView class]]) {

        [self refreshNewList:[(HotChannelsView*)sender hotChannel]];
    }
}

// 加载更过频道内容
- (void)loadMoreContent:(id)sender
{
    if (![sender isKindOfClass:[HotChannelsView class]]) {
        return;
    }
    
    HotChannelsView *hotView = sender;
    ThreadsManager *tm = [ThreadsManager sharedInstance]; // 帖子管理器
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
    HotChannel *hotChannel = hcm.visibleHotChannels[hotView.tag];
    
    
    if (![tm isHotChannelInRefreshing:self hotChannel:hotChannel] &&
        ![tm isHotChannelInGettingMore:self hotChannel:hotChannel])
    {
        [tm getMoreForHotChannel:self
                      hotChannel:hotChannel
           withCompletionHandler:^(ThreadsFetchingResult *result)
         {
             HotChannel *hotchannel = nil;
             HotChannelsView *hotView = nil;
             HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
             
             id hot1 = hcm.visibleHotChannels[_oneView.tag];
             id hot2 = hcm.visibleHotChannels[_twoView.tag];
             id hot3 = hcm.visibleHotChannels[_threeView.tag];
             
             if ([hot1 isKindOfClass:[HotChannel class]] &&
                 ((HotChannel*)hot1).channelId == result.channelId) {
                 hotchannel = hot1;
                 hotView = _oneView;
             }
             else if([hot2 isKindOfClass:[HotChannel class]] &&
                     ((HotChannel*)hot2).channelId == result.channelId){
                 hotchannel = hot2;
                 hotView = _twoView;
             }
             else if([hot3 isKindOfClass:[HotChannel class]] &&
                     ((HotChannel*)hot3).channelId == result.channelId){
                 hotchannel = hot3;
                 hotView = _threeView;
             }
             
             
             if (hotchannel != nil && [result succeeded]) {
                 NSDate* update = [tm lastGetMoreDateOfHotChannel:hotchannel];
                 [hotView moreChannels:hotchannel array:[result threads] date:update];                 
                 if([result noChanges]){
                     if ([self curHotChannelsView] == hotView) {                    
                         [PhoneNotification autoHideWithText:@"现在没有更多数据"];
                     }
                 }
             }
             [hotView cancelLoadingState:YES];
         }];
    }
}

- (void)viewNightModeChanged:(BOOL)isNight{
    [_oneView viewNightModeChanged:isNight];
    [_twoView viewNightModeChanged:isNight];
    [_threeView viewNightModeChanged:isNight];
}

#pragma mark 工具函数
// 页面向右边移
- (void)pageMoveToRight:(UIScrollView *)scrollView{
    NSInteger idex = [_oneView tag];
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
    if (idex > 0 && idex < hcm.visibleHotChannels.count) {
        CGRect itemOneRect = _oneView.frame;
        CGRect itemTwoRect = _twoView.frame;
        CGRect itemThreeRect = _threeView.frame;
        
        HotChannelsView* tempView = _oneView;
        _oneView = _threeView;
        _threeView = _twoView;
        _twoView = tempView;
        
        [_oneView setFrame:itemOneRect];
        [_twoView setFrame:itemTwoRect];
        [_threeView setFrame:itemThreeRect];
        
        --idex;
        [_oneView setTag:idex];
        HotChannel *hotchannel = hcm.visibleHotChannels[idex];        
        [self reloadSubViewDate:_oneView hotChannel:hotchannel];
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
    }
    
}

// 页面向左边移
- (void)pageMoveToLeft:(UIScrollView *)scrollView{
    NSInteger idex = [_threeView tag];
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];    
    if (idex > 0 && idex < hcm.visibleHotChannels.count-1) {        
        CGRect itemOneRect = _oneView.frame;
        CGRect itemTwoRect = _twoView.frame;
        CGRect itemThreeRect = _threeView.frame;
  
        HotChannelsView* tempView = _oneView;
        _oneView = _twoView;
        _twoView = _threeView;
        _threeView = tempView;
        
        [_oneView setFrame:itemOneRect];
        [_twoView setFrame:itemTwoRect];
        [_threeView setFrame:itemThreeRect];
        
        ++idex;
        [_threeView setTag:idex];
        
        HotChannel *hotchannel = hcm.visibleHotChannels[idex];
        [self reloadSubViewDate:_threeView hotChannel:hotchannel];
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
    }
}

// 刷新本地频道
-(void)refreshLocalChannel
{
    HotChannelsView *hotView;
    if ([_oneView hotChannel].channelId == 0)
        hotView = _oneView;
    else if([_twoView hotChannel].channelId == 0)
        hotView = _twoView;
    else if([_threeView hotChannel].channelId == 0)
        hotView = _threeView;
    
    
    if (hotView) {
        id hotMgr = [HotChannelsManager sharedInstance];
        HotChannel *hc =
        [hotMgr getChannelWithSameId:[hotView hotChannel]
                             inArray:[hotMgr visibleHotChannels]];
        if (hc) {
            [hotView setLoadingState:NO];
            [self refreshHotChannel:hc completion:nil];
        }
    }
}


/**
 *  刷新新闻频道列表
 */
-(void)refreshCurrentChannel:(void (^)())completion
{
    HotChannelsView *curView = [self curHotChannelsView];
    if (curView) {
        id hotMgr = [HotChannelsManager sharedInstance];
        HotChannel *hc =
        [hotMgr getChannelWithSameId:[curView hotChannel]
                             inArray:[hotMgr visibleHotChannels]];
        if (hc) {
            [curView setLoadingState:YES];
            [self refreshHotChannel:hc completion:^{
                if (completion) {
                    completion();
                }
            }];
        }
    }
}


// 刷新新闻列表
-(void)refreshNewList:(HotChannel *)hc
{
    if([hc isSubschannel]){     // 是 订阅 频道
        // TODO 刷新订阅频道
        [self refreshSubsChannel:hc];
    }
    else {
        ThreadsManager *tm = [ThreadsManager sharedInstance];
        // 如果正在刷新和加载更多，取消加载状态
        if (![tm isHotChannelInRefreshing:self hotChannel:hc] &&
            ![tm isHotChannelInGettingMore:self hotChannel:hc]) {
            
            // 请求刷新热门帖子
            [self refreshHotChannel:hc completion:nil];
        }
    }
}



// 刷新新闻列表
-(void)refreshHotChannel:(HotChannel*)hotChannel
              completion:(void (^)())completion
{
    HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
    HotChannel * curChannel = hcm.visibleHotChannels[_curHotChannelIndex];
    //判断当前频道是不是刷新状态
    if (curChannel.isRefresh || hotChannel == curChannel) {
        //开始刷新时，导航条的刷新按钮开始旋转
        if ([_hotChannelChangedDelegate respondsToSelector:@selector(refreshBtnRotationStart)]) {
            [_hotChannelChangedDelegate refreshBtnRotationStart];
        }
    }
    // 刷新新闻
    [[ThreadsManager sharedInstance] refreshHotChannel:self
                                            hotChannel:hotChannel
                                 withCompletionHandler:^(ThreadsFetchingResult *result)
    {
        HotChannel *hotchannel = nil;
        HotChannelsView *hotView = nil;
        HotChannelsManager *hcm = [HotChannelsManager sharedInstance];
        
        id hot1 = hcm.visibleHotChannels[_oneView.tag];
        id hot2 = hcm.visibleHotChannels[_twoView.tag];
        id hot3 = hcm.visibleHotChannels[_threeView.tag];
        
        if ([hot1 isKindOfClass:[HotChannel class]] &&
            ((HotChannel*)hot1).channelId == result.channelId) {
            hotchannel = hot1;
            hotView = _oneView;
        }
        else if([hot2 isKindOfClass:[HotChannel class]] &&
                ((HotChannel*)hot2).channelId == result.channelId){
            hotchannel = hot2;
            hotView = _twoView;
        }
        else if([hot3 isKindOfClass:[HotChannel class]] &&
                ((HotChannel*)hot3).channelId == result.channelId){
            hotchannel = hot3;
            hotView = _threeView;
        }
        
        if (hotchannel != nil) {            
            if ([result succeeded]) {
                NSDate* update = [[ThreadsManager sharedInstance] lastRefreshDateOfHotChannel:hotchannel];
                // 刷新对应频道数据
                [hotView reloadChannels:hotchannel array:[result threads] date:update];
                
                if ([self curHotChannelsView] == hotView) {
                    if([result noChanges]){
                        [PhoneNotification autoHideWithText:@"现在是最新数据"];
                    }
                }
                
                //加入浮动栏动画 modify by jsg
                [self addFloatingView:result];
            }
            else{
                if ([self curHotChannelsView] == hotView) {
                    [PhoneNotification autoHideWithText:@"网络异常!"];
                }
            }
        }
        [hotView cancelLoadingState:YES];
        
        //结束刷新时，导航条的刷新按钮停止旋转
        if([_hotChannelChangedDelegate respondsToSelector:@selector(refreshBtnRotationFinish)]){
            [_hotChannelChangedDelegate refreshBtnRotationFinish];
        }
        
        if (completion) {
            completion();
        }
    }];
}

// 刷新订阅频道
-(void)refreshSubsChannel:(HotChannel *)hc
{
    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    if ([scm isInCommitting]) {
        // 取消刷新状态
        HotChannelsView *hcv =
        [self hotChannelsViewWithHotchannel:hc];
        [hcv cancelLoadingState:YES];
        return;
    }
    
    // 刷新订阅频道列表
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (!userInfo) {// 非用户，直接刷新固定订阅列表
        [self requestSubsChannelsNew:hc subschannels:[scm loadLocalSubsChannels]];
    }
    else {
        // 刷新订阅频道列表
        [scm refreshSubsChannelListWithUser:userInfo handler:^(BOOL succeeded)
         {
             // 请求订阅频道新闻
             if (succeeded) {
                 [self requestSubsChannelsNew:hc subschannels:[scm loadLocalSubsChannels]];
             }
             else {
                 HotChannelsView *hcv =
                 [self hotChannelsViewWithHotchannel:hc];
                 [hcv cancelLoadingState:YES];
                 [PhoneNotification autoHideWithText:@"请求订阅列表异常"];
             }
         }];
    }
}

-(HotChannelsView *)hotChannelsViewWithHotchannel:(HotChannel *)hc
{
    if (hc) {
        if ([_oneView hotChannel].channelId == hc.channelId)
            return _oneView;
        else if([_twoView hotChannel].channelId == hc.channelId)
            return _twoView;
        else if([_threeView hotChannel].channelId == hc.channelId)
            return _threeView;
    }
    return nil;
}


// 请求订阅频道新闻
- (void)requestSubsChannelsNew:(HotChannel*)hc
                  subschannels:(NSArray*)subsChannels
{
    // 初始状态是没有订阅频道
    if (0 == [subsChannels count]) {
        HotChannelsView *hcv = [self hotChannelsViewWithHotchannel:hc];
        [hcv cancelLoadingState:NO];
    }
    else {
        ThreadsManager *tm = [ThreadsManager sharedInstance];
        [tm updateSubsChannelsLastNews:self subsChannels:subsChannels
                            completion:^(ThreadsFetchingResult *result)
         {
             HotChannelsView *hcv =
             [self hotChannelsViewWithHotchannel:hc];
             if (result.succeeded) {
                 
                 NSDate* update = [tm LastUpdateSubsChannelNews];
                 for (SubsChannel* sc in subsChannels) {
                     
                     BOOL isOK = NO;
                     // 从最新数据列表中拿数据
                     for (ThreadSummary *ts in result.threads){
                         if (sc.channelId == ts.channelId) {
                             isOK = YES;
                             sc.newsId = ts.threadId;
                             sc.newsTitle = ts.title;
                             break;
                         }
                     }
                     
                     // 在最新更新的新闻列表中没有获取到数据，就从本地列表中拿
                     if (!isOK) {
                         ThreadsManager *tm = [ThreadsManager sharedInstance];
                         
                         NSArray *scDataArray =
                         [tm getLocalThreadsForSubsChannelID:sc.channelId];
                         if ([scDataArray count] > 0) {
                             ThreadSummary *ts = [scDataArray firstObject];
                             sc.newsId = ts.threadId;
                             sc.newsTitle = ts.title;
                         }
                     }
                 }
                 
                 
                 [hcv reloadChannels:hc array:nil date:update];
       
             }
             else{
                 [PhoneNotification autoHideWithText:@"刷新订阅频道新闻失败"];
                 [hcv cancelLoadingState:YES];
             }
         }];
    }
    
}


// 在滚动的时候，需要关闭SYZ的GridView
// 收缩Controller里面的GirdView;
//-(void)unexpandControllerGridView{
//    id object = [self nextResponder];
//    while (![object isKindOfClass:[PhoneSurfController class]] &&
//           object != nil) {
//        object = [object nextResponder];
//    }
//
//    if ([object isKindOfClass:[PhoneHotRootController class]]) {
//        [((PhoneHotRootController*)object) unexpandGridViewWithAnimate:YES];
//    }
//}


- (void)addFloatingView:(ThreadsFetchingResult *)result
{
    HotChannelsView *curHCV = [self curHotChannelsView];
    if([curHCV hotChannel].channelId != result.channelId)
        return;
    
    
    //更新资讯为0条不显示
    NSInteger addBumber = [result addedThreadsCount];
    if(![ThreadsFetchingResult sharedInstance].isAppear && addBumber != 0){

        [ThreadsFetchingResult sharedInstance].isAppear = YES; //浮动栏开启
        
        UIFloatingViewController *floatViewCtrl = [[UIFloatingViewController alloc] init];
        [[self curHotChannelsView] addSubview:floatViewCtrl.view];

        NSString *addNumberStr = [NSString stringWithFormat:@"%@",@(addBumber)];
        [floatViewCtrl setAddedThreadsCount:addNumberStr];
            
            
        [[NSNotificationCenter defaultCenter] postNotificationName:kFloatingViewAppear object:nil];
    }
}
@end
