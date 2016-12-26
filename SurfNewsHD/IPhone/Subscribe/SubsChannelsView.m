//
//  SubsChannelsView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelsView.h"
#import "ThreadsManager.h"
#import "SubsTableViewCell.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelSummaryViewController.h"
#import "SurfSubscribeViewController.h"
#import "PictureThreadView.h"
#import "SNLoadingMoreCell.h"
#import "SNThreadViewerController.h"
#import "RealTimeStatisticsRequest.h"

#define ShowThreadSummaryCount 3    // cell显示帖子详情的个数
#define RefreshDateSpace 15         // 刷新订阅频道列表的时间间隔(分钟)


// 加载更多Cell
@interface LoadMoreData : NSObject
@property(nonatomic,assign)NSString *title;
@property(nonatomic,assign) SubsChannel *subsChannel; // 指定更多属于那个订阅频道
@end



@implementation LoadMoreData
@end



///////////////////////////////////////////////////////////////
// SubsChannelTableViewData
///////////////////////////////////////////////////////////////
@interface SubsChannelTableViewData : NSObject{
    LoadMoreData *_loadMore;
}

@property(nonatomic,strong) SubsChannel *subsChannel;
@property(nonatomic,strong) NSMutableArray *threads;
@property(nonatomic) BOOL isLoadingThreadsError;
@property(nonatomic) BOOL isLoadingThreads;

- (id)initWithSubsChannel:(SubsChannel*)sc;
- (NSUInteger)subsObjectsCount;
- (id)subsObjectAtIndex:(NSUInteger)index;
@end

@implementation SubsChannelTableViewData

- (id)initWithSubsChannel:(SubsChannel*)sc
{
    if (self = [super init]) {
        _subsChannel = sc;
        _threads = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}


- (NSUInteger)subsObjectsCount
{
    uint count = 0;
    if (_subsChannel) {
        count = 2;// _subsChannel + threads cell ;
        
        if (_threads.count >= ShowThreadSummaryCount) {
            ++count; // 加载更多
        }
    }
    return count;
}
- (id)subsObjectAtIndex:(NSUInteger)index
{
    if (index == 0)
        return _subsChannel;
    else if(index == 1)
        return _threads;
    else if(index == 2)
    {
        if (!_loadMore)
            _loadMore = [self createLoadMoreData];        
        return _loadMore;
    }
    return nil;
}


- (float)cellHeightAtIndex:(NSUInteger)index
{
    if (index == 0)
        return [SubsTableViewCell CellHeight];
    else if (index == 1){
        if (_threads.count == 0) {
            return [SubsThreadSummaryViewCell LoadingOrErrorStateCellHeight];
        }
        else{
            float cellHeight = 0;
            for (id obj in _threads) {
                cellHeight += [PictureThreadView viewHeight:obj];
            }
            return cellHeight;
        }
    }
    return 25; // 加载更多Cell高度
}

#pragma mark private method
- (void)setSubsChannel:(SubsChannel *)subsChannel{
    _subsChannel = subsChannel;    
    _loadMore.subsChannel = subsChannel;
}

- (LoadMoreData*)createLoadMoreData
{    
    LoadMoreData *moreData = [LoadMoreData new];
    moreData.subsChannel = _subsChannel;
    moreData.title = @"查看全部";
    return moreData;
}
@end





///////////////////////////////////////////////////////////////
// SubsChannelsView
///////////////////////////////////////////////////////////////
typedef enum : NSInteger
{
    UpdateStateNone,                        // 什么也没有做
    UpdateStateRefreshSubsChennelList,      // 刷新订阅频道列表
    UpdateStateGetSubsChannelNews,          // 获取订阅频道新闻
} UpdateState;

@implementation SubsChannelsView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _updateState = UpdateStateNone;
        _scm = [SubsChannelsManager sharedInstance];
        _tableVewDataSource = [NSMutableArray arrayWithCapacity:20];
        
        
        CGRect rect = self.bounds;
        rect.origin.x = 10;
        rect.size.width -= 20;
        _subsTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
        [_subsTableView setDataSource:self];
        [_subsTableView setDelegate:self];
        _subsTableView.sectionHeaderHeight = 0;
        _subsTableView.sectionFooterHeight = 0;
        _subsTableView.backgroundView = nil;
        _subsTableView.backgroundColor = [UIColor clearColor];
        _subsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _subsTableView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:_subsTableView];
        
        
        CGRect topRect = rect;
        topRect.origin.y = - topRect.size.height;
        _topLoading = [[LoadingView alloc] initWithFrame:topRect atTop:YES];
        [_topLoading setStyle:StateDescriptionTableStyleTop];
        [_subsTableView addSubview:_topLoading];
        
        // editing 操作视图
        _editingOperateView = [[UITableViewEditingOperateView alloc] initWithFrame:rect];
        [_editingOperateView hiddenOperateView];
        [self addSubview:_editingOperateView];
        [_subsTableView addSubview:_editingOperateView.subsChannelEidtingView];
        
        
        [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    }
    return self;
}



