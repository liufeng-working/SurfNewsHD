//
//  PhoneReadController.m
//  SurfNewsHD
//
//  Created by apple on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneReadController.h"
#import "AppDelegate.h"
#import "NSString+Extensions.h"
@interface PhoneReadController ()

@end

@implementation PhoneReadController
@synthesize webUrl;
@synthesize state;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateDragOnly;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tools = [self addBottomToolsBar];
    
    float width = CGRectGetWidth(self.view.frame);
    float height = CGRectGetHeight(self.view.frame)-tools.frame.size.height;
    
    stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stateBtn addTarget:self action:@selector(stateUp) forControlEvents:UIControlEventTouchUpInside];
    stateBtn.frame = CGRectMake(256.0f, 0.0f, 64.0f, 49.0f);
    [stateBtn setBackgroundImage:[UIImage imageNamed:@"news_Refesh.png"] forState:UIControlStateNormal];
    [tools addSubview:stateBtn];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(webViewBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"news_Left.png"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(70.0f, 0.0f, 64.0f, 49.0f);
    [tools addSubview:backBtn];
    
    
    forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardBtn.frame = CGRectMake(186.0f, 0.0f, 64.0f, 49.0f);
    [forwardBtn setBackgroundImage:[UIImage imageNamed:@"news_Right.png"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(webViewForward) forControlEvents:UIControlEventTouchUpInside];
    [tools addSubview:forwardBtn];
    
    webview = [[PhoneWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    webview.backgroundColor = [UIColor clearColor];
    webview.delegate = self;
    [self.view addSubview:webview];

    if (IOS7) {
        webview.frame=CGRectMake(0.0f, 20.0f, width, height-20);
    }
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.webUrl completeUrl]]]];
}

#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];

    //by Jerry
    if (IOS7) {
        if (!statusBarBgView) {
            statusBarBgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            [self.view addSubview:statusBarBgView];
        }
        
        if (night) {
            [statusBarBgView setBackgroundColor:[UIColor blackColor]];
        }
        else{
            [statusBarBgView setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dealloc
{
    if (webview.loading) {
        [webview stopLoading];
    }
}
#pragma marl - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.state = YES;
    [backBtn setEnabled:[webview canGoBack]];
    [forwardBtn setEnabled:[webview canGoForward]];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.state = NO;
    [backBtn setEnabled:[webview canGoBack]];
    [forwardBtn setEnabled:[webview canGoForward]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.state = NO;
    [PhoneNotification autoHideWithText:@"加载失败"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.absoluteString hasPrefix:@"surfnews-iphone://activity-share"]) {
        NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:request.URL.query];
        
        if (shareThread == nil) {
            shareThread = [[ThreadSummary alloc] init];
        }
        shareThread.channelType = -100;  //这里定义活动的thread的channelType为-100
        shareThread.threadId = [[dict valueForKey:@"id"] integerValue];
        shareThread.title = [[[dict valueForKey:@"title"] urlDecodedString] urlDecodedString];
        shareThread.desc = [[[dict valueForKey:@"content"] urlDecodedString] urlDecodedString];
        shareThread.newsUrl = [[[dict valueForKey:@"link"] urlDecodedString] urlDecodedString];
        PhonePopShareView *_popShareView = [[PhonePopShareView alloc] initWithFrame:
                                            self.view.bounds];
        _popShareView.delegate = self;
        return NO;
    }
    return YES;
}

#pragma mark - Btn
-(void)stateUp
{
    if (self.state){
        [webview stopLoading];
    }else{
        [webview reload];
    }
}
-(void)webViewBack
{
    [webview goBack];
}
-(void)webViewForward
{
    [webview goForward];
}
-(void)dismissModalViewController
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}
//#pragma mark - PhoneWebViewDelegate
//-(void)webViewWillBeginDragging:(UIScrollView *)sView
//{
//    bgChanged = YES;
//}
//-(void)webViewDidScroll:(UIScrollView *)sView
//{
//    if (sView.contentOffset.y > 0) {
//        _backgroundView.hidden = YES;
//    }else{
//        _backgroundView.hidden = NO;
//    }
//    if (bgChanged) {
//        float alpha = (float)-sView.contentOffset.y/self.view.frame.size.height;
//        _blackMask.alpha =0.8- alpha;
//    }
//}
//- (void)webViewDidEndDragging:(UIScrollView *)sView
//               willDecelerate:(BOOL)decelerate
//{
//    CGPoint offset = sView.contentOffset;
//    DJLog(@"%f",offset.y);
//    if(offset.y < -40.0f)
//    {
//        bgChanged = NO;
//        sView.contentInset = UIEdgeInsetsMake(-offset.y, 0, 0, 0);
//        _backgroundView.hidden = NO;
//        [UIView animateWithDuration:0.5f animations:^{
//            _blackMask.alpha = 0.0f;
//            webview.frame = CGRectMake(0.0f, self.view.frame.size.height, webview.frame.size.width, webview.frame.size.height);
//            tools.frame = CGRectMake(0.0f, self.view.frame.size.height+44.0f, tools.frame.size.width, 44.0f);
//            
//        } completion:^(BOOL finished) {
//            [self dismissControllerAnimated:PresentAnimatedStateNone];
//        }];
//    }else
//    {
//        bgChanged = NO;
//        _blackMask.alpha = 0.8;
//    }
//    
//}
//-(void)webViewImageDownloadFinished:(ThreadContentImageInfoV2*)imageInfo
//{
//}

