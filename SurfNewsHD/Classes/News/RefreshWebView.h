//
//  RefreshWebView.h
//  WebViewRefresh
//
//  Created by apple on 13-1-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
typedef enum {
    WebViewLoadHtmlAnimateWhiteStyle = 0,
    WebViewLoadHtmlAnimateUpStyle = 1,
    WebViewLoadHtmlAnimateDownStyle = 2,
    WebViewLoadHtmlAnimateReloadStyle = 3
} WebViewLoadHtmlAnimate;

@class RefreshWebView;
@protocol RefreshWebViewDelegate
-(BOOL)refreshWebView:(WebViewLoadHtmlAnimate)type;
-(NSString *)loadingViewTitle:(WebViewLoadHtmlAnimate)type;
@end

@class LoadingView;
@interface RefreshWebView : UIWebView<UIScrollViewDelegate>
{
#ifdef ipad
    LoadingView *_headerView;
    LoadingView *_footerView;
#else
    
#endif
    BOOL htmlDomReady;    //取代UIWebview.loading，后者为NO时不代表html DOM树完全建立完成
    BOOL _isFooterInAction;
    UILabel *_msgLabel;
    WebViewLoadHtmlAnimate animateStyle;
    
@private
    UIScrollView *sView;
}
@property(nonatomic) BOOL htmlDomReady;
@property(nonatomic,weak) id<RefreshWebViewDelegate> refreshDelegate;
@property(nonatomic) WebViewLoadHtmlAnimate animateStyle;
- (void)webviewRefreshContentInset;
- (void)tableViewDidFinishedLoadingWithMessage:(NSString *)msg;
/*
-(void)loadHTMLString:(NSString *)string
              baseURL:(NSURL *)baseURL
            animateUp:(WebViewLoadHtmlAnimate)style;
*/
@end


