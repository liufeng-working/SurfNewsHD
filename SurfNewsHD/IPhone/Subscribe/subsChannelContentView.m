//
//  subsChannelContentView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "subsChannelContentView.h"
#import "ThreadsManager.h"
#import "ThreadSummary.h"
#import "PictureThreadView.h"
#import "SubsChannelsListResponse.h"
#import "PhoneSurfController.h"
#import "SNLoadingMoreCell.h"
#import "SNThreadViewerController.h"


#define RefreshDateSpaceMinute 15   // 刷新频道内容时间间隔



@implementation subsChannelContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _subsContentTableView = [[UITableView alloc] initWithFrame:self.bounds
                                                 style:UITableViewStylePlain];
        _subsContentTableView.dataSource = self;
        _subsContentTableView.delegate = self;
        [_subsContentTableView setBackgroundColor:[UIColor clearColor]];
        [_subsContentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_subsContentTableView];
        
        // 创建headerView和footerView
        float width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds);
        CGRect rect = CGRectMake(0.f, - height, width, height);
        _headerLoadingView = [[LoadingView alloc] initWithFrame:rect atTop:YES];
        _headerLoadingView.style = StateDescriptionTableStyleTop;
        [_subsContentTableView addSubview:_headerLoadingView];
        
        _channelContentArray = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
}

// 加载订阅频道
- (void)reloadSubsChannel:(SubsChannel*)sc
{
    _subsChannel = sc;  
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    NSArray *subsCnl = [tm getLocalThreadsForSubsChannel:_subsChannel];
    [self reloadThreadsSummary:subsCnl];
    
    
    // 设置LoadingView为正在加载状态    
    NSDate *date = [tm lastRefreshDateOfSubsChannel:_subsChannel];
    
    BOOL isLoading = (date == nil) ? YES : NO;//没有更新时间，就刷新
    if (!isLoading && subsCnl.count < 10) {
        isLoading = YES;
    }
    
    
    if (!isLoading) {
        // 比较更新时间是否大于设定的时间间隔
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |
                        NSDayCalendarUnit | kCFCalendarUnitHour | kCFCalendarUnitMinute;
        NSDateComponents *components = [calendar components:flags fromDate:date toDate:[NSDate date] options:0];        
        if ([components year] != 0 || [components month] != 0 || [components day] != 0 ||
            [components hour] != 0 || [components minute] > RefreshDateSpaceMinute) {
            isLoading = YES;
        }
    }    
    if (isLoading) { // 没有加载，更新时间大于设定时间
        [self setLoadingStatus];
        [self requestRefreshSubsChannel];
    }
}

- (void)setLoadingStatus
{
    _headerLoadingView.loading = YES;
    _headerLoadingView.state = kPRStateLoading;
    _subsContentTableView.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
    _subsContentTableView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
}

-(void)requestRefreshSubsChannel
{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if ([tm isSubsChannelInRefreshing:_subsChannel] || [tm isSubsChannelInGettingMore:_subsChannel]) { // 正在刷新就不要在加载了
        [self recoverLoadingViewStateNormal];
        return;
    }
    
    [tm refreshSubsChannel:self subsChannel:_subsChannel withCompletionHandler:^(ThreadsFetchingResult *result)
    {
        if (result.succeeded) {
            if (result.channelId == _subsChannel.channelId){
                NSDate* update = [tm lastRefreshDateOfSubsChannel:_subsChannel];
                [_headerLoadingView updateRefreshDate:update];
                if (![result noChanges]) {// 数据发生改变
                    [self reloadThreadsSummary:result.threads];
                }
                else{
                    [PhoneNotification autoHideWithText:@"现在是最新数据"];
                }
            }
        }
        else{
            [SurfNotification surfNotification:@"网络异常!"];
        }
        
        [self recoverLoadingViewStateNormal]; // 恢复LoadingView为等待状态
    }];
}

