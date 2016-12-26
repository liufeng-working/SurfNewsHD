//
//  PhotoCollectionListHorizontalScrollView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionListHorizontalScrollView.h"
#import "PhotoCollectionListView.h"
#import "PhotoCollectionManager.h"
#import "ThreadsManager.h"
#import "PhotoGalleryViewController.h"

#define TopRefreshDateSpace 15

@implementation PhotoCollectionListHorizontalScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect scrollRect = self.bounds;
        _horizontalScrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
        _horizontalScrollView.delegate = self;
        _horizontalScrollView.bounces = YES;
        _horizontalScrollView.pagingEnabled = YES;
        _horizontalScrollView.showsHorizontalScrollIndicator = NO;
        _horizontalScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_horizontalScrollView];
        

        CGRect viewRect = self.bounds;
        _subView1 =[[PhotoCollectionListView alloc] initWithFrame:viewRect];
        viewRect.origin.x += viewRect.size.width;
        _subView2 = [[PhotoCollectionListView alloc] initWithFrame:viewRect];
        viewRect.origin.x += viewRect.size.width;
        _subView3 = [[PhotoCollectionListView alloc] initWithFrame:viewRect];
        [_horizontalScrollView addSubview:_subView1];
        [_horizontalScrollView addSubview:_subView2];
        [_horizontalScrollView addSubview:_subView3];
        
        _pcm = [PhotoCollectionManager sharedInstance];
    }
    return self;
}

- (void)reloadDataWithPhotoCollectionChannel:(PhotoCollectionChannel*)pcc
{
    if (pcc == nil) {
        return;
    }
    
    NSArray *tempChannelList = _pcm.photoCollecChannelList;
    NSUInteger idx = [tempChannelList indexOfObject:pcc];
    if (idx == NSNotFound) {
        return;
    }
    
    _curIndex = idx;
    NSUInteger subViewIndex1=0,subViewIndex2=0,subViewIndex3=0;
    switch (tempChannelList.count) {
        case 1:
        {
            _horizontalScrollView.contentOffset = CGPointZero;
            _horizontalScrollView.contentSize = self.bounds.size;
            
            if (_subView2){
                [_subView2 removeFromSuperview];
            }
            if (_subView3) {
                [_subView3 removeFromSuperview];
            }
            
            
            _subView1.tag = subViewIndex1;
            PhotoCollectionChannel *pcc1 = tempChannelList[subViewIndex1];
            [self reloadSubViewDate:_subView1 photoCollectionChannel:pcc1];
            break;
        }
        case 2:
        {
            subViewIndex1 = 0;
            subViewIndex2 = 1;
            float contentWidth = CGRectGetWidth(_horizontalScrollView.bounds);
            float contentHeight = CGRectGetHeight(_horizontalScrollView.bounds);
            if (idx == 0) {
                _horizontalScrollView.contentOffset = CGPointZero;
            }else{
                _horizontalScrollView.contentOffset = CGPointMake(contentWidth, 0);
            }
            _horizontalScrollView.contentSize = CGSizeMake(contentWidth * 2, contentHeight);
            
            // 移除多余的View
            if (_subView3) {
                [_subView3 removeFromSuperview];
            }
            
            // 添加需要的subsView
            if (![[_horizontalScrollView subviews] containsObject:_subView2]) {
                [_horizontalScrollView addSubview:_subView2];
            }
            
            _subView1.tag = subViewIndex1;
            _subView2.tag = subViewIndex2;
            PhotoCollectionChannel *pcc1 = tempChannelList[subViewIndex1];
            PhotoCollectionChannel *pcc2 = tempChannelList[subViewIndex2];
            [self reloadSubViewDate:_subView1 photoCollectionChannel:pcc1];
            [self reloadSubViewDate:_subView2 photoCollectionChannel:pcc2];
            break;
        }
        default:
        {
            float contentWidth = CGRectGetWidth(_horizontalScrollView.bounds);
            float contentHeight = CGRectGetHeight(_horizontalScrollView.bounds);
            if (idx == 0) {
                subViewIndex1 = 0;
                subViewIndex2 = 1;
                subViewIndex3 = 2;
                _horizontalScrollView.contentOffset = CGPointZero;
                
            }
            else if (idx == tempChannelList.count - 1){                
                subViewIndex1 = idx-2;
                subViewIndex2 = idx-1;
                subViewIndex3 = idx;
                _horizontalScrollView.contentOffset = CGPointMake(contentWidth * 2, 0);
                
            }
            else{                
                subViewIndex1 = idx-1;
                subViewIndex2 = idx;
                subViewIndex3 = idx+1;
                _horizontalScrollView.contentOffset = CGPointMake(contentWidth, 0);
            }
            
            
            // 添加有可能移除的subsView
            if (![[_horizontalScrollView subviews] containsObject:_subView2]) {
                [_horizontalScrollView addSubview:_subView2];
            }
            if (![[_horizontalScrollView subviews] containsObject:_subView3]) {
                [_horizontalScrollView addSubview:_subView3];
            }
            
            
            _subView1.tag = subViewIndex1;
            _subView2.tag = subViewIndex2;
            _subView3.tag = subViewIndex3;
            PhotoCollectionChannel *pcc1 = tempChannelList[subViewIndex1];
            PhotoCollectionChannel *pcc2 = tempChannelList[subViewIndex2];
            PhotoCollectionChannel *pcc3 = tempChannelList[subViewIndex3];            
            [self reloadSubViewDate:_subView1 photoCollectionChannel:pcc1];
            [self reloadSubViewDate:_subView2 photoCollectionChannel:pcc2];
            [self reloadSubViewDate:_subView3 photoCollectionChannel:pcc3];
            _horizontalScrollView.contentSize = CGSizeMake(contentWidth * 3, contentHeight);
            break;
        }
    }
    
    // 只刷新当前的图集列表
    [self refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd];
    
}


