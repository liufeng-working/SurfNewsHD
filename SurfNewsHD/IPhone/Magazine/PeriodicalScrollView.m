//
//  PeriodicalScrollView.m
//  SurfNewsHD
//
//  Created by apple on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PeriodicalScrollView.h"
#import "SurfHtmlGenerator.h"
#import "AppSettings.h"
#import "NSDictionary+QueryString.h"
#import "NSString+Extensions.h"

@implementation PeriodicalScrollView
@synthesize scrollView;
@synthesize toolsBar;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        float width = CGRectGetWidth(frame);
        float height = CGRectGetHeight(frame);
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width,height)];
        scrollView.delegate = self;
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setContentSize:CGSizeMake(3 * width, height)];
        [scrollView setPagingEnabled:YES];
        [self addSubview:scrollView];
        
        PeriodicalWebView *leftView;
        PeriodicalWebView *centerView;
        PeriodicalWebView *rightView;
        
        CGRect rect = CGRectMake(0.f, 0.f, width, height);
        leftView = [[PeriodicalWebView alloc]initWithFrame:rect];
        leftView.tag = 0;
        leftView.webViewDelegate=self;
        leftView.delegate = self;
        [scrollView addSubview:leftView];
        
        rect.origin.x = width;
        centerView = [[PeriodicalWebView alloc]initWithFrame:rect];
        centerView.tag = 1;
        centerView.webViewDelegate=self;
        centerView.delegate = self;
        [scrollView addSubview:centerView];
        
        rect.origin.x = width *2;
        rightView = [[PeriodicalWebView alloc]initWithFrame:rect];
        rightView.tag = 2;
        rightView.delegate = self;
        rightView.webViewDelegate=self;
        [scrollView addSubview:rightView];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)reloadScrollView
{
    NSInteger currentPage = [self.scrollViewDelegate currentScrollPage];
    NSUInteger count = [[self.scrollViewDelegate getThreadArr] count];
    if (currentPage +1 == count)
    {
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width*2, 0.f)];
    }else if(currentPage == 0)
    {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }else if (currentPage > 0)
    {
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
    }
    if (count < 3) {
        [scrollView setContentSize:CGSizeMake(count * [scrollView bounds].size.width, [scrollView bounds].size.height)];
    }
    [self.scrollViewDelegate reloadNewsScrollView];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
