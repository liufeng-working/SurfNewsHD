//
//  BelleGirlScrollView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/11/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "BelleGirlScrollView.h"
#import "SNToolBar.h"
#import "ThreadsManager.h"
#import "SNPictureSummaryView.h"
#import "BelleGirlDesView.h"
#import "PathUtil.h"
#import "EzJsonParser.h"
#import "PhoneshareWeiboInfo.h"




@interface BelleGirlScrollView () <UIScrollViewDelegate,BelleGirlDesViewDelegate, SNToolBarDelegate, BelleGirlViewDelegate>{
    
}
@end

@implementation BelleGirlScrollView {

    NSMutableArray *belleGirlThreads_Arr;
    UIScrollView *mainScrollView;
    NSUInteger belleGirl_Index;
    SNToolBar*          mToolBar;
    UIImage *_img;
    
    
    // 提示图片
    UIImageView *_left_topImage;
    UIImageView *_right_topImage;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initScrollView];
        [self initTipsView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!mToolBar) {
        mToolBar = [[SNToolBar alloc] initWithToolBarType:SNBelleGirlType thread:_selectThread];
        [mToolBar setDeletage:self];
        [self addSubview:mToolBar];
    }
    
    // 标记已读
    [[ThreadsManager sharedInstance] markThreadAsRead:_selectThread];
}



- (SNToolBar *)getSNToolBar{
    return mToolBar;
}

/**
 *  初始化提示窗口
 */
- (void)initTipsView
{
    // 图片内容简介
    if (!_tipsView) {
        _tipsView = [[SNPictureSummaryView alloc] initWithBottomY:CGRectGetHeight(self.bounds) - 44];
        _tipsView.backgroundColor = [[UIColor alloc] initWithRed:0.f green:0.f blue:0.f alpha:0.6];
        [self addSubview:_tipsView];
    }
}

-(void)initScrollView
{
    mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    mainScrollView.delegate=self;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.scrollsToTop = NO;
    mainScrollView.bounces = YES;
    mainScrollView.scrollEnabled = NO;
    [mainScrollView setShowsVerticalScrollIndicator:NO];
    [mainScrollView setShowsHorizontalScrollIndicator:NO];
    mainScrollView.contentSize = CGSizeMake(self.frame.size.width * belleGirlThreads_Arr.count, kScreenHeight);
    [self addSubview:mainScrollView];
}

