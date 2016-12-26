//
//  PeriodicalWebView.h
//  SurfNewsHD
//
//  Created by apple on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeriodicalHtmlResolving.h"
@class PhoneWebView;
@protocol PeriodicalWebViewDelegate
-(void)webViewDidScroll:(UIScrollView *)sView;
-(void)webViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate;
-(void)webViewWillBeginDragging:(UIScrollView *)sView;
@end
@interface PeriodicalWebView : UIWebView
{
    PeriodicalLinkInfo *info;
    id<PeriodicalWebViewDelegate> webViewDelegate;
    NSMutableArray *imageDownloaderArr;
    BOOL htmlDomReady;
    UIActivityIndicatorView *activity;
}
@property(nonatomic) id<PeriodicalWebViewDelegate> webViewDelegate;
@property(nonatomic,strong,readonly) PeriodicalHtmlResolvingResult* contentResolvingResult;
-(void)hrefReloadWeb:(PeriodicalLinkInfo *)item;
-(void)webWillDealloc;
-(void)phoneWebViewDidFinishLoad;
-(void)downloadImageByUserClick:(NSString*)imgId;
-(PeriodicalLinkInfo *)currentLinkInfo;
@end
