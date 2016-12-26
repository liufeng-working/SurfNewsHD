//
//  RefreshWebView.m
//  WebViewRefresh
//
//  Created by apple on 13-1-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "RefreshWebView.h"
#import <QuartzCore/QuartzCore.h>

#define kPROffsetY 60.f
#define kPRMargin 5.f
#define kPRLabelHeight 20.f
#define kPRLabelWidth 100.f
#define kPRArrowWidth 20.f
#define kPRArrowHeight 40.f

#define kTextColor [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define kPRBGColor [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define kPRAnimationDuration .18f

@implementation RefreshWebView
#define REFRESH_HEADER_HEIGHT 65.0f
@synthesize htmlDomReady;
@synthesize refreshDelegate;
@synthesize animateStyle;
-(NSString*)generateWhatTheFuckWebViewApiString
{
    //_setDrawInWebThread
    return [@"_s" stringByAppendingFormat:@"%@raw%@eb%@ad:",@"etD",@"InW",@"Thre"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        htmlDomReady = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setOpaque:NO];
        [self hideGradientBackground:self];
        //TEST for smooth scrolling
        BOOL yes = YES;
        NSString* str = [self generateWhatTheFuckWebViewApiString];
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:NSSelectorFromString(str)]];
        [invocation setTarget:self];
        [invocation setSelector:NSSelectorFromString(str)];
        [invocation setArgument:&yes atIndex:2];
        [invocation invoke];
        
        // Initialization code
        sView = self.subviews[0];
        sView.delegate = self;
        
        [sView addObserver:self
                forKeyPath:@"contentSize"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
        
#ifdef ipad
        float width = CGRectGetWidth(frame);
        float height = REFRESH_HEADER_HEIGHT;
        
        _headerView = [[LoadingView alloc] initWithFrame:
                       CGRectMake(0.0f,-height, width, height) atTop:YES];
        _headerView.style = StateDescriptionWebStyleTop;
        [sView addSubview:_headerView];
        
        
        _footerView = [[LoadingView alloc] initWithFrame:
                       CGRectMake(0.0f,self.frame.size.height, width, height) atTop:NO];
        _footerView.style = StateDescriptionWebStyleBottom;
        [sView addSubview:_footerView];
        
#else
        self.backgroundColor = [UIColor whiteColor];
#endif

        
    }
    return self;
}
- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

/*
-(void)loadHTMLString:(NSString *)string
              baseURL:(NSURL *)baseURL
            animateUp:(WebViewLoadHtmlAnimate)style
{
    self.animateStyle = style;

    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float y = self.frame.origin.y;
    if (style != WebViewLoadHtmlAnimateDownStyle) {
        self.frame = CGRectMake(self.frame.origin.x, y+height , width, 0);
    }
    else
    {
        self.frame = CGRectMake(self.frame.origin.x, y , width, 0);
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(self.frame.origin.x, y , width, height);
    } completion:^(BOOL finished) {
    }];

    [self stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
    [super loadHTMLString:string baseURL:baseURL];
    
    
}
*/
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
#ifdef ipad
    _footerView.frame = CGRectMake(0, sView.contentSize.height,  CGRectGetWidth(self.frame), REFRESH_HEADER_HEIGHT);
    [self webviewRefreshContentInset];
#else
    
#endif
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
#ifdef ipad
    if (_headerView.state == kPRStateLoading || _footerView.state == kPRStateLoading) {
        return;
    }
    
    NSString *title1 = [self.refreshDelegate loadingViewTitle:WebViewLoadHtmlAnimateDownStyle];
    [_footerView updateRefreshTitle:title1];
    
    NSString *title2 = [self.refreshDelegate loadingViewTitle:WebViewLoadHtmlAnimateUpStyle];
    [_headerView updateRefreshTitle:title2];
    
    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    
    float yMargin = offset.y + size.height - contentSize.height;
    if (offset.y < -kPROffsetY) {   //header totally appeard
        _headerView.state = kPRStatePulling;
    } else if (offset.y > -kPROffsetY && offset.y < 0){ //header part appeared
        _headerView.state = kPRStateLocalDisplay;
        
    } else if ( yMargin > kPROffsetY){  //footer totally appeared
        if (_footerView.state != kPRStateHitTheEnd) {
            _footerView.state = kPRStatePulling;
        }
    } else if ( yMargin < kPROffsetY && yMargin > 0) {//footer part appeared
        if (_footerView.state != kPRStateHitTheEnd) {
            _footerView.state = kPRStateLocalDisplay;
        }
    }