// 加载美女新闻
-(void)loadBeauties:(NSArray *)beauties
           curIndex:(NSUInteger)index
{
    
//    { // test
//       NSRange r = NSMakeRange(0,2);
//       NSIndexSet *set =  [NSIndexSet indexSetWithIndexesInRange:r];
//        beauties = [[beauties objectsAtIndexes:set] mutableCopy];
//    }
    
    
    if ([beauties count] <= 0) {
        return;
    }
    
    if (index >= [beauties count]) {
        index = 0;
    }
    
    
    [self chickShowTipsImage:belleGirl_Index = index];
    _selectThread = beauties[index];
    belleGirlThreads_Arr = [beauties mutableCopy];
    [_tipsView setTitle:_selectThread.title];
    [_tipsView setDesc:_selectThread.desc];
  
    
 
  
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    if (belleGirlThreads_Arr.count == 1) {
        BelleGirlDesView* item1 = [self buildBelleGirlDesView];
        [item1 setThread:belleGirlThreads_Arr[belleGirl_Index]];
        [mainScrollView addSubview:item1];
        [mainScrollView setContentSize:CGSizeMake(width, height)];
    }
    else if(beauties.count == 2) {
        
        BelleGirlDesView* item1 = [self buildBelleGirlDesView];
        [item1 setThread:belleGirlThreads_Arr[belleGirl_Index]];
        [mainScrollView addSubview:item1];
    
        BelleGirlDesView* item2 = [self buildBelleGirlDesView];
        if (belleGirl_Index == 1) {
            [item2 setThread:belleGirlThreads_Arr[0]];
            [item1 setFrame:CGRectMake(width, 0, width, height)];
            [mainScrollView setContentOffset:CGPointMake(width, 0)];
        }
        else {
            [item2 setThread:belleGirlThreads_Arr[1]];
            [item2 setFrame:CGRectMake(width, 0, width, height)];
            [mainScrollView setContentOffset:CGPointZero];
        }
        [mainScrollView addSubview:item2];
        [mainScrollView setContentSize:CGSizeMake(width*2, height)];
    }
    else {
        BelleGirlDesView* item1 = [self buildBelleGirlDesView];
        BelleGirlDesView* item2 = [self buildBelleGirlDesView];
        BelleGirlDesView* item3 = [self buildBelleGirlDesView];
        [mainScrollView addSubview:item1];
        [mainScrollView addSubview:item2];
        [mainScrollView addSubview:item3];
        
        if (belleGirl_Index == 0) {
            [item1 setThread:belleGirlThreads_Arr[0]];
            [item2 setThread:belleGirlThreads_Arr[1]];
            [item3 setThread:belleGirlThreads_Arr[2]];
            
            CGPoint centerP = mainScrollView.center;
            [item1 setCenter:centerP];
            centerP.x += width;
            [item2 setCenter:centerP];
            centerP.x += width;
            [item3 setCenter:centerP];
            
            [mainScrollView setContentOffset:CGPointZero];
        }
        else if(belleGirl_Index == [belleGirlThreads_Arr count]-1){
            [item1 setThread:belleGirlThreads_Arr[belleGirl_Index-2]];
            [item2 setThread:belleGirlThreads_Arr[belleGirl_Index-1]];
            [item3 setThread:belleGirlThreads_Arr[belleGirl_Index]];
            
            CGPoint centerP = mainScrollView.center;
            [item1 setCenter:centerP];
            centerP.x += width;
            [item2 setCenter:centerP];
            centerP.x += width;
            [item3 setCenter:centerP];
            
            [mainScrollView setContentOffset:CGPointMake(width+width, 0)];
            
            // 加载更多美女图片
            if ([_delegate respondsToSelector:@selector(snRequestMoreBeauties)]) {
                [_delegate snRequestMoreBeauties];
            }
        }
        else {
            [item1 setThread:belleGirlThreads_Arr[belleGirl_Index-1]];
            [item2 setThread:belleGirlThreads_Arr[belleGirl_Index]];
            [item3 setThread:belleGirlThreads_Arr[belleGirl_Index+1]];
            
            CGPoint centerP = mainScrollView.center;
            [item1 setCenter:centerP];
            centerP.x += width;
            [item2 setCenter:centerP];
            centerP.x += width;
            [item3 setCenter:centerP];
            
            [mainScrollView setContentOffset:CGPointMake(width, 0)];
        }
        [mainScrollView setContentSize:CGSizeMake(width*3, height)];
    }
}

-(void)loadMoreBeauties:(NSArray*)beauties
{
    if ([beauties count] <= 0 &&
        [belleGirlThreads_Arr count] > 2) {
        return;
    }
    
    
    [belleGirlThreads_Arr addObjectsFromArray:beauties];
    
    
    // 如果已经滑到最后
    if([self curScrollViewPage] == 2 &&
       belleGirl_Index < [belleGirlThreads_Arr count] -1) {
        
        UIView *item0 = [self viewerAtPage:0];
        UIView *item1 = [self viewerAtPage:1];
        UIView *item2 = [self viewerAtPage:2];
        [self moveViewer:item0 toPage:2];
        [self moveViewer:item1 toPage:0];
        [self moveViewer:item2 toPage:1];
        
        [(BelleGirlDesView*)item0 setThread:belleGirlThreads_Arr[belleGirl_Index+1]];
        
        CGFloat width = CGRectGetWidth(mainScrollView.bounds);
        [mainScrollView setContentOffset:CGPointMake(width, 0)];
    }
}

/**
 *  创建美女详情窗口
 *
 *  @return 美女详情窗口
 */
-(BelleGirlDesView*)buildBelleGirlDesView
{
    BelleGirlDesView *b =
    [[BelleGirlDesView alloc] initWithFrame:self.bounds];
    b.delegate = self;
    return b;
}


- (void)changeToolsBar:(ThreadSummary *)thread
{
    if (mToolBar) {
        [mToolBar changeBarType:SNBelleGirlType thread:thread];
        [mToolBar viewNightModeChanged:[[ThemeMgr sharedInstance] isNightmode]];
    }
}

