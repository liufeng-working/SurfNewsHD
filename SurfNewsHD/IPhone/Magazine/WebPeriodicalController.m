//
//  WebPeriodicalController.m
//  SurfNewsHD
//
//  Created by apple on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WebPeriodicalController.h"
#import "MagazineManager.h"
#import "NSString+Extensions.h"
#import "WebDesPeriodicalController.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "DownLoadViewController.h"
#import "AppDelegate.h"
#import "NetworkStatusDetector.h"
#import "OfflineIssueInfo.h"
#import "UIAlertView+Blocks.h"
#import "ThemeMgr.h"
#import "SurfHtmlGenerator.h"

@interface WebPeriodicalController ()

@end

@implementation WebPeriodicalController
@synthesize periodicalInfo;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        herfArray = [NSMutableArray new];
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = self.periodicalInfo.periodicalName;
    
    float width = CGRectGetWidth(self.view.frame);
    
    UIView * toolsBar = [self addBottomToolsBar];
    
   
    OfflineDownloader* od = [OfflineDownloader sharedInstance];
    BOOL shouldAddDownloadButton = YES;
    if([od isIssueOfflineDataReady:self.periodicalInfo.magazineId issId:self.periodicalInfo.periodicalId])
    {
        //离线数据已就绪
        shouldAddDownloadButton = NO;
    }
    else
    {
        //离线数据未就绪
        if(self.periodicalInfo.offlineZipUrl)
        {
            if(self.periodicalInfo.offlineZipSize)
            {
                shouldAddDownloadButton = YES;
            }
            else
            {
                //json文件错乱，zip文件大小为0
                shouldAddDownloadButton = NO;
            }
        }
        else    //离线包尚未提供下载
        {
            shouldAddDownloadButton = NO;
        }
    }
    
    if(shouldAddDownloadButton)
    {
        UIImage *moreImg = [UIImage imageNamed:@"download.png"];
        float btnWidth = moreImg.size.width;
        float btnHeight = moreImg.size.height;
        float btnX = CGRectGetWidth(toolsBar.bounds) - btnWidth;
        float btnY = (CGRectGetHeight(toolsBar.bounds) - btnHeight) * 0.5f;
        offlineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [offlineBtn setFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
        [offlineBtn setBackgroundImage:moreImg forState:UIControlStateNormal];
        [offlineBtn addTarget:self action:@selector(offlineBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [toolsBar addSubview:offlineBtn];
        
        [od addEventDelegate:self];
    }
    
    float height = CGRectGetHeight(self.view.frame)-toolsBar.frame.size.height-self.StateBarHeight;
    
    ThemeMgr *themeMgr = [ThemeMgr sharedInstance];
    [self.view setBackgroundColor:[UIColor colorWithHexString:
                              [themeMgr isNightmode]?NightBackgroundColor:DayBackgroundColor]];
    
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight,
                                                          width, height)];
    webview.delegate = self;
    webview.hidden = YES;
    [self.view addSubview:webview];
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(width/2-20.0f,
                                                                         self.StateBarHeight + webview.frame.size.height/2,
                                                                         40.0f, 40.0f)];
    activity.activityIndicatorViewStyle  = [themeMgr isNightmode] ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
    [activity startAnimating];
    [self.view addSubview:activity];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([herfArray count]<=0) {
        [self requestPeriodicalsInfo];
    }
}
- (void)willDealloc
{
    MagazineManager *manager = [MagazineManager sharedInstance];
    [manager cancelPeriodicalContent:self.periodicalInfo];
    [[OfflineDownloader sharedInstance] removeEventDelegate:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)requestPeriodicalsInfo
{
    if (!self.periodicalInfo) {
        DJLog(@"数据为空");
        return;
    }
   
    MagazineManager *manager = [MagazineManager sharedInstance];
    
    [manager getPeriodicalContentIndex:self.periodicalInfo complete:^(BOOL success, PeriodicalHtmlResolvingResult *result)
     {
         if (success && result.resolvedContent.length >0) {
             [webview loadHTMLString:result.resolvedContent baseURL:nil];
             [herfArray removeAllObjects];
             [herfArray addObjectsFromArray:result.herfArr];
         }
     }];
}
- (void)dismissControllerAnimated:(PresentAnimatedState)state
{
    [super dismissControllerAnimated:state];
    [self willDealloc];
    
    float scrollPosition = [[webview stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
    self.periodicalInfo.scrollPosition = scrollPosition;
    [[EzJsonParser serializeObjectWithUtf8Encoding:self.periodicalInfo] writeToFile:[PathUtil pathOfPeriodicalInfo:self.periodicalInfo] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *absoluteString = [url.absoluteString urlDecodedString];
    
    for (NSInteger i = 0; i<[herfArray count]; i++) {
        PeriodicalLinkInfo *info = [herfArray objectAtIndex:i];
        
        if ([absoluteString isEqualToString:info.linkUrl]) {
            self.periodicalInfo.lastReadURL = info.linkUrl;
            
            [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:self.periodicalInfo andWithType:kRTS_Periodical and:^(BOOL succeeded) {
                
            }];
            
            WebDesPeriodicalController *controller =
            [[WebDesPeriodicalController alloc] initWithPeriodicalLinks:herfArray andActiveIndex:i];
            [self presentController:controller
                           animated:PresentAnimatedStateFromRight];
            return NO;
        }
    }
    
    return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.hidden = NO;
    [activity stopAnimating];
    [activity removeFromSuperview];
    
    if (self.periodicalInfo.scrollPosition != 0.0f) {
        [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %f)", self.periodicalInfo.scrollPosition]];
    }
    if (self.periodicalInfo.lastReadURL != nil && ![self.periodicalInfo.lastReadURL isEmptyOrBlank]) {
        [self alertView];
    }
}
#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
    
    NSString *js =[NSString stringWithFormat:@"document.getElementById('CustomCSS').href=\"file://%@\"",[PathUtil pathOfResourceNamed:night?@"mag_index_n.css":@"mag_index_d.css" ]];
    
    [webview stringByEvaluatingJavaScriptFromString:js];
    
    
}
#pragma mark - OfflineDownloaderDelegate
-(void) downloadingIssueStatusChanged:(OfflineIssueInfo*)issue
{
    if (issue.magId == periodicalInfo.magazineId &&
        issue.issId == periodicalInfo.periodicalId)
    {
        switch (issue.issueStatus)
        {
            case IssueStatusDataReady:
            {
                offlineBtn.hidden = YES;
                [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"%@下载完成!",issue.name]];
                
                //重新加载本地数据
                [self requestPeriodicalsInfo];
                break;
            }
            case IssueStatusDownloading:
            {
                break;
            }
            case IssueStatusUnzipping:
            {
                [[DownLoadViewController sharedInstance] deleteImage];
                break;
            }
            case IssueStatusPending:
            {
                [[DownLoadViewController sharedInstance] deleteImage];
                break;
            }
            case IssueStatusStopped:
            {
                [[DownLoadViewController sharedInstance] deleteImage];
                [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"%@下载已停止!",issue.name]];
                break;
            }
            case IssueStatusWillDiscard:
            {
                [[DownLoadViewController sharedInstance] deleteImage];
                [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"%@下载失败!",issue.name]];
                break;
            }
            default:
                break;
        }
    }
}
-(void)offlineBtnClick:(UIButton *)btn
{
    OfflineDownloader *offline = [OfflineDownloader sharedInstance];
    if([offline isIssueDownloadingOrPending:self.periodicalInfo.magazineId issId:self.periodicalInfo.periodicalId])
    {
        //队列中
        [PhoneNotification autoHideWithText:@"下载任务已添加,请稍候..."];
    }
    else
    {
        //添加下载
        NetworkStatusType type = [NetworkStatusDetector currentStatus];
        if (type == NSTNoWifiOrCellular || type == NSTUnknown)
        {
            [PhoneNotification autoHideWithText:@"当前没有网络连接!"];
        }
        else if(type == NST2G || type == NST3G || type == NST4G || type == NSTLTE)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"即将下载%@(%@),\n您当前未接入WiFi，下载将会耗费您的流量，确定继续?",self.periodicalInfo.periodicalName,[NSString readableStringWithBytes:self.periodicalInfo.offlineZipSize]] cancelButtonItem:
                                  [RIButtonItem itemWithLabel:@"取消" action:
                                   ^{
                                       
                                   }] otherButtonItems:
                                  [RIButtonItem itemWithLabel:@"确定" action:
                                   ^{
                                       [self addMagazineTask];
                                   }], nil];
            [alert show];
        }
        else if(type == NSTWifi)
        {
            [self addMagazineTask];
        }
    }
}