#pragma mark UITableViewDataSource
// 每个分区有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_channelContentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_channelContentArray.count - 1 == indexPath.row &&
        [[_channelContentArray lastObject] isKindOfClass:[NSString class]])
    {
        NSString *cellIdentifier = @"more_cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.userInteractionEnabled = NO;
        }
        // 这里需要每次都检查下是什么模式
        [(SNLoadingMoreCell*)cell hiddenActivityView:YES];
        [cell viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
        return cell;
    }
    
    
    
    
    PictureThreadView *ptView = nil;
    static NSString *CellIdentifier = @"hotChannels_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        // cell 选择后的背景View
        UIView *bgView = [[UIView alloc] initWithFrame:[cell bounds]];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.selectedBackgroundView = bgView;
        
        CGSize size = [tableView rectForRowAtIndexPath:indexPath].size;
        CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
        ptView = [[PictureThreadView alloc] initWithFrame:rect];
        [[cell contentView] addSubview:ptView];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    else{        
        for (PictureThreadView* tempView in [cell contentView].subviews) {
            if([tempView isKindOfClass:[PictureThreadView class]]){
                ptView = tempView;
                break;
            }
        }
    }
    
    
    // 设置夜间模式
    if (cell.selectedBackgroundView != nil) {
        if ([ThemeMgr sharedInstance].isNightmode)
            cell.selectedBackgroundView .backgroundColor= [UIColor colorWithHexValue:kTableCellSelectedColor_N];
        else
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
    }

    
    if ([_channelContentArray count] > indexPath.row) {
        [ptView reloadThreadSummary:[_channelContentArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}


#pragma mark UITableViewDelegate
// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_channelContentArray[indexPath.row] isKindOfClass:[NSString class]]) {
        return kMoreCellHeight;
    }
    return [PictureThreadView viewHeight:_channelContentArray[indexPath.row]]; // 边距
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    
    if (row < _channelContentArray.count) {
        id ts = [_channelContentArray objectAtIndex:row];
        if ([ts isKindOfClass:[ThreadSummary class]]) {
            // 标记为已读
            [[ThreadsManager sharedInstance] markThreadAsRead:ts];
            [_subsContentTableView reloadData];            
            
            
            [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:ts andWithType:kRTS_RSSNews and:^(BOOL succeeded) {
                
            }];
            
            
            // 2014.8.20 使用新的新闻
            SNThreadViewerController *pnc =
            [[SNThreadViewerController alloc] initWithThread:ts];
            PhoneSurfController *psc = [self findUserObject:[PhoneSurfController class]];
            [psc presentController:pnc
                          animated:PresentAnimatedStateFromRight];
        }
    }
}

// 改变offset 都会回调这个函数，
// 这里改变headerView和FooterView状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerLoadingView.state == kPRStateLoading )
        return;
    
    
    CGPoint offset = scrollView.contentOffset;    
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        _headerLoadingView.state = kPRStatePulling;
    } else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){ //header part appeared
        _headerLoadingView.state = kPRStateLocalDisplay;
    }
}

// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerLoadingView.state == kPRStateLoading) {
        return;
    }
    
    // headerView 状态是拉伸状态
    if (_headerLoadingView.state == kPRStatePulling) {
        // 下啦刷新
        _headerLoadingView.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self requestRefreshSubsChannel]; //刷新
        }];
    }
    else if(_headerLoadingView.state == kPRStateLocalDisplay){
        //        _headerView.state = kPRStateNormal;
        [UIView animateWithDuration:.18f animations:^{
        } completion:^(BOOL finished) {
            _headerLoadingView.state = kPRStateNormal;
        }];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 滚动到底部，自动加载更多数据
    float scrollContentHeight = scrollView.contentSize.height;
    float scrollHeight = CGRectGetHeight(scrollView.bounds);
    if (scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - kMoreCellHeight &&
        [[_channelContentArray lastObject] isKindOfClass:[NSString class]]) {
        [self requestMoreThreandSummary]; // 请求更多帖子详情
    }
}