- (UIImage *)getImageFromThread:(ThreadSummary *)ts
{
    _img = nil;
    NSString *imgPath = [PathUtil pathOfThreadLogo:ts];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 图片文件不存在
    if (![fm fileExistsAtPath:imgPath])
    {
        return _img;
    }
    else{
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        _img = [UIImage imageWithData:imgData];
        return _img;
    }
}

/**
 *  检查是否需要提示图片
 *
 *  @param index 当前图片下标
 */
-(void)chickShowTipsImage:(NSInteger)index
{
    if (index >0 && index < [belleGirlThreads_Arr count]-1) {
        [self showTopLeftImage:NO];
        [self showTopRightImage:NO];
    }
    else {
        // 检查是否需要显示提示图片
        if(index == 0){
            [self showTopLeftImage:YES];
        }
        
        if(index == [belleGirlThreads_Arr count]-1){
            [self showTopRightImage:YES];
        }
    }
}

// 显示滑动到最左边的提示图片
-(void)showTopLeftImage:(BOOL)isShow
{
    if (isShow) {
        if (!_left_topImage) {
            // 滑到最左边没有图片的提示
            CGFloat halfH = CGRectGetHeight(self.bounds) / 2;
            UIImage *lImg = [UIImage imageNamed:@"belleGirl_left_Top"];
            
            _left_topImage =
            [[UIImageView alloc] initWithImage:lImg];
            _left_topImage.center = CGPointMake(lImg.size.width/2, halfH - 50);
            [mainScrollView insertSubview:_left_topImage atIndex:0] ;
        }
    }
    else {
        [_left_topImage removeFromSuperview];
        _left_topImage = nil;
    }
}

-(void)showTopRightImage:(BOOL)isShow
{
    if (isShow) {
        if (!_right_topImage) {
            CGFloat width = mainScrollView.contentSize.width;
            CGFloat halfH = CGRectGetHeight(self.bounds) / 2;
            
            UIImage *rImg = [UIImage imageNamed:@"belleGirl_right_Top"];
            // 滑到最右边没有图片的提示
            _right_topImage =
            [[UIImageView alloc] initWithImage:rImg];
            _right_topImage.center =
            CGPointMake(width-rImg.size.width/2, halfH - 50);
            [mainScrollView insertSubview:_right_topImage atIndex:0];
        }
    }
    else {
        [_right_topImage removeFromSuperview];
        _right_topImage = nil;
    }
}

#pragma mark BelleGirlDesViewDelegate
- (void)nextRight
{
    if (belleGirl_Index >= belleGirlThreads_Arr.count - 1) {
        return;
    }
    
    
    [self chickShowTipsImage:++belleGirl_Index];
    _selectThread = (ThreadSummary *)[belleGirlThreads_Arr objectAtIndex:belleGirl_Index];
    [_tipsView setTitle:_selectThread.title];
    [_tipsView setDesc:_selectThread.desc];
    [self changeToolsBar:_selectThread];
    

    CGFloat width = CGRectGetWidth(self.bounds);
    NSInteger curPage = [self curScrollViewPage];
    if (curPage < 2) {
        [UIView animateWithDuration:0.3 animations:^{
            [mainScrollView setContentOffset:CGPointMake((curPage+1)*width, 0)];
        } completion:^(BOOL finished) {
            if ([self curScrollViewPage] == 2 &&
                belleGirl_Index < [belleGirlThreads_Arr count] -1) {
                UIView *item0 = [self viewerAtPage:0];
                UIView *item1 = [self viewerAtPage:1];
                UIView *item2 = [self viewerAtPage:2];
                [self moveViewer:item0 toPage:2];
                [self moveViewer:item1 toPage:0];
                [self moveViewer:item2 toPage:1];
                
                [(BelleGirlDesView*)item0 setThread:belleGirlThreads_Arr[belleGirl_Index+1]];
                
                [mainScrollView setContentOffset:CGPointMake(curPage*width, 0)];
            }
            
            // 检查是否需要下载更多美女新闻
            if([belleGirlThreads_Arr count]-belleGirl_Index <= 3){
                if ([_delegate respondsToSelector:@selector(snRequestMoreBeauties)]) {
                    [_delegate snRequestMoreBeauties];
                }
            }
        }];
    }

}

