//
//  PhotoCollectionListView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionListView.h"
#import "LoadingView.h"
#import "SNLoadingMoreCell.h"
#import "PhotoCollectionCell.h"
#import "PhotoCollectionData.h"
#import "PhotoCollectionListHorizontalScrollView.h"
#import "PhotoCollectionContentController.h"
#import "PhotoGalleryViewController.h"
#import "PhotoCollectionManager.h"
#import "ThreadsManager.h"
#import "RealTimeStatisticsRequest.h"



@implementation PhotoCollectionListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pccListData = [NSMutableArray arrayWithCapacity:20];
        
        
        CGRect tableRect = self.bounds;
        _photoCollectionTableView = [[UITableView alloc] initWithFrame:tableRect
                                                                 style:UITableViewStyleGrouped];
        _photoCollectionTableView.dataSource = self;
        _photoCollectionTableView.delegate = self;
        _photoCollectionTableView.backgroundColor = [UIColor clearColor];
        _photoCollectionTableView.showsHorizontalScrollIndicator = NO;
        _photoCollectionTableView.contentSize = tableRect.size;
        _photoCollectionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;        
        _photoCollectionTableView.sectionHeaderHeight = .0;
        _photoCollectionTableView.sectionFooterHeight = .0;
        _photoCollectionTableView.backgroundView = nil;
        [self addSubview:_photoCollectionTableView];
        
        
        // 创建headerView
        CGRect rect = CGRectMake(0, 0 - tableRect.size.height, tableRect.size.width, tableRect.size.height);
        _headerView = [[LoadingView alloc] initWithFrame:rect atTop:YES];
        _headerView.style = StateDescriptionTableStyleTop;
        [_photoCollectionTableView addSubview:_headerView];
        
    }
    return self;
}

// 更新刷新时间
- (void)updateRefreshDate:(NSDate*)date
{
    [_headerView updateRefreshDate:date];   // 设置刷新时间
}

// 加载数据
- (void)reloadDataWithPhotoCollectionChannel:(PhotoCollectionChannel*)pcc
                         photoCollectionList:(NSArray*)cList
                                 refreshDate:(NSDate*)date
{
    _photoCollectionChannel = pcc;
    [_pccListData removeAllObjects];// 删除旧数据    
    [_pccListData addObjectsFromArray:cList];
    if (cList.count >= 20)
    {
        [_pccListData addObject:@"加载更多"]; // 添加加载风火轮
    }

    [_headerView updateRefreshDate:date];   // 设置刷新时间
    [_photoCollectionTableView reloadData]; // 加载数据
    
    // 加载当前屏幕中的图片
    [self performSelector:@selector(loadCellsImage) withObject:nil afterDelay:0.2];
}


// 滚动条的偏移坐标
- (void)scrollOffsetY:(float)y
{
    if (!_headerView.loading) {
        float offY = _photoCollectionTableView.contentSize.height - _photoCollectionTableView.bounds.size.height;
        if (offY < y && offY >= 0 ) {
            _photoCollectionTableView.contentOffset = CGPointMake(0.f, offY);
        }
        else{
            _photoCollectionTableView.contentOffset = CGPointMake(0.f, y);
        }
    }
}


// 设置刷新状态
- (void)setRefreshState
{
    if (!_headerView.loading) {
        _headerView.loading = YES;
        _headerView.state = kPRStateLoading;        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _photoCollectionTableView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
            _photoCollectionTableView.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)cancelRefreshState:(BOOL)animated
{
    if (_headerView.loading) {
        _headerView.loading = NO;
        [_headerView setState:kPRStateNormal animated:YES];
        
        if (animated) {
            [UIView animateWithDuration:kUpDownUpdateDuration*2 delay:kUpDownUpdateDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                //top不留一个像素，最顶的分割线将看不到
                _photoCollectionTableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
            } completion:^(BOOL finished) {
                _photoCollectionTableView.contentOffset = CGPointZero;
                _photoCollectionTableView.contentInset = UIEdgeInsetsZero;
            }];
        }
        else{
            _photoCollectionTableView.contentOffset = CGPointZero;
            _photoCollectionTableView.contentInset = UIEdgeInsetsZero;
        }
    }
}

// 检测图集频道内容是否发生改变
- (NSUInteger)photoCollectionCount;
{    
    NSUInteger listCount = [_pccListData count];
    if ([[_pccListData lastObject] isKindOfClass:[NSString class]]) {
        --listCount;
    }    
    return listCount;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==  _pccListData.count - 1) {
        if ([_pccListData[indexPath.section] isKindOfClass:[NSString class]]) {
            return kMoreCellHeight;
        }
    }
    return [PhotoCollectionCell CellHeight];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return 10.f;    // 顶部间隔（zyl）
    return 10.f;        // 间隔
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _pccListData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifndef ipad
    if (indexPath.section ==  _pccListData.count - 1 &&
        [[_pccListData lastObject] isKindOfClass:[NSString class]]) {
        NSString *identifier = @"loadingmore_cell";
        SNLoadingMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.userInteractionEnabled = NO;            
        }
        [cell viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode]; // 需要每次检查。
        return cell;
    }