// 加载订阅频道列表
- (void)loadSubsChannelsList
{
    ThreadsManager* tm = [ThreadsManager sharedInstance];
    [_topLoading updateRefreshDate:[tm LastUpdateSubsChannelNews]]; // 最后刷新新闻的刷新时间
    [_tableVewDataSource removeAllObjects];     // 清除所有数据
    for (SubsChannel *sc in _scm.visibleSubsChannels)
    {
        SubsChannelTableViewData* data = [self createSubsChannelTableViewData:sc];
        
        // 如果有本地数据，加载前3条
        NSArray *scDataArray = [tm getLocalThreadsForSubsChannel:sc];
        if (scDataArray.count > 0) {
            NSUInteger len = scDataArray.count>ShowThreadSummaryCount?ShowThreadSummaryCount:scDataArray.count;
            NSRange rang = NSMakeRange(0, len);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:rang];
            [data.threads addObjectsFromArray:[scDataArray objectsAtIndexes:indexSet]];
        }        
        
        [_tableVewDataSource addObject:data];
    }
    [_subsTableView reloadData];
    
    // 刷新订阅频道列表
    [self refreshSubsChannelsListForTimeInterval];
}



// 刷新订阅频道列表，满足一定的时间间隔
- (void)refreshSubsChannelsListForTimeInterval
{
    if (_updateState !=  UpdateStateNone)
    {
        return;
    }
    
    // 检查刷新时间是否超过15分钟
    ThreadsManager* tm = [ThreadsManager sharedInstance];
    NSDate *lastDate = [tm LastUpdateSubsChannelNews];
    BOOL isLoading = (lastDate==nil) ? YES : NO;
    if (!isLoading) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
        NSDateComponents *dateComponents = [calendar components:flags
                                                       fromDate:lastDate
                                                         toDate:[NSDate date] options:0];
        if (dateComponents.minute > RefreshDateSpace || dateComponents.hour != 0 ||
            dateComponents.day != 0 || dateComponents.month != 0 || dateComponents.year != 0 ) {
            isLoading = YES;
        }
    }
    if (isLoading) {
        [self setLoadingState];
        [self syncSubsChannelList];
    }
    else{
        [self checkSubsChannelChanged];
    }
}
// 检查订阅频道是否发生改变,对改变的频道进行更新或删除操作
- (void)checkSubsChannelChanged
{
    if (_updateState != UpdateStateNone) {
        return;
    }
    
 
    NSMutableArray *tempSubsChannels = [NSMutableArray arrayWithArray:[_scm visibleSubsChannels]];
    NSMutableArray *tempDataSource = [NSMutableArray arrayWithArray:_tableVewDataSource];
    if (tempSubsChannels.count != tempDataSource.count)
    {
        for (SubsChannel* sc in [_scm visibleSubsChannels])
        {
            SubsChannelTableViewData *data = [self findSubsChannelTableDataInArray:sc inTableDataArray:tempDataSource];
            if (data != nil)
            {
                data.subsChannel = sc;
                [tempSubsChannels removeObject:sc];
                [tempDataSource removeObject:data];
            }
        }
        
        // 删除订阅频道
        if (tempDataSource.count > 0)
        {
            [_tableVewDataSource removeObjectsInArray:tempDataSource];
        }
        
        // 添加新增的订阅频道
        if (tempSubsChannels.count > 0)
        {
            for (SubsChannel *sc in tempSubsChannels)
            {
                SubsChannelTableViewData* data = [self createSubsChannelTableViewData:sc];
                data.isLoadingThreads = YES;
                NSUInteger index = [[_scm visibleSubsChannels] indexOfObject:sc];
                if (index < _tableVewDataSource.count) {
                    [_tableVewDataSource insertObject:data atIndex:index];
                }
                else{
                    [_tableVewDataSource addObject:data];
                }
            }            
            [self requestSubsChannelsNew:tempSubsChannels];// 请求新增频道的新闻列表
        }
        
        // 重新刷新
        [_subsTableView reloadData]; 
    }
    else
    {
        // 检测顺序是否改变
        BOOL isReloadData = NO;
        for (int i = 0; i < tempSubsChannels.count; ++i)
        {
            SubsChannel *sc = tempSubsChannels[i];
            SubsChannelTableViewData *data = _tableVewDataSource[i];
            if (data.subsChannel.channelId != sc.channelId)
            {
                isReloadData = YES;
                SubsChannelTableViewData *tempData = [self findSubsChannelTableDataInArray:sc inTableDataArray:_tableVewDataSource];
                if (tempData != nil)
                {
                    [_tableVewDataSource removeObject:tempData];
                    [_tableVewDataSource insertObject:tempData atIndex:i];                    
                }                
            }
            else{
                data.subsChannel = sc;
            }
        }
        
        if (isReloadData)
        {
            [_subsTableView reloadData]; 
        }
    }
}




