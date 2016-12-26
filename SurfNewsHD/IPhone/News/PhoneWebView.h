//
//  PhoneWebView.h
//  SurfNewsHD
//
//  Created by apple on 13-5-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadSummary.h"
#import "ThreadContentResolver.h"
#import "ThemeMgr.h"
#import "PhoneShareView.h"
#import "PhoneSurfController.h"
#import "AppDelegate.h"
#import "PhonePopShareView.h"
#import <MessageUI/MessageUI.h>
#import "ContentShareController.h"

@class PhoneWebView;
@protocol PhoneWebViewDelegate
-(void)webViewDidScroll:(UIScrollView *)sView;
-(void)webViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate;
-(void)webViewWillBeginDragging:(UIScrollView *)sView;

-(void)webViewImageDownloadFinished:(ThreadContentImageInfoV2*)imageInfo;
@optional
-(void)shareViewPopped:(NSInteger)index;
@end

@interface PhoneWebView : UIWebView<UIScrollViewDelegate,PhoneShareWeiboDelegate>
{
    ThreadSummary *thread_;
    NSMutableArray *imageDownloaderArr;
    ThreadContentResolvingResultV2* contentRslvResult_;
    ContentShareController *m_contentShareCtl;
    
    BOOL htmlDomReady;    //取代UIWebview.loading，后者为NO时不代表html DOM树完全建立完成
    BOOL showReloadButtonWhenDomReady;
    BOOL loadContentWhenDomReady;

    BOOL loadImgFinished;
    
    NSMutableArray *m_imgNewsShareArray;
    NSMutableArray *m_imgNewsShareArrayDefault;
    
    UIActivityIndicatorView *activity;
    
}
@property(nonatomic,weak) id<PhoneWebViewDelegate> webViewDelegate;
@property(nonatomic,strong,readonly) ThreadContentResolvingResultV2* contentResolvingResult;
@property(nonatomic,retain) ContentShareController *m_contentShareCtl;

-(void)phoneWebViewDidFinishLoad;
-(void)downloadImageByUserClick:(NSString*)imgId;   //用户点击立刻下载某个图片
-(ThreadSummary *)threadCurrent;
-(void)webWillDealloc;
//-(void)shareSina;
-(void)popShareContentToWeixin:(ThreadSummary *)thread;
-(void)popShareContentToWeixinTimeline:(ThreadSummary *)thread;
-(void)popShareContentToSinaWeibo:(ThreadSummary *)thread;
-(void)popShareContentToTencentWeibo:(ThreadSummary *)thread;
-(void)popShareContentToRenren:(ThreadSummary *)thread;
-(void)popShareContentToChinaMobileWeibo:(ThreadSummary *)thread;
@end