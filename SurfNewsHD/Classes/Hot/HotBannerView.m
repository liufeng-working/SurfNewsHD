//
//  HotBannerView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotBannerView.h"
#import "BannerViewCell.h"
#import "HotChannelsView.h"

#ifdef ipad
    #define kTableHeight 287.0f
    #define kPageCtrlHeight 30.0f       // UIPageControl高度
    #define TimeInterval 5.0f           // 定时器间隔时间
    #define kTitleColor 0xff8c8d8e
#else
    #define kTableHeight 160.0f
    #define kPageCtrlHeight 0.0f       // UIPageControl高度
    #define TimeInterval 5.0f           // 定时器间隔时间
    #define kTitleColor 0xFFFFFFFF
#endif

@implementation MyScrollView

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if (event.type == UIEventTypeTouches &&
        [view isKindOfClass:[BannerViewCell class]]){
         BannerViewCell *cell = (BannerViewCell *)view;
        ThreadSummary *ts = cell.bannerData.threadSummary;
        
        // 传递给浏览器
        UIView *view = [[[self superview] superview] superview];
        if ([view isKindOfClass:[HotChannelsView class]]) {
            if ([((HotChannelsView*)view).delegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
                [((HotChannelsView*)view).delegate readThreadContent:view threadSummary:ts];
            }
            return NO;
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

@end



@implementation HotBannerView
+ (NSInteger)hotBannerHeight{
    return kTableHeight + kPageCtrlHeight;
}
- (id)initWithFrame:(CGRect)frame
{    
    if (self = [super initWithFrame:frame])
    {
        // Initialization code
        CGRect rect = CGRectMake(.0f, .0f, CGRectGetWidth(frame) + 8.f, kTableHeight);
        scrollView = [[MyScrollView alloc] initWithFrame:rect];
        scrollView.delegate = self;
        [scrollView setPagingEnabled:YES];
        [scrollView setBounces:NO]; // 不要弹跳
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setContentSize:CGSizeMake(3 * rect.size.width, rect.size.height)];
        [self addSubview:scrollView];
        
        // 添加3个窗口
        rect = CGRectMake(0.f, 0.f, CGRectGetWidth(frame), kTableHeight);
        UIView *view = [[BannerViewCell alloc]initWithFrame:rect];
        [scrollView addSubview:view];
        
        rect.origin.x += CGRectGetWidth([scrollView bounds]);
        view = [[BannerViewCell alloc]initWithFrame:rect];
        [scrollView addSubview:view];

        rect.origin.x += CGRectGetWidth([scrollView bounds]);
        view = [[BannerViewCell alloc]initWithFrame:rect];
        [scrollView addSubview:view];
        
#ifdef ipad      
        float titleHeight = 35.f;
        rect = [scrollView bounds];
        rect.origin.y += rect.size.height - titleHeight;
        rect.size.height = titleHeight;
        UIView *titleBG = [[UIView alloc] initWithFrame:rect];
        titleBG.backgroundColor = [UIColor colorWithWhite:.0 alpha:0.65];
        [self addSubview:titleBG];
        
        
        rect.origin.x += 15.f;
        rect.size.width = 400.f;
        titleView = [[UILabel alloc] initWithFrame:rect];
        titleView.textColor = [UIColor colorWithHexValue:kTitleColor];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont systemFontOfSize:18.f];
        [self addSubview:titleView];
        
        // 虚线
        rect = CGRectMake(.0f, CGRectGetHeight(frame)-2.f, CGRectGetWidth(frame), 2.f);
        UIView *dottedView = [[UIView alloc] initWithFrame:rect];
        dottedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dottedLine"]] ;
        [self addSubview:dottedView];
#else
        float bgHeight = 25.f;
        rect = [scrollView bounds];
        rect.origin.y += rect.size.height - bgHeight;
        rect.size.height = bgHeight;
        UIView *titleBG = [[UIView alloc] initWithFrame:rect];
        titleBG.backgroundColor = [UIColor colorWithHexValue:0xCC2B2B2B];
        [self addSubview:titleBG];
        
        
        rect.origin.x += 8.f;
        rect.size.width = 200.f;
        titleView = [[UILabel alloc] initWithFrame:rect];
        titleView.textColor = [UIColor colorWithHexValue:kTitleColor];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont systemFontOfSize:15.f];
        [self addSubview:titleView];
#endif
        
        //UIPageControl
        pageCtrl = [[SNPageControl alloc] init];
        pageCtrl.hidesForSinglePage = YES;        // 如何是一个的话，就隐藏。
        pageCtrl.userInteractionEnabled = NO;     // 忽略按键事件。
        pageCtrl.dotColorCurrentPage = [UIColor colorWithHexValue:0xffAD2F2F];
        pageCtrl.dotColorOtherPage = [UIColor whiteColor];
        [self addSubview:pageCtrl];

        // 数据池
        bannerDataPool = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    [self stopTimer];
}

- (void)reloadData:(NSArray *)picNews isVodel:(BOOL)isV
{
    
    [self stopTimer];
    _isVodel = isV;
    [bannerDataPool removeAllObjects]; //删除所有对象
    for(ThreadSummary* ts in picNews){
        if(ts.isPicThread){  // 图片数据的缓存池
            [bannerDataPool addObject:[[BannerData alloc] initWithThreadSummary:ts]];
        }
    }
    
    // 获取ScrollView中的BannerViewCell类
    NSMutableArray *subsViews = [NSMutableArray arrayWithCapacity:3];
    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[BannerViewCell class]]) {
            [subsViews addObject:obj];
        }
    }];
    
    // 清空bannerView数据
    [subsViews makeObjectsPerformSelector:@selector(reloadData: isVodel:) withObject:nil];
    
    // 对subsViews排序
    [subsViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([(UIView*)obj1 frame].origin.x > [(UIView*)obj2 frame].origin.x) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    
    // 设置Scroll状态
    NSUInteger bannerCount = bannerDataPool.count;
    CGSize scrollSize = scrollView.bounds.size;
    if(bannerCount == 0) {
        [scrollView setContentSize:CGSizeMake(scrollSize.width, scrollSize.height)];
    }
    else if(bannerCount == 1) {
        // 为了不让它滚动，
        [scrollView setContentSize:CGSizeMake(scrollSize.width, scrollSize.height)];
        scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
        BannerViewCell *cell = [subsViews objectAtIndex:0];
        BannerData *bd = bannerDataPool[0];
        bd.isApply = YES;
        [cell reloadData:bd isVodel:isV];
        titleView.text = bd.title;
    }
    else if(bannerCount >= 2) {
        BannerViewCell *cell0 = [subsViews objectAtIndex:0];
        BannerViewCell *cell1 = [subsViews objectAtIndex:1];
        BannerViewCell *cell2 = [subsViews objectAtIndex:2];
        
        BannerData *data0 = bannerDataPool[bannerCount-1];
        BannerData *data1 = bannerDataPool[0];
        BannerData *data2 = bannerDataPool[1];
        data0.isApply = data1.isApply = data2.isApply = YES;
        
        
        [scrollView setContentSize:CGSizeMake(3 * scrollSize.width, scrollSize.height)];
        scrollView.contentOffset = CGPointMake(scrollSize.width, 0.0f);        
        [cell0 reloadData:data0 isVodel:isV];
        [cell1 reloadData:data1 isVodel:isV];
        [cell2 reloadData:data2 isVodel:isV];
        titleView.text = data1.title;   // 设置标题
    }
    
    // 设置UIPageControl
    pageCtrl.numberOfPages = bannerCount;
    pageCtrl.currentPage = 0;
 
#ifdef ipad
    CGSize superSize = [self bounds].size;
    CGSize pageSize = [pageCtrl sizeForNumberOfPages:bannerCount];
    pageCtrl.frame = CGRectMake((superSize.width - pageSize.width)*0.5f,
                                superSize.height - kPageCtrlHeight-10.f,
                                pageSize.width, pageSize.height);
#else
    CGSize superSize = [self bounds].size;
    CGSize pageSize = [pageCtrl sizeForNumberOfPages:bannerCount];
    pageSize.height = CGRectGetHeight(titleView.bounds);
    pageCtrl.frame = CGRectMake((superSize.width - pageSize.width - 10.f),
                                superSize.height - kPageCtrlHeight-pageSize.height,
                                pageSize.width, pageSize.height);
    
    
    // 标题根据pageCtrl的宽度来计算titleView宽度
    CGRect tR = titleView.frame;
    tR.size.width = pageCtrl.frame.origin.x-tR.origin.x-10;
    titleView.frame = tR;
    
#endif
    
    [self startTimer]; // 开始定时
}