-(void)setLoadingState{
    _topLoading.loading = YES;
    _topLoading.state = kPRStateLoading;
    _subsTableView.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
    _subsTableView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
}

-(void)cancelLoadingState:(void (^)(BOOL finished))completion
{
    if (_topLoading.isLoading)
    {
        _topLoading.loading = NO;
        [_topLoading setState:kPRStateNormal animated:YES];
        [UIView animateWithDuration:kUpDownUpdateDuration*2
                              delay:kUpDownUpdateDuration*2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{_subsTableView.contentInset=UIEdgeInsetsMake(1, 0, 0, 0);}
                         completion:^(BOOL finished) {
                             _updateState = UpdateStateNone;
                             _subsTableView.contentInset = UIEdgeInsetsZero;
                             if (completion) { completion(finished); }
                         }];
    }
    else
    {
        if (completion)
        {
            completion(YES);
        }
    }
}



// 改变风格：添加一个简介模式风格
- (void)changeStyle
{
    _isSimpleMode = !_isSimpleMode;
    [_subsTableView reloadData];    
}



#pragma mark SubsChannelChangedObserver
// 订阅频道发生改变
-(void)subsChannelChanged
{
    if (_updateState == UpdateStateNone)
    {
        [self checkSubsChannelChanged];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSimpleMode) {
        return 1;
    }
    
    if (section < _tableVewDataSource.count) {
        SubsChannelTableViewData *data = _tableVewDataSource[section];
        return data.subsObjectsCount;
    }
    else {
        return 1;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableVewDataSource.count + 1;// 1 是添加更多订阅频道
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger rowIdx = indexPath.row;
    NSInteger sectionIdx = indexPath.section;
    
    if (sectionIdx >= _tableVewDataSource.count) {
        // 订阅更多频道
        NSString *identifier = @"addMoreSubs";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [((SNLoadingMoreCell*)cell) hiddenActivityView:YES];
            [((SNLoadingMoreCell*)cell) setTitle:@"+订阅更多频道"];
            [((SNLoadingMoreCell*)cell) setBgColorForDay:[UIColor whiteColor]];
            [((SNLoadingMoreCell*)cell) setBgColorForNight:[UIColor colorWithHexValue:0xFF3C3D3E]];
        }
        [cell viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode]; // 需要每次检查。
        return cell;
    }
    
    
    SubsChannelTableViewData *data = _tableVewDataSource[sectionIdx];
    id object = [data subsObjectAtIndex:rowIdx];
    
    if ([object isKindOfClass:[SubsChannel class]])
    {
        NSString *identifier = @"subsChannelCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SubsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        [(SubsTableViewCell*)cell reloadSubsChannel:object indexPath:indexPath onlySubs:NO];
    }
    else if ([object isKindOfClass:[NSMutableArray class]])
    {
        NSString *identifier = @"threadSummaryCell";
        SubsThreadSummaryViewCell *tempCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (tempCell == nil) {
            tempCell = [[SubsThreadSummaryViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:identifier];
            tempCell.titleEdgeInsets = UIEdgeInsetsMake(0.f, 30.f, 0.f, 10.f);
        }
        
        // 设置文字
        [tempCell reloadDataWithThreadSummaryArray:object isLoading:data.isLoadingThreads isError:data.isLoadingThreadsError];
        cell = tempCell;
    }
    else if([object isKindOfClass:[LoadMoreData class]])
    {
        NSString *identifier = @"stringCell";
        SubsChannelLoadMoreCell *tempCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (tempCell == nil) {
            tempCell = [[SubsChannelLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:identifier];
        }
        
        // 设置文字
        tempCell.title = ((LoadMoreData*)object).title;
        cell = tempCell;
    }
    
    [cell viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    return cell;
}

// 使用这个函数，才会显示Swipe to Delete
- (void)tableView:(UITableView *)tView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    OfflineIssueInfo *info = [offlinesArray objectAtIndex:indexPath.row];
//    [[OfflineDownloader sharedInstance] deleteDataForMagIssue:info];
//    [offlinesArray removeObject:info];
//    [self reloadTableView];
}


#pragma mark UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 一滚动，就恢复cell的状态
    NSArray *cells = [_subsTableView visibleCells];
    for (UITableViewCell *c in cells)
    {
        if (c.isEditing)
        {
            [c setEditing:NO animated:YES];
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
    if (_topLoading.state == kPRStateLoading) {
        return;
    }
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        _topLoading.state = kPRStatePulling;
    }
    else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){ //header part appeared
        _topLoading.state = kPRStateLocalDisplay;
    }
    
}
// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_topLoading.state == kPRStateLoading) {
        return;
    }
    
    // headerView 状态是拉伸状态
    if (_topLoading.state == kPRStatePulling) {
        // 下啦刷新
        _topLoading.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self syncSubsChannelList];// 同步订阅列表
        }];
    }
    else if(_topLoading.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
        } completion:^(BOOL finished) {
            _topLoading.state = kPRStateNormal;
        }];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSInteger sectionIndex = indexPath.section;
    if (sectionIndex < _tableVewDataSource.count)
    {
        SubsChannelTableViewData *data = _tableVewDataSource[sectionIndex];
        return [data cellHeightAtIndex:index];
    }
    else{
        return 30.f; // 添加更多订阅频道高度
    }   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_editingOperateView.isHidden) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    
    if (indexPath.section < _tableVewDataSource.count) {
        SubsChannelTableViewData *data = _tableVewDataSource[indexPath.section];
        if (indexPath.row == 0 || indexPath.row == 2) {
            // 跳到订阅频道的帖子列表
            [self gotoSubsChannelSummaryViewController:data.subsChannel];
        }
        else if(indexPath.row == 1) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[SubsThreadSummaryViewCell class]]) {
                // 注意：[tableView deselectRowAtIndexPath:indexPath animated:YES];要在这个函数之后使用
                ThreadSummary *summary = [((SubsThreadSummaryViewCell*)cell) getSelectionThreadSummary];
                if (summary != nil) {
                    // 这个还要给一坨数据
                    NSArray *threads = [[ThreadsManager sharedInstance] getLocalThreadsForSubsChannel:data.subsChannel];
                    if ([threads indexOfObject:summary] == NSNotFound) {
                        for (ThreadSummary *t in threads) {
                            if (t.threadId == summary.threadId) {
                                summary = t;
                                break;
                            }
                        }
                    }
                  
                    
                    if (summary != nil) {
                        // 标记为已读
                        [[ThreadsManager sharedInstance] markThreadAsRead:summary];
                        
                        
                        // 新闻详情的一些数据
                        NSMutableArray* arr = [[threads mutableCopy] mutableCopy];
                        for (NSInteger i = [arr count] - 1; i >= 0; i --) {
                            ThreadSummary* t = (ThreadSummary*)[arr objectAtIndex:i];
                            // 过滤type > 2的活动类型
                            if (t.type > 2) {
                                [arr removeObjectAtIndex:i];
                            }
                        }
                        
                        NSInteger index = [arr indexOfObject:summary];
                        if (index == NSNotFound) {
                            for (int i = 0; i<arr.count; ++i) {
                                ThreadSummary *ts = [arr objectAtIndex:i];
                                if ([ts isKindOfClass:[ThreadSummary class]]) {
                                    if (ts.threadId == summary.threadId) {
                                        index = i;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:summary andWithType:kRTS_RSSNews and:^(BOOL succeeded) {
                            
                        }];
                        
                        
                        ThreadSummary *ts = arr[index];
                        SNThreadViewerController* pnc = [[SNThreadViewerController alloc] initWithThread:ts];
                        Class classType = [SurfSubscribeViewController class];
                        SurfSubscribeViewController *controller = [self findUserObject:classType];
                        [controller presentController:pnc animated:PresentAnimatedStateFromRight];
                    }
                }
            }
        }
    }
    else if(indexPath.section == _tableVewDataSource.count)
    {
        // 添加更多订阅频道
        SurfSubscribeViewController *controller = [self findUserObject:[SurfSubscribeViewController class]];
        if (controller && [controller isKindOfClass:[SurfSubscribeViewController class]]) {            
            [controller addSubschannelClick:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section < _tableVewDataSource.count)
    {
        tableView.scrollEnabled = NO;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        SubsChannelTableViewData *data = _tableVewDataSource[indexPath.section];        
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        [_editingOperateView showOperateView:cellRect subsChannel:data.subsChannel];
    }
    return UITableViewCellEditingStyleNone;
}

// 当返回UITableViewCellEditingStyleNone的时候，UITableView会触发cell selection事件，下面的代码禁止这种情况的发生。
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_editingOperateView.isHidden) {
        return nil;
    }
    return indexPath;
}