#endif
    
    NSString *cellIdentifier = @"photoCollection_cell";
    PhotoCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[PhotoCollectionCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:cellIdentifier];
        
        // 添加圆角边距（zyl）
        cell.layer.cornerRadius = 0.5f;// 圆角半径
        cell.layer.borderWidth = 1;
        cell.layer.masksToBounds = YES;
        cell.layer.borderColor = [UIColor clearColor].CGColor;// 边框颜色

    }
    
    id obj = _pccListData[indexPath.section];
    if ([obj isKindOfClass:[PhotoCollection class]]){
        [cell reloadDateWithPhotoCollection:obj];
    }
    
    [cell viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    return cell;
}


// 改变offset 都会回调这个函数，
// 这里改变headerView和FooterView状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 0)
        _photoCollectionChannel.listScrollOffsetY = scrollView.contentOffset.y;
    
    
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerView.state == kPRStateLoading)
        return;
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        _headerView.state = kPRStatePulling;
    } else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){ //header part appeared
        _headerView.state = kPRStateLocalDisplay;
    }
}
// 滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 加载cell图集
  	[self loadCellsImage];
    
    
    // 滚动到底部，自动加载更多数据
    float scrollContentHeight = scrollView.contentSize.height;
    float scrollHeight = scrollView.bounds.size.height;
    if (scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - kMoreCellHeight &&
        [[_pccListData lastObject] isKindOfClass:[NSString class]])
    {
        [self morePhotoCollectionList];
    }
}


// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadCellsImage]; // 没有加速的情况下，就不会回调scrollViewDidEndDecelerating
    }
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerView.state == kPRStateLoading)
        return;
    
    // headerView 状态是拉伸状态
    if (_headerView.state == kPRStatePulling) {
        _headerView.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            // 通知刷新图集频道
            [self updatePhotoCollectionList];
        }];
    }
    else if(_headerView.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:.18f animations:^{} completion:^(BOOL finished) {
            _headerView.state = kPRStateNormal;
        }];
    }
}

// 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section >= _pccListData.count) {
        return;
    }
    
    id obj = _pccListData[indexPath.section];
    if ([obj isKindOfClass:[PhotoCollection class]]) {        
        Class classType = [PhotoGalleryViewController class];
        PhotoGalleryViewController *pgvc = [self findUserObject:classType];  
        if ([pgvc isKindOfClass:classType]) {

            [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:obj andWithType:kRTS_Photos and:^(BOOL succeeded) {
                
            }];
            
            // 跳转到图集内容
            PhotoCollectionContentController *controller;
            controller = [PhotoCollectionContentController new];
            controller.photoColl = obj;
//            controller.pcc = _photoCollectionChannel;
            [pgvc presentController:controller animated:PresentAnimatedStateFromRight];
        }
    }
}

#pragma mark private method

// 刷新图集列表
- (void)updatePhotoCollectionList
{
    Class classType = [PhotoCollectionListHorizontalScrollView class];
    PhotoCollectionListHorizontalScrollView* pclhsv =
    [self findUserObject:classType];
    [pclhsv performSelector:@selector(refreshPhotoCollectionList:)
                     withObject:_photoCollectionChannel];
}

// 加载更多图集列表
- (void)morePhotoCollectionList
{
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
    if (_photoCollectionChannel == nil || [pcm photoCollectionListIsLoading:_photoCollectionChannel])
    {
        return;
    }
    
  
    [pcm getMorePhotoCollectionList:_photoCollectionChannel withCompletionHandler:^(ThreadsFetchingResult *result)
    {
       if (result.channelId == _photoCollectionChannel.cid)
       {
           NSString *message;
           if ([result succeeded])
           {
               BOOL isExistMoreData = NO;
               if ([[_pccListData lastObject] isKindOfClass:[NSString class]])
               {
                   isExistMoreData = YES;
                   [_pccListData removeLastObject];   // 删除更多的那个Cell
               }
               
               
               if ([result noChanges])
               {
                   message = @"现在是最新数据";                   
                   if (isExistMoreData)
                   {
                       [_photoCollectionTableView reloadData];
                   }
               }
               else{
                   [_pccListData addObjectsFromArray:[result threads]];
                   [_pccListData addObject:@"加载更多"];
                   [_photoCollectionTableView reloadData];
                   
                   // 加载当前屏幕中的图片
                   [self performSelector:@selector(loadCellsImage) withObject:nil afterDelay:0.2];
               } 
           }
           else{
               message = @"网络异常!";
           }
            
           // 当前View在屏幕中可见，就弹出提示信息
           Class classType = [PhotoCollectionListHorizontalScrollView class];
           PhotoCollectionListHorizontalScrollView* pclhsv =
           [self findUserObject:classType];
           
           if (message && [message length] > 0) {
               id curSubsView = [pclhsv performSelector:@selector(curSubsView)];
               if (curSubsView == self) {
                   [PhoneNotification autoHideWithText:message];
               }
           }
       }
        
    }];
}

- (void)loadCellsImage{
    // 加载当前屏幕中的图片
    NSArray *cells = [_photoCollectionTableView visibleCells];    
    for (PhotoCollectionCell *c in cells)
    {
        if ([c isKindOfClass:[PhotoCollectionCell class]])
        {
            [c requestImage];
        }
    }
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    [_headerView viewNightModeChanged:isNight];
    [[_photoCollectionTableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [(UIView*)obj viewNightModeChanged:isNight];
    }];
}
@end