- (void)addMagazineTask
{
    MagIssueOfflineDownloadTask *task = [MagIssueOfflineDownloadTask new];
    task.magId = periodicalInfo.magazineId;
    task.issueId = periodicalInfo.periodicalId;
    task.url = periodicalInfo.offlineZipUrl;
    task.issueName = periodicalInfo.periodicalName;
    task.expectedZipBytes = periodicalInfo.offlineZipSize;
    
    [[OfflineDownloader sharedInstance] addDownloadTask:task];
    [PhoneNotification autoHideWithText:@"下载任务已添加,请稍候..."];
}

- (void)alertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"是否自动跳转到上次浏览的位置？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"好的", nil];
    [alert show];
}

#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.periodicalInfo.lastReadURL = nil;
    } else if (buttonIndex == 1) {
        for (NSInteger i = 0; i<[herfArray count]; i++) {
            PeriodicalLinkInfo *info = [herfArray objectAtIndex:i];
            
            if ([self.periodicalInfo.lastReadURL isEqualToString:info.linkUrl]) {
                WebDesPeriodicalController *controller = [[WebDesPeriodicalController alloc] initWithPeriodicalLinks:herfArray andActiveIndex:i];
                [self presentController:controller
                               animated:PresentAnimatedStateFromRight];
            }
        }
    }
}

@end