//- (NSString *)tableView:(UITableView *)tableView
//titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"改变Editing的长度.";
//}


#pragma mark private method
- (void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight)
    {
        self.backgroundColor = [UIColor colorWithHexValue:0xFF242526];
        [_subsTableView setSeparatorColor:[UIColor colorWithHexValue:0xff222223]];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithHexValue:0xFFE9E8E8];
        [_subsTableView setSeparatorColor:[UIColor colorWithHexValue:0xffdcdbdb]];
    }
    
    [_topLoading viewNightModeChanged:isNight];
    [_editingOperateView viewNightModeChanged:isNight];
    for (UITableViewCell* cell in [_subsTableView visibleCells]) {
        [cell viewNightModeChanged:isNight];
    }
}
- (SubsChannelTableViewData*)findSubsChannelTableDataInArray:(SubsChannel*)sc inTableDataArray:(NSArray*)array
{
    for (SubsChannelTableViewData *data in array) {
        if (data.subsChannel.channelId == sc.channelId) {
            return data;
        }
    }
    return nil;
}

- (SubsChannelTableViewData*)createSubsChannelTableViewData:(SubsChannel*)sc
{
    SubsChannelTableViewData* data = [[SubsChannelTableViewData alloc]initWithSubsChannel:sc];
    return data;    
}