-(PeriodicalWebView *)currentScrollWeb
{
    NSInteger currentPage = [self.scrollViewDelegate currentScrollPage];
    NSUInteger count = [[self.scrollViewDelegate getThreadArr] count];
    ///*
    PeriodicalWebView *view = nil;
    for(UIView *v in scrollView.subviews)
    {
        if([v isKindOfClass:[PeriodicalWebView class]])
        {
            if(v.frame.origin.x == scrollView.contentOffset.x){
                if (v.frame.origin.x != CGRectGetWidth(scrollView.frame) &&
                    currentPage != 0&&
                    currentPage+1 != count) {
                    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0.f)];
                }
                view = (PeriodicalWebView *)v;
                break;
            }
        }
    }
    return view;
    //*/
}
-(PeriodicalWebView *)leftScrollWeb
{
    NSInteger currentPage = [self.scrollViewDelegate currentScrollPage];
    if (currentPage == 0) {
        return nil;
    }
    ///*
    PeriodicalWebView *view = nil;
    for(UIView *v in scrollView.subviews)
    {
        if([v isKindOfClass:[PeriodicalWebView class]])
        {
            if(v.frame.origin.x == scrollView.contentOffset.x - scrollView.frame.size.width){
                view = (PeriodicalWebView *)v;
                break;
            }
            
        }
    }
    return view;
    //*/
}
-(PeriodicalWebView *)rightScrollWeb
{
    NSUInteger count = [[self.scrollViewDelegate getThreadArr] count];
    NSInteger currentPage = [self.scrollViewDelegate currentScrollPage];
    if (currentPage+1 >= count) {
        return nil;
    }
    ///*
    PeriodicalWebView *view = nil;
    for(UIView *v in scrollView.subviews)
    {
        if([v isKindOfClass:[PeriodicalWebView class]])
        {
            if(v.frame.origin.x == scrollView.contentOffset.x + scrollView.frame.size.width){
                view = (PeriodicalWebView *)v;
                break;
            }
            
        }
    }
    return view;
    //*/
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)_sView
{
    
    CGFloat width = CGRectGetWidth([scrollView bounds]);
    oldPage = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_sView
{
    
    CGFloat width = CGRectGetWidth([scrollView bounds]);
    NSInteger page = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    if (oldPage < page) {
        
        [self pageMoveToRight:YES];
    }else if (oldPage > page){
        
        [self pageMoveToLeft:YES];
    }else{
        DJLog(@"未移动");
        scrollView.userInteractionEnabled = YES;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)_sView willDecelerate:(BOOL)decelerate{
    scrollView.userInteractionEnabled = NO;
}

-(void)pageMoveToLeft:(BOOL)animated
{
    NSInteger currentPage = [self.scrollViewDelegate currentScrollPage];
    NSUInteger count = [[self.scrollViewDelegate getThreadArr] count];
    if (currentPage > 1 && currentPage+1 < count) {
        
        //        /*
        // 搜索UIView
        CGSize scrollSize = scrollView.bounds.size;
        UIView *view1, *view2, *view3;
        for(UIView *v in scrollView.subviews)
        {
            if([v isKindOfClass:[PeriodicalWebView class]])
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
        
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
        
    }else{
        DJLog(@"滚动到左边界");
    }
    
    scrollView.userInteractionEnabled = YES;
    [self.scrollViewDelegate pageMoveToLeft];
}
-(void)pageMoveToRight:(BOOL)animated
{
    NSInteger currentPage = [self.scrollViewDelegate currentScrollPage];
    NSUInteger count = [[self.scrollViewDelegate getThreadArr] count];
    if (currentPage > 0 && currentPage < count-2) {
        //*
        CGSize scrollSize = scrollView.bounds.size;
        
        // 搜索UIView
        UIView *view1, *view2, *view3;
        for(UIView *v in scrollView.subviews)
        {
            if([v isKindOfClass:[PeriodicalWebView class]])
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
        CGRect tempRect = [view3 frame];
        view3.frame = view2.frame;
        view2.frame = view1.frame;
        view1.frame = tempRect;
        
        
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
    }else{
        DJLog(@"滚动到右边界");
    }
    scrollView.userInteractionEnabled = YES;
    [self.scrollViewDelegate pageMoveToRight];
}
-(void)backModalViewController
{
    [UIView animateWithDuration:0.5f animations:^{
        scrollView.frame = CGRectMake(0.0f, self.frame.size.height, scrollView.frame.size.width, scrollView.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self.scrollViewDelegate dismissModalViewController];
    }];
}

#pragma mark - PeriodicalWebViewDelegate UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    PeriodicalWebView *web = (PeriodicalWebView *)webView;
    [web phoneWebViewDidFinishLoad];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DJLog(@"%@",request.URL.absoluteString);
    
    //imageclick://
    if([request.URL.absoluteString hasPrefix:IMAGE_CLICK_PREFIX])
    {
        NSDictionary *paramsDict = [NSDictionary dictionaryWithFormEncodedString:request.URL.query];
        
        //src文件名为webview-img-click-to-download.png
        //表示点击下载图片
        if([request.URL.path hasSuffix:@"webview-img-click-to-download.png"])
        {
            [((PeriodicalWebView *)webView) downloadImageByUserClick:[paramsDict objectForKey:@"imgid"]];
        }
        else
        {
            PeriodicalWebView *web = (PeriodicalWebView *)webView;
            NSInteger imageIndex = 0;
            ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
            NSMutableArray *imageArr = [NSMutableArray array];

            for (NSInteger i = 0 ; i< [web.contentResolvingResult.herfArr count]; i++)
            {
                ThreadContentImageInfoV2 *imgInfo1 = [web.contentResolvingResult.herfArr objectAtIndex:i];
                if(picMode == ReaderPicOn ||
                   (picMode == ReaderPicManually && imgInfo1.isLocalImageReady))
                {
                    [imageArr addObject:imgInfo1];
                    if ([imgInfo1.imageId isEqualToString:[paramsDict objectForKey:@"imgid"]]) {
                        imageIndex = [imageArr count]-1;
                    }
                }
            }
            if (!pictureBox) {
                pictureBox = [[PictureBox alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                          self.superview.frame.size.width,
                                                                          self.superview.frame.size.height)];
            }
            pictureBox.delegate = self;
            pictureBox.backgroundColor = [UIColor blackColor];
            pictureBox.hidden = NO;
            [self.superview addSubview:pictureBox];
            
            
            
            [pictureBox setShareUrl:[[self currentScrollWeb] currentLinkInfo].linkUrl];
            [pictureBox reloadDataWithImageInfoV2Array:[web currentLinkInfo].linkTitle
                                            imageArray:imageArr
                                            imageIndex:imageIndex
                                     isHightDefinition:NO];
            
            pictureBox.alpha = 0.0f;
            [UIView animateWithDuration:0.5f animations:^{
                pictureBox.alpha = 1.0f;
            }];
            
        }
    }else if([request.URL.absoluteString isEqualToString:RELOAD_CONTENT_CLICK_PREFIX])
    {
        //重新加载
    }
    else if([request.URL.absoluteString isEqualToString:SOURCE_URL_CLICK_PREFIX])
    {
        //没有查看原文
        
    }
    else if([request.URL.absoluteString hasPrefix:OPEN_URL_WITH_SAFARI])
    {
        //调用safari打开url
        NSString* url = [[request.URL.absoluteString substringFromIndex:[OPEN_URL_WITH_SAFARI length]] urlDecodedString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    return YES;
}



// 隐藏tabBar动画
- (void)hiddenToolsBar:(BOOL)hidden animated:(BOOL)animated
{
    static BOOL isAnimated = NO;
    if (self.toolsBar == nil || isAnimated) {
        return;
    }
    
    
    isHiddenToolsBar = hidden;
    float toolsBarHeight = CGRectGetHeight(self.toolsBar.frame);
    
    
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            isAnimated = YES;
            CGRect toolsBarRect = self.toolsBar.frame;
            toolsBarRect.origin.y += (hidden ? toolsBarHeight : -toolsBarHeight);
            self.toolsBar.frame = toolsBarRect;
        } completion:^(BOOL finished) {
            isAnimated = NO;
        }];
    }
    else{
        isAnimated = NO;
        CGRect toolsBarRect = self.toolsBar.frame;
        toolsBarRect.origin.y += (hidden ? toolsBarHeight : -toolsBarHeight);
        self.toolsBar.frame = toolsBarRect;
    }
}



-(void)webViewWillBeginDragging:(UIScrollView *)sView
{
    // 记录当前滚动的开始坐标
    beginScrollPoint = sView.contentOffset;
}
-(void)webViewDidScroll:(UIScrollView *)sView
{
    CGPoint p = sView.contentOffset;
    if (fabs(p.x - beginScrollPoint.x) < fabs(p.y - beginScrollPoint.y))
    {
        float offH = 20.f;
        float scrollViewHeight = CGRectGetHeight(sView.frame);
        if (p.y > beginScrollPoint.y ) {     // 向下
            // tabBar 没有隐藏，就做隐藏操作
            if ( p.y < sView.contentSize.height-scrollViewHeight - offH) {
                if (!isHiddenToolsBar) {
                    [self hiddenToolsBar:YES animated:YES];
                }
            }
            else{
                if (isHiddenToolsBar) {
                    [self hiddenToolsBar:NO animated:YES];
                }
            }
        }
        else {
            // 向上
            if (isHiddenToolsBar && p.y < beginScrollPoint.y) {
                [self hiddenToolsBar:NO animated:YES];
            }
        }
    }
}
- (void)webViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate
{
    // 判断是否拖拽到底部
    if(isHiddenToolsBar && sView.contentOffset.y > 0.f)
    {
        float offH = 20.f;
        float sViewHeight = CGRectGetHeight(sView.frame);
        if (sView.contentOffset.y >= sView.contentSize.height-sViewHeight - offH) {
            [self hiddenToolsBar:NO animated:YES];  // tabBar隐藏，就做显示作
        }
    }
}
#pragma mark - PictureBoxDelegate
- (void)pictureBoxShowFinish
{
    pictureBox.alpha = 1.0f;
    [UIView animateWithDuration:0.5 animations:^{
        pictureBox.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [pictureBox removeFromSuperview];
    }];
}
@end
