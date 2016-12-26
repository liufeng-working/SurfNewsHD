//
//  PhoneReadController.h
//  SurfNewsHD
//
//  Created by apple on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PhoneWebView.h"
#import "ShareCountStatisticsManager.h"
#import "PhoneOauthWebviewController.h"
#import "PhonePopShareView.h"


@interface PhoneReadController : PhoneSurfController<UIWebViewDelegate,/*PhoneWebViewDelegate,*/ PhoneShareWeiboDelegate,MFMessageComposeViewControllerDelegate, PhoneOauthWebviewControllerDelegate>
{
    PhoneWebView *webview;
    UIButton *stateBtn;
    UIButton *backBtn;
    UIButton *forwardBtn;
    BOOL bgChanged;
    UIView* tools;
    UIView *statusBarBgView;
    ThreadSummary *shareThread;
}
@property(nonatomic,strong) NSString *webUrl;
@property(nonatomic,assign) BOOL state;
@end