#pragma mark - PhonePopShareViewDelegate
- (void)shareToWeixin
{
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SNS_SHARE];
    
    [theApp sendThreadToWeinxin:shareThread shareImage:nil];
}

- (void)shareToWeixinTimeline
{
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SNS_SHARE];
    
    [theApp sendThreadToWeinxinTimeline:shareThread shareImage:nil];
}

- (void)shareToSinaWeibo
{
    if (![self isOAuthed:SinaOAuth]) {
        [self oauthWebViewController:SinaOAuth];
        return;
    }
    
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SNS_SHARE];
    
    [webview popShareContentToSinaWeibo:shareThread];
}

- (void)shareToTencentWeibo
{
    if (![self isOAuthed:TencentWeiboOAuth]) {
        [self oauthWebViewController:TencentWeiboOAuth];
        return;
    }
    
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SNS_SHARE];
    
    [webview popShareContentToTencentWeibo:shareThread];
}

- (void)shareToRenren
{
    if (![self isOAuthed:RenRenOAuth]) {
        [self oauthWebViewController:RenRenOAuth];
        return;
    }
    
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SNS_SHARE];
    [webview popShareContentToRenren:shareThread];
}

- (void)shareToChinaMobileWeibo
{
    if (![self isOAuthed:ChinaMobielOAuth]) {
        [self oauthWebViewController:ChinaMobielOAuth];
        return;
    }
    
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SNS_SHARE];
    [webview popShareContentToChinaMobileWeibo:shareThread];
}

- (void)shareToSMS
{
    //[self hiddenBar:shareView];
    [[ShareCountStatisticsManager sharedInstance] shareCountStatisticsWithActiveId:[NSString stringWithFormat:@"%@", @(shareThread.threadId)] shareType:SMS_SHARE];
    
    NSString *text = [NSString stringWithFormat:@"#冲浪快讯# 《%@》 %@",
                      shareThread.title == nil ? @"" : shareThread.title,
                      shareThread.desc == nil ? @"" : shareThread.desc];
    if ([MFMessageComposeViewController canSendText]) {
        theApp.nightModeShadow.hidden = YES;
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.body = [NSString stringWithFormat:@"%@ %@", text, shareThread.newsUrl];
        messageController.messageComposeDelegate = self;
        [self presentViewController:messageController
                           animated:YES completion:nil];
        
    }
}

//跳转到授权界面
- (void)oauthWebViewController:(OAuthClientType)type
{
    PhoneOauthWebviewController *controller = [PhoneOauthWebviewController new];
    [controller setOAuthClientType:type];
    controller.delegate = self;
    [self presentController:controller animated:PresentAnimatedStateFromRight];
    //    [theApp.oauthWebViewController setOAuthClientType:type];
    //    theApp.oauthWebViewController.delegate = self;
    //    [self presentModalViewController:theApp.oauthWebViewController animated:YES];
}

#pragma mark MFMessageComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [PhoneNotification autoHideWithText:@"短信分享成功"];
    } else if (result == MessageComposeResultFailed) {
        [PhoneNotification autoHideWithText:@"短信分享失败"];
    }
    theApp.nightModeShadow.hidden = ![[ThemeMgr sharedInstance] isNightmode];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PhoneOauthWebViewControllerDelegate methods
//授权成功
- (void)oauthResult:(PhoneOauthWebviewController *)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissControllerAnimated:PresentAnimatedStateFromRight];
}

//授权失败
- (void)oauthFailed:(PhoneOauthWebviewController *)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissControllerAnimated:PresentAnimatedStateFromRight];
    
    if (type == SinaOAuth)
        [PhoneNotification autoHideWithText:@"绑定新浪微博失败,请重试"];
    else if (type == TencentWeiboOAuth)
        [PhoneNotification autoHideWithText:@"绑定腾讯微博失败,请重试"];
    else if (type == RenRenOAuth)
        [PhoneNotification autoHideWithText:@"绑定人人网失败,请重试"];
    else if (type == ChinaMobielOAuth)
        [PhoneNotification autoHideWithText:@"绑定中国移动微博失败,请重试"];
}

//判断是否已授权
- (BOOL)isOAuthed:(OAuthClientType)type
{
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    if (type == SinaOAuth) {
        NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
        if ([sinaDict valueForKey:@"access_token"] && [sinaDict valueForKey:@"uid"]) {
            return YES;
        } else {
            return NO;
        }
    } else if (type == TencentWeiboOAuth) {
        NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
        if ([tencentDict valueForKey:@"access_token"]) {
            return YES;
        } else {
            return NO;
        }
    } else if (type == RenRenOAuth) {
        NSDictionary *renrenDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
        if ([renrenDict valueForKey:@"access_token"]) {
            return YES;
        } else {
            return NO;
        }
    } else if (type == ChinaMobielOAuth) {
        NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

@end