- (void)priorLeft
{
    if (belleGirl_Index == 0) {
        return;
    }
    
    
    [self chickShowTipsImage:--belleGirl_Index];
    _selectThread = (ThreadSummary *)[belleGirlThreads_Arr objectAtIndex:belleGirl_Index];
    [_tipsView setTitle:_selectThread.title];
    [_tipsView setDesc:_selectThread.desc];
    [self changeToolsBar:_selectThread];
    
    
    CGFloat width = CGRectGetWidth(mainScrollView.bounds);
    NSInteger curPage = [self curScrollViewPage];
    if (curPage > 0) {
        
        [UIView animateWithDuration:0.3 animations:^{
            [mainScrollView setContentOffset:CGPointMake((curPage-1)*width, 0)];
        } completion:^(BOOL finished) {
            if ([self curScrollViewPage] == 0 &&
                belleGirl_Index > 0) {
            
                UIView *item0 = [self viewerAtPage:0];
                UIView *item1 = [self viewerAtPage:1];
                UIView *item2 = [self viewerAtPage:2];
                
                
                [self moveViewer:item0 toPage:1];
                [self moveViewer:item1 toPage:2];
                [self moveViewer:item2 toPage:0];
                
                [(BelleGirlDesView*)item2 setThread:belleGirlThreads_Arr[belleGirl_Index-1]];
                
                [mainScrollView setContentOffset:CGPointMake(curPage*width, 0)];
            }
            
        }];
        
    }
}

-(NSInteger)curScrollViewPage
{
    CGFloat width = CGRectGetWidth([mainScrollView bounds]);
    return floor((mainScrollView.contentOffset.x - width / 2) / width) + 1;
}

/**
 将某个viewer放置在某个page处
 */
- (void)moveViewer:(UIView*)v toPage:(int)p
{
    if(p < 0 || p > 2) return;
    CGRect frame = v.frame;
    frame.origin.x = p * frame.size.width;
    v.frame = frame;
}

/**
 获取指定页的SNWebViewer
 */
- (BelleGirlDesView*)viewerAtPage:(int)p
{
    if(p > 3 || p < 0) return nil;
    
    CGFloat width = CGRectGetWidth(mainScrollView.bounds);
    for (BelleGirlDesView* v in [mainScrollView subviews]) {
        if ([v isKindOfClass:[BelleGirlDesView class]]) {
            if(v.frame.origin.x == p * width) {
                return v;
            }
        }
    }
    return nil;
}

-(void)sortBelleDesView
{
    
}

/**
 *  美女详情界面喜欢按钮被点击
 */
- (void)didBelleGirlDesViewToolBarBelleGirlBt:(ThreadSummary*)ts
{
    [self toolBarActionLikeBelleGirl:ts];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)pageScroll{
    
}

#pragma mark-- SNToolBarDelegate
-(void)toolBarActionFontSizeChanged:(float)size{}
-(void)toolBarActionNightModeChanged:(BOOL)night{}
-(void)toolBarActionRefresh{}
-(void)toolBarActionEnergy:(ThreadSummary *)ts{}
-(void)toolBarGotoLogin{}
-(void)toolBarActionReport:(ThreadSummary *)ts{}
-(NSString*)toolBarActionGetWeiboContent{return nil;}
-(NSMutableArray*)getContentImgArr{return nil;}

- (void)toolBarActionShare:(ThreadSummary *)ts{
    // 分享图片到微博
    if([self getImageFromThread:ts]){
        PhoneshareWeiboInfo *info = [[PhoneshareWeiboInfo alloc]initWithWeiboSource:kWeiboData_BeautyCell];
        [info setThread:ts isShareEnergy:NO];
        [info setPicture:_img];
        info.showWeiboType = kWeixin|kWeiXinFriendZone|kSinaWeibo|kQQFriend|kQZone;
        if ([_delegate respondsToSelector:@selector(didShareBt:)]) {
            [_delegate didShareBt:info];
        }
    }
    else {
        [PhoneNotification autoHideWithText:@"无法分享，没有图像数据"];
    }
}

-(void)toolBarActionExit
{
    if ([_delegate respondsToSelector:@selector(didBackBt)]) {
        [_delegate didBackBt];
    }
}