// 同步订阅频道列表
- (void)syncSubsChannelList
{
    if (_updateState ==  UpdateStateGetSubsChannelNews) {
        // 获取订阅频道新闻，需要取消加载状态
        _updateState = UpdateStateNone;
        [[ThreadsManager sharedInstance] cancelUpdateSubsChannelsNews:self];
    }
    
    // 没有做任何事，就请求订阅频道列表
    if (_updateState ==  UpdateStateNone)
    {
        _updateState = UpdateStateRefreshSubsChennelList;
        // 刷新订阅频道列表
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        if (!userInfo)// 非用户，直接刷新固定订阅列表
        {
             [self requestSubsChannelsNew:[_scm loadLocalSubsChannels]];
        }
        else{
            [_scm refreshSubsChannelListWithUser:userInfo handler:^(BOOL succeeded)
            {
                // 请求订阅频道新闻
                if (succeeded)
                {
                    [self requestSubsChannelsNew:[_scm loadLocalSubsChannels]];
                }
                else
                {
                    [self cancelLoadingState:nil];
                    [PhoneNotification autoHideWithText:@"请求订阅列表异常"];
                }
            }];
        }
    }
}

// 请求订阅频道新闻
- (void)requestSubsChannelsNew:(NSArray*)subsChannels
{    
    ThreadsManager *tm = [ThreadsManager sharedInstance];    
    // 居然会没有订阅频道的情况
    if (subsChannels.count > 0)
    {
        // 在用户切换的时候，只清空数据，订阅频道的新闻不删除，导致刷新不会有数据
        for (SubsChannel *sc in subsChannels)
        {
            SubsChannelTableViewData *data = [self findSubsChannelTableDataInArray:sc inTableDataArray:_tableVewDataSource];
            if (data != nil && data.threads.count == 0)
            {
                NSArray *threads = [[ThreadsManager sharedInstance] getLocalThreadsForSubsChannelID:sc.channelId];
                if (threads.count > 0)
                {
                    NSUInteger addObjectCount = ShowThreadSummaryCount;
                    if (threads.count < addObjectCount)
                    {
                        addObjectCount = threads.count;
                    }
                    NSRange rang = NSMakeRange(0, addObjectCount);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:rang];
                    [data.threads addObjectsFromArray:[threads objectsAtIndexes:indexSet]];
                }
            }
        }        
        
    
        
      
        [self notifyTableViewDataLoadingState];          // 添加加载状态        

        _updateState = UpdateStateGetSubsChannelNews;
        [tm updateSubsChannelsLastNews:self subsChannels:subsChannels
                            completion:^(ThreadsFetchingResult *result)
         {
             _updateState = UpdateStateNone;
             if (result.succeeded)
             {
                 [_topLoading updateRefreshDate:[tm LastUpdateSubsChannelNews]];
                 if (!result.noChanges && result.threads.count > 0)
                 {
                     [self updateNewsForSubsChannelTableSource:result.threads];
                     [self cancelLoadingState:^(BOOL finished)
                     {
                        // 把所有可见的cell 都更新一下
                        [_subsTableView reloadData];
                     }];
                 }
                 else{
                     [self cancelLoadingState:nil];
                     
                     // 刷新TableView状态为异常状态
                     [self notifyTableViewDataErrorState];
                 }
             }
             else{
                 [PhoneNotification autoHideWithText:@"刷新订阅频道新闻失败"];
                 [self cancelLoadingState:nil];
                 
                 // 刷新TableView状态为异常状态
                 [self notifyTableViewDataErrorState];
             }
         }];
    }
    else
    {
        _updateState = UpdateStateNone;
        [PhoneNotification autoHideWithText:@"您还没有订阅任何栏目"];
        [self cancelLoadingState:nil];
    }
}