// 图集频道列表刷新完，使用这个函数（会根据刷新时间间隔来决定是否需要刷新图集列表）
- (void)refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd
{
    if (!_pcclRefreshEnd) return;
    
    
    PhotoCollectionListView * pclv = [self curSubsView];    
    PhotoCollectionChannel *pcc = pclv.photoCollectionChannel;
    if (pcc==nil || pcc.cid == 0) {
        return;
    }
    
    // 更新时间大于我们设定的时间段，就更新
    NSDate *refreshDate = [_pcm lastRefreshDateOfPhotoCollectionChannel:pcc]; 
    BOOL isLoad = (refreshDate == nil) ? YES : NO;
    if (!isLoad){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
        NSDateComponents *dateComponents = [calendar components:flags
                                                       fromDate:refreshDate
                                                         toDate:[NSDate date] options:0];
        if (dateComponents.minute >= TopRefreshDateSpace || dateComponents.hour != 0 ||
            dateComponents.day != 0 || dateComponents.month != 0 || dateComponents.year != 0 ) {
            isLoad = YES;
        }
    }
    if (isLoad && ![_pcm photoCollectionListIsLoading:pcc])
    {
        [pclv setRefreshState];
        [self refreshPhotoCollectionList:pcc];
    }
}
// 重新加载当前图集频道数据
- (void)reloadCurrentPhotoCollectionChannel
{
    PhotoCollectionListView *curView = [self curSubsView];
    PhotoCollectionChannel *pcc = curView.photoCollectionChannel;
    NSUInteger oldPCCount = [curView photoCollectionCount];
    NSUInteger newPCCount = [_pcm loadLocalPhotoCollectionListForPCC:pcc].count;    
    if (oldPCCount != newPCCount) {
        [self reloadSubViewDate:curView photoCollectionChannel:pcc];
    }
}

// 当前视图显示的频道
-(PhotoCollectionChannel*)currentViewShowPCC
{
   return [self curSubsView].photoCollectionChannel; 
}

// 频道顺序发生改变
- (void)photoCollectionChannelOrderChanned:(PhotoCollectionChannel*)curPcc
{
    NSArray *tempChannelList = _pcm.photoCollecChannelList;

    // 一个一个View的检查
    NSUInteger idx1 = [tempChannelList indexOfObject:_subView1.photoCollectionChannel];
    NSUInteger idx2 = [tempChannelList indexOfObject:_subView2.photoCollectionChannel];
    NSUInteger idx3 = [tempChannelList indexOfObject:_subView3.photoCollectionChannel];
    if (_subView1.tag != idx1 || _subView2.tag != idx2 || _subView3.tag != idx3)
    {
        [self reloadDataWithPhotoCollectionChannel:curPcc];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = NO;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self scrollViewEnd:scrollView];
    }
}

// 滚动窗口滑动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewEnd:scrollView];
}


- (void)scrollViewEnd:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = YES;
    CGFloat width = CGRectGetWidth([scrollView bounds]);
    int viewIndex = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    if (viewIndex == 0) {
        if (_curIndex != _subView1.tag) {
            _curIndex = _subView1.tag;
            [self pageMoveToRight:scrollView];
            [self notifyHotChannelChanged];
        }
    }
    else if (viewIndex == 2) {
        if (_curIndex != _subView3.tag) {
            _curIndex = _subView3.tag;
            [self pageMoveToLeft:scrollView];
            [self notifyHotChannelChanged];
        }
    }
    else{
        if (_curIndex != _subView2.tag) {
            _curIndex = _subView2.tag;
            [self refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd];
            [self notifyHotChannelChanged];
        }
    }
}