// 加载更多订阅频道的帖子内容
- (void)requestMoreThreandSummary
{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if ([tm isSubsChannelInGettingMore:_subsChannel] || [tm isSubsChannelInRefreshing:_subsChannel]) {
        return;
    }

    SNLoadingMoreCell *moreCell;
    id cell = [[_subsContentTableView visibleCells] lastObject];
    if ([cell isKindOfClass:[SNLoadingMoreCell class]]){
        moreCell = cell;
    }
    [moreCell hiddenActivityView:NO];
    
    
    // 请求更多订阅频道的帖子内容
    [tm getMoreForSubsChannel:self subsChannel:_subsChannel
        withCompletionHandler:^(ThreadsFetchingResult *result)
    {
        [moreCell hiddenActivityView:YES];
        
        if (result.succeeded) {
            if (result.channelId == _subsChannel.channelId)
            {
                // 这个函数，会处理。没有数据时候，把moreCell删除掉
                [self loadMoreThreadsSummary:result.threads];
                if ([result noChanges]) {
                    [PhoneNotification autoHideWithText:@"现在没有更多数据"];
                }
            }
        }
        else {
            // 加载失败提示
            [PhoneNotification autoHideWithText:@"网络异常"];
        }
    }];

}



// 恢复LoadingView 默认状态
- (void)recoverLoadingViewStateNormal{
    if (_headerLoadingView.loading) {
        _headerLoadingView.loading = NO;
        [_headerLoadingView setState:kPRStateNormal animated:YES];
        [UIView animateWithDuration:kUpDownUpdateDuration+kUpDownUpdateDuration
                              delay:kUpDownUpdateDelay
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{_subsContentTableView.contentInset=UIEdgeInsetsMake(1, 0, 0, 0);}
                         completion:^(BOOL finished) {
                             _subsContentTableView.contentOffset = CGPointZero;
                             _subsContentTableView.contentInset = UIEdgeInsetsZero;
                         }];
    }
}


// 重新加载帖子内容
- (void)reloadThreadsSummary:(NSArray*)threadsSummary
{
    [_channelContentArray removeAllObjects];
    if (threadsSummary.count > 0) {
        [_channelContentArray addObjectsFromArray:threadsSummary];
        
        // 添加更多加载cellDate
        [_channelContentArray addObject:@"添加更多"];
        [_subsContentTableView reloadData]; // 更新table
    }
}

// 加载更多帖子内容
- (void)loadMoreThreadsSummary:(NSArray*)threadsSummary{
    // 移除loadMoreCellData
    if ([[_channelContentArray lastObject] isKindOfClass:[NSString class]]) {
        [_channelContentArray removeLastObject];
    }
    
    if (threadsSummary.count > 0) {
        // 添加更多帖子数据
        [_channelContentArray addObjectsFromArray:threadsSummary];
        
        // 添加更多加载cellDate
        [_channelContentArray addObject:@"添加更多"];
        
        // table Y坐标向上移动一点
        CGPoint offset = _subsContentTableView.contentOffset;
        offset.y += 30.f;
        [_subsContentTableView setContentOffset:offset animated:YES];
        
    }
    [_subsContentTableView reloadData]; // 更新table
}

-(void)viewNightModeChanged:(BOOL)isNight{
    if (isNight) {
        [_subsContentTableView setSeparatorColor:[UIColor colorWithHexValue:0xff222223]];
    }
    else{
        [_subsContentTableView setSeparatorColor:[UIColor colorWithHexValue:0xffdcdbdb]];
    }
    
    [_headerLoadingView viewNightModeChanged:isNight];


}
//已经阅读的位置 by Lee
-(void)setScrollOfThread:(ThreadSummary *)thread
{
    if ([_channelContentArray count]<= 0 || !thread ||
        thread.channelId != _subsChannel.channelId) {
        return;
    }
    
    NSInteger index = [_channelContentArray indexOfObject:thread];
    if (index == NSNotFound)
    {
        int i = 0;
        for (ThreadSummary *item in _channelContentArray)
        {
            if (item.threadId == thread.threadId) {
                index = i;
                break;
            }
            
            i ++;
        }
    }
    if (index != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        BOOL isVisible = [[_subsContentTableView indexPathsForVisibleRows] containsObject:indexPath];
        
        if (!isVisible)
        {
            [_subsContentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
        
    }
}
-(void)setScrollOfThreadY:(NSNumber *)y{
    [_subsContentTableView setContentOffset: CGPointMake(0.f, [y floatValue]) animated:YES];
}
@end