#else
    
#endif
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
#ifdef ipad
    if (_headerView.state == kPRStateLoading || _footerView.state == kPRStateLoading) {
        return;
    }
    if (_headerView.state == kPRStatePulling) {
        if (![self.refreshDelegate refreshWebView:WebViewLoadHtmlAnimateUpStyle]) {
            return;
        }
        
        //    if (offset.y < -kPROffsetY) {
        _isFooterInAction = NO;
        _headerView.state = kPRStateLoading;
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            sView.contentInset = UIEdgeInsetsMake(kPROffsetY, 0, 0, 0);
        }];
    }
    else if(_headerView.state == kPRStateLocalDisplay){        
        _headerView.state = kPRStateNormal;      
    }
    else if (_footerView.state == kPRStatePulling) {
        if (![self.refreshDelegate refreshWebView:WebViewLoadHtmlAnimateDownStyle]) {
            return;
        }
        
        //    } else  if (offset.y + size.height - contentSize.height > kPROffsetY){
        _isFooterInAction = YES;
        _footerView.state = kPRStateLoading;
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            sView.contentInset = UIEdgeInsetsMake(0, 0, kPROffsetY, 0);
        }];
    }
    else if(_footerView.state == kPRStateLocalDisplay){
        _footerView.state = kPRStateNormal;
    }
#else
    
#endif
}
#pragma mark -
- (void)webviewRefreshContentInset {
    [self tableViewDidFinishedLoadingWithMessage:@""];
}

- (void)tableViewDidFinishedLoadingWithMessage:(NSString *)msg{
#ifdef ipad
    //    if (_headerView.state == kPRStateLoading) {
    if (_headerView.loading) {
        _headerView.loading = NO;
        [_headerView setState:kPRStateNormal animated:NO];
        NSString *title = [self.refreshDelegate loadingViewTitle:WebViewLoadHtmlAnimateUpStyle];
        [_headerView updateRefreshTitle:title];
        [UIView animateWithDuration:kPRAnimationDuration*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            sView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL bl){
            if (msg != nil && ![msg isEqualToString:@""]) {
                [self flashMessage:msg];
            }
        }];
    }
    //    if (_footerView.state == kPRStateLoading) {
    else if (_footerView.loading) {
        _footerView.loading = NO;
        [_footerView setState:kPRStateNormal animated:NO];
        NSString *title = [self.refreshDelegate loadingViewTitle:WebViewLoadHtmlAnimateDownStyle];
        [_footerView updateRefreshTitle:title];
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            sView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL bl){
            if (msg != nil && ![msg isEqualToString:@""]) {
                [self flashMessage:msg];
            }
        }];
    }
#else
    
#endif
}

- (void)flashMessage:(NSString *)msg{
    //Show message
    __block CGRect rect = CGRectMake(0, sView.contentOffset.y - 20, sView.bounds.size.width, 20);
    
    if (_msgLabel == nil) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.frame = rect;
        _msgLabel.font = [UIFont systemFontOfSize:14.f];
        _msgLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _msgLabel.backgroundColor = [UIColor orangeColor];
        [_msgLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_msgLabel];
    }
    _msgLabel.text = msg;
    
    rect.origin.y += 20;
    [UIView animateWithDuration:.4f animations:^{
        _msgLabel.frame = rect;
    } completion:^(BOOL finished){
        rect.origin.y -= 20;
        [UIView animateWithDuration:.4f delay:1.2f options:UIViewAnimationOptionCurveLinear animations:^{
            _msgLabel.frame = rect;
        } completion:^(BOOL finished){
            [_msgLabel removeFromSuperview];
            _msgLabel = nil;
        }];
    }];
}

-(void)dealloc
{
    [sView removeObserver:self forKeyPath:@"contentSize"];
}
@end