- (void)startTimer
{
    if(timer == nil){        
        timer = [NSTimer scheduledTimerWithTimeInterval:TimeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
}
- (void)stopTimer
{
    if(timer != nil)
        [timer invalidate];
    timer = nil;
}
//timer调用函数
-(void)timerFired:(NSTimer *)_timer{    
    if(bannerDataPool.count >= 2){
        // 针对超出UITableView范围，就不在使用动画，
        // 不能关闭动画，暂时还没有找到控件可见的事件，来触发动画。
        if ([[self superview] isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)[self superview];
            if(tableView.contentOffset.y > CGRectGetHeight([self bounds])){
                [self pageMoveToLeft:NO];
            }
            else {
                [self pageMoveToLeft:YES];
            }            
        }
        else{
             [self pageMoveToLeft:YES];
        }
    }
    else
        [_timer invalidate];    // 停止滚动
}


#pragma
// 将要开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer]; // 停止动画
}
// 滚动窗口滑动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_sView
{
    CGFloat width = _sView.frame.size.width;
    NSInteger page = floor((_sView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2

    if(page == 1) {
        return;
    } else if (page == 0) {
        [self pageMoveToRight];
    } else {
        [self pageMoveToLeft:NO];
    }

    [self startTimer]; // 开始定时滚动
    CGPoint p = CGPointZero;
    p.x = scrollView.bounds.size.width;
    [scrollView setContentOffset:p animated:NO];    
}

- (void)pageMoveToRight
{
    NSUInteger bannerCount = bannerDataPool.count;
    CGSize scrollSize = scrollView.bounds.size;
    
    // 搜索UIView
    BannerViewCell *view1, *view2, *view3;
    for(BannerViewCell *v in scrollView.subviews)
    {
        if([v isKindOfClass:[BannerViewCell class]])
        {
            if(v.frame.origin.x == 0.0f)
                view1 = v;
            else if (v.frame.origin.x == scrollSize.width)
                view2 = v;
            else if (v.frame.origin.x == scrollSize.width + scrollSize.width)
                view3 = v;
        }
    }
    // 更新框架坐标
    CGRect tempRect = [view1 frame];
    view1.frame = view2.frame;
    view2.frame = view3.frame;
    view3.frame = tempRect;
    
    BannerViewCell *cell1 = (BannerViewCell *)view1;
    BannerViewCell *cell3 = (BannerViewCell *)view3;
    if (bannerCount >= 2)
    {
        NSInteger idx = [bannerDataPool indexOfObject:cell1.bannerData] - 1;
        if(idx < 0)
            idx = bannerCount -1;
        
        BannerData *newData = bannerDataPool[idx];
        cell3.bannerData.isApply = NO;
        newData.isApply = YES;
        [cell3 reloadData:newData isVodel:_isVodel];
    }
    
    // 更新UIPageControl
    pageCtrl.currentPage = [bannerDataPool indexOfObject:((BannerViewCell *)view1).bannerData];
    titleView.text = ((BannerViewCell *)view1).bannerData.title;
    
    CATransition *t = [CATransition animation];
    t.type = @"cube";
    t.subtype = kCATransitionFromBottom;    
    t.duration = 0.3f;
    [titleView.layer addAnimation:t forKey:@"Transition"];
}
- (void)pageMoveToLeft:(bool)isAnimated
{
    NSUInteger bannerCount = bannerDataPool.count;
    CGSize scrollSize = scrollView.bounds.size;
    
    // 搜索UIView
    BannerViewCell *c0, *c1, *c2;
    for(BannerViewCell *c in scrollView.subviews){
        if([c isKindOfClass:[BannerViewCell class]]){
            if(c.frame.origin.x == 0.0f)
                c0 = c;
            else if (c.frame.origin.x == scrollSize.width)
                c1 = c;
            else if (c.frame.origin.x == scrollSize.width + scrollSize.width)
                c2 = c;
        }
    }
    
    if(isAnimated)
    {
        CGRect r0 =  c0.frame;
        CGRect r1 =  c1.frame;
        c0.frame = c2.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];        
        c1.frame = r0;
        c2.frame = r1;
        [UIView commitAnimations];
    }
    else
    {
        CGRect tempR = [c2 frame];
        c2.frame = c1.frame;
        c1.frame = c0.frame;
        c0.frame = tempR;
    }

    
    BannerViewCell *cell1 = c0;
    BannerViewCell *cell3 = c2;
    if (bannerCount >= 2)
    {
        NSInteger idx = [bannerDataPool indexOfObject:cell3.bannerData] + 1;
        if (idx >= bannerCount) {
            idx = 0;
        }
        
        BannerData *newData = bannerDataPool[idx];
        cell1.bannerData.isApply = NO;
        newData.isApply = YES;
        [cell1 reloadData:newData isVodel:_isVodel];
    }
    
    // 更新UIPageControl
    pageCtrl.currentPage = [bannerDataPool indexOfObject:((BannerViewCell *)c2).bannerData];
    titleView.text = ((BannerViewCell *)c2).bannerData.title;
    
    CATransition *t = [CATransition animation];
    t.type = @"cube";
    t.subtype = kCATransitionFromTop;
    t.duration = 0.3f;
    [titleView.layer addAnimation:t forKey:@"Transition"];

}

@end