#pragma mark private method
// 获取当前的subsView
-(PhotoCollectionListView*)curSubsView{
    CGFloat width = CGRectGetWidth(_horizontalScrollView.bounds);
    int viewIndex = floor((_horizontalScrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    if (viewIndex == 0)
        return _subView1;
    else if (viewIndex == 1)
        return _subView2;
    else if (viewIndex == 2)
        return _subView3;
    return nil;
}


// 给一个子屏幕加载数据
-(void)reloadSubViewDate:(PhotoCollectionListView*)pclv photoCollectionChannel:(PhotoCollectionChannel*)pcc
{
    if (_pcm == nil) return;        
        
    // 使用本地数据
    NSDate *refreshDate = [_pcm lastRefreshDateOfPhotoCollectionChannel:pcc];
    NSArray *pcList = [_pcm loadLocalPhotoCollectionListForPCC:pcc];
    [pclv reloadDataWithPhotoCollectionChannel:pcc photoCollectionList:pcList refreshDate:refreshDate];
    [pclv scrollOffsetY:pcc.listScrollOffsetY];
}


// 刷新图集列表
- (void)refreshPhotoCollectionList:(PhotoCollectionChannel*)pcc
{
    if (_pcm == nil || [_pcm photoCollectionListIsLoading:pcc]) {
        return;
    }
    
    
    [_pcm refreshPhotoCollectionList:pcc withCompletionHandler:^(ThreadsFetchingResult *result)
    {        
        PhotoCollectionChannel *tempPCC = nil;
        PhotoCollectionListView *tempSubsView = nil;
        

        if (_subView1.photoCollectionChannel.cid == result.channelId) {
            tempSubsView = _subView1;
            tempPCC = _subView1.photoCollectionChannel;
        }
        else if(_subView2.photoCollectionChannel.cid == result.channelId){
            tempSubsView = _subView2;
            tempPCC = _subView2.photoCollectionChannel;
        }
        else if(_subView3.photoCollectionChannel.cid == result.channelId){
            tempSubsView = _subView3;
            tempPCC = _subView3.photoCollectionChannel;
        }
        

        
        if (tempPCC != nil)
        {
            NSString *message;
            NSDate* refreshDate = [_pcm lastRefreshDateOfPhotoCollectionChannel:tempPCC];
            
            if ([result succeeded])
            {
                if ([result noChanges])
                {
                    message = @"现在是最新数据";
                    [tempSubsView updateRefreshDate:refreshDate];// 修改刷新时间
                }
                else{                   
                    [tempSubsView reloadDataWithPhotoCollectionChannel:tempPCC
                                                   photoCollectionList:[result threads]
                                                           refreshDate:refreshDate];
                }
            }
            else{
                message = @"网络异常!";
            }
            
            // 如果出现提示消息是当前显示的View,就提示用户。
            if ([self curSubsView] == tempSubsView && message.length > 0) {
                [PhoneNotification autoHideWithText:message];
            }
        }
        [tempSubsView cancelRefreshState:YES];
    }];
}

- (void)pageMoveToRight:(UIScrollView*)scrollView
{
    NSInteger idex = [_subView1 tag];
    if (idex > 0 && idex < _pcm.photoCollecChannelList.count) {
        CGRect rect1 = _subView1.frame;
        CGRect rect2 = _subView2.frame;
        CGRect rect3 = _subView3.frame;
        
        PhotoCollectionListView* tempView = _subView1;
        _subView1 = _subView3;
        _subView3 = _subView2;
        _subView2 = tempView;
        
        [_subView1 setFrame:rect1];
        [_subView2 setFrame:rect2];
        [_subView3 setFrame:rect3];
        
        _subView1.tag = --idex;
        PhotoCollectionChannel *pcc = _pcm.photoCollecChannelList[idex];
        [self reloadSubViewDate:_subView1 photoCollectionChannel:pcc];        
        float offWidth = CGRectGetWidth(scrollView.bounds);
        [scrollView setContentOffset:CGPointMake(offWidth, 0.f)];
    }
    [self refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd];
}
- (void)pageMoveToLeft:(UIScrollView*)scrollView
{
    NSInteger idex = _subView3.tag;
    if (idex > 0 && idex < _pcm.photoCollecChannelList.count-1) {
        CGRect rect1 = _subView1.frame;
        CGRect rect2 = _subView2.frame;
        CGRect rect3 = _subView3.frame;
        
        PhotoCollectionListView* tempView = _subView1;
        _subView1 = _subView2;
        _subView2 = _subView3;
        _subView3 = tempView;
        
        [_subView1 setFrame:rect1];
        [_subView2 setFrame:rect2];
        [_subView3 setFrame:rect3];
        
        _subView3.tag = ++idex;        
        PhotoCollectionChannel *pcc = _pcm.photoCollecChannelList[idex];
        [self reloadSubViewDate:_subView3 photoCollectionChannel:pcc];
        float offWidth = CGRectGetWidth(scrollView.bounds);
        [scrollView setContentOffset:CGPointMake(offWidth, 0.f)];
    }
    [self refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd];
}

- (void)notifyHotChannelChanged
{
    Class classType = [PhotoGalleryViewController class];
    PhotoGalleryViewController *controller = [self findUserObject:classType];
    if ([controller isKindOfClass:classType]) {
        [controller showPhotoCollectionChanged:[self currentViewShowPCC]];
    }
}

- (void)viewNightModeChanged:(BOOL)isNight
{
    [_subView1 viewNightModeChanged:isNight];
    [_subView2 viewNightModeChanged:isNight];
    [_subView3 viewNightModeChanged:isNight];
}
@end