// 更新TableView数据源中的新闻
- (void)updateNewsForSubsChannelTableSource:(NSArray*)news
{
    if ([news count] == 0) {  return;  }    
    
    for (SubsChannelTableViewData *data in _tableVewDataSource)
    {
        u_long cid = data.subsChannel.channelId;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelId == %ld",cid];
        NSArray *newsForCid = [news filteredArrayUsingPredicate:predicate];
        if (newsForCid.count > 0)
        {
            NSUInteger addObjectCount = ShowThreadSummaryCount;
            if (newsForCid.count < addObjectCount) {
                addObjectCount = newsForCid.count;
            }
            NSRange rang = NSMakeRange(0, addObjectCount);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:rang];
            [data.threads addObjectsFromArray:[newsForCid objectsAtIndexes:indexSet]];
       
            // 删除多余ShowThreadSummaryCount的数据
            if (data.threads.count > ShowThreadSummaryCount)
            {
                NSUInteger del_Count = data.threads.count - ShowThreadSummaryCount;
                NSRange del_rang = NSMakeRange(ShowThreadSummaryCount, del_Count);
                NSIndexSet *del_indexSet = [NSIndexSet indexSetWithIndexesInRange:del_rang];
                [data.threads removeObjectsAtIndexes:del_indexSet];
            }

            data.isLoadingThreads = NO;
            data.isLoadingThreadsError = NO;
        }
    }
}