- (void)toolBarActionBelleGirlDown:(ThreadSummary *)ts{
    [[RealTimeStatisticsManager sharedInstance] sendRealTimeBelleGirlActionStatistics:ts andWithType:kBelleGirl_Save and:^(BOOL succeeded) {
        
    }];
    
    // 保存图片到相册中
    if([self getImageFromThread:ts]){
        SEL completionSelector = @selector(saveImagecompletion:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(_img, self,completionSelector, nil);
    }
    else {
        [PhoneNotification autoHideWithText:@"无法保存，没有图像数据"];
    }
    
}

/**
 *  工具栏加载更多按钮点击
 *
 *  @param ts 新闻信息
 */
- (void)toolBarActionBelleMore:(ThreadSummary *)ts
{
    BelleGirlView *belleView = [[BelleGirlView alloc] initWithFrame:self.bounds];
    [belleView setDelegate:self];
    [self addSubview:belleView];
}

- (void)toolBarActionLikeBelleGirl:(ThreadSummary *)ts
{
    if ([[ThreadsManager sharedInstance] isThreadRated:ts]) {
        [PhoneNotification autoHideWithText:@"太心急啦!只能赞一次,换张美女图片试试吧"];
        return;
    }
    
    RealTimeStatisticsManager *rsm =
    [RealTimeStatisticsManager sharedInstance];
    

    if ([rsm isBusy]) {
        return;
    }
    
    
    [rsm sendRealTimeBelleGirlActionStatistics:ts
                                   andWithType:kBelleGirl_Intimacy
                                           and:^(BOOL succeeded) {
        if (succeeded) {
            [PhoneNotification autoHideWithText:@"亲密度增加~"];
            [[ThreadsManager sharedInstance] markThreadAsRated:ts];
            ts.intimacyDegree = ts.intimacyDegree + 1;
            [[EzJsonParser serializeObjectWithUtf8Encoding:ts] writeToFile:[PathUtil pathOfThreadInfo:ts] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            
            // TODO:刷新工具栏点赞按钮
            [mToolBar setLikeGirlBt];
            
            // 更新点赞总数
            [[self viewerAtPage:0] updateState];
            [[self viewerAtPage:1] updateState];
            [[self viewerAtPage:2] updateState];
        }
        else
            [PhoneNotification autoHideWithText:@"与美女亲密错误噢~"];
    }];
}

- (void)saveImagecompletion:(UIImage *)image
   didFinishSavingWithError:(NSError *)error
                contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL){
        // Show error message...
        [PhoneNotification autoHideWithText:@"保存失败！"];
    }
    else{
        [PhoneNotification autoHideWithText:@"保存成功！"];
    }
}


#pragma mark BelleGirlViewDelegate
- (void)removeBelleView:(BelleGirlView *)belleView{
    [belleView removeFromSuperview];
}

- (void)clickBt:(BelleMore_type)index{
    if (Belle_hate == index) {
        if (_selectThread.belleGirl_hate) {
            [PhoneNotification autoHideWithText:@"您的信息已提交,将减少推荐类似图片信息"];
        }
        else{
            [[RealTimeStatisticsManager sharedInstance] sendRealTimeBelleGirlActionStatistics:_selectThread andWithType:kBelleGirl_Hate and:^(BOOL succeeded) {
                if (succeeded) {
                    _selectThread.belleGirl_hate = 1;
                    [[EzJsonParser serializeObjectWithUtf8Encoding:_selectThread] writeToFile:[PathUtil pathOfThreadInfo:_selectThread] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [PhoneNotification autoHideWithText:@"您的信息已提交,将减少推荐类似图片信息"];
                }
            }];
        }
    }
    else{
        if (_selectThread.belleGirl_report) {
            [PhoneNotification autoHideWithText:@"我们会尽快处理,避免类似信息发布"];
        }
        else{
            [[RealTimeStatisticsManager sharedInstance] sendRealTimeBelleGirlActionStatistics:_selectThread andWithType:kBelleGirl_Report and:^(BOOL succeeded) {
                if (succeeded) {
                    _selectThread.belleGirl_report = 1;
                    [[EzJsonParser serializeObjectWithUtf8Encoding:_selectThread] writeToFile:[PathUtil pathOfThreadInfo:_selectThread] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    
                    [PhoneNotification autoHideWithText:@"我们会尽快处理,避免类似信息发布"];
                }
            }];
        }
    }
}

@end