- (void)gotoSubsChannelSummaryViewController:(SubsChannel*)sc
{
    // TODO 跳到订阅频道的帖子列表
    SubsChannelSummaryViewController *summaryController;
    summaryController = [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummaryDownload];
    summaryController.title = sc.name;
    summaryController.subsChannel = sc;    
    Class classType = [SurfSubscribeViewController class];
    SurfSubscribeViewController *controller = [self findUserObject:classType];
    if ([controller isKindOfClass:classType])
    {
        [controller presentController:summaryController animated:PresentAnimatedStateFromRight];
    }
}

// 通知TableView Cell 显示异常状态
-(void)notifyTableViewDataErrorState
{
    BOOL isReloadData = NO;
    for (SubsChannelTableViewData *data in _tableVewDataSource)
    {
        data.isLoadingThreads = NO;
        data.isLoadingThreadsError = data.threads.count > 0 ? NO : YES;
        if (data.isLoadingThreadsError)
        {
            isReloadData = YES;
        }
    }
    
    // 重新刷新TableView状态
    if (isReloadData)
    {
        [_subsTableView reloadData];
    }
}

-(void)notifyTableViewDataLoadingState
{
    BOOL isReloadData = NO;
    for (SubsChannelTableViewData *data in _tableVewDataSource)
    {
        data.isLoadingThreadsError = NO;
        data.isLoadingThreads = data.threads.count > 0 ? NO : YES;
        if (data.isLoadingThreads)
        {
            isReloadData = YES;
        }
    }
    
    // 重新刷新TableView状态
    if (isReloadData)
    {
        [_subsTableView reloadData];
    }
}

- (void)handleEditingOperateViewHidderEvent
{
    _subsTableView.scrollEnabled = YES;
    NSArray *indexPaths = [_subsTableView indexPathsForVisibleRows];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath *index = obj;
            if (index.row == 0)
            {
                [_subsTableView cellForRowAtIndexPath:index].selectionStyle = UITableViewCellSelectionStyleBlue;
            }
        }
    }];
    
}
@end
