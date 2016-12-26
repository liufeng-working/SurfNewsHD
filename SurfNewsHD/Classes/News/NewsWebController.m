//
//  NewsWebController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NewsWebController.h"
#import "GTMHTTPFetcher.h"
#import "XmlResolve.h"
#import "PathUtil.h"
#import "ThreadContentResolver.h"
#import "SurfHtmlGenerator.h"
#import "ReadNewsController.h"
#import "ShareController.h"
#import "AppDelegate.h"
#import "NSString+Extensions.h"
#import "AppSettings.h"
#import "NSDictionary+QueryString.h"
#import "SurfRootViewController.h"
#import "FileUtil.h"
#import "SurfNotification.h"
#import "XmlUtils.h"
@interface NewsWebController ()

@end

@implementation NewsWebController
@synthesize channels;
@synthesize currentIndex;
@synthesize hotChannel;
@synthesize subsChannel;
@synthesize currentThread;
@synthesize webStyle;
@synthesize currentNewsData;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        imageDownloaderArr = [[NSMutableArray alloc] init];
        webStyle = NewsWebrStyleHot;
        channels = [NSMutableArray new];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    float height = 748-kPaperTopY-kPaperBottomY;

    webListView = [[NewsWebListView alloc] initWithFrame:CGRectMake(0.0f, kPaperTopY, 222.0f, height)];
    webListView.delegate = self;
    [self.view addSubview:webListView];
    
    float width = kContentWidth - 10.f - CGRectGetMaxX(webListView.frame);

    webview = [[RefreshWebView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(webListView.frame)+ 10.f,
                                                               kPaperTopY,
                                                               width,
                                                               height)];
    webview.refreshDelegate = self;
    webview.delegate = self;
    [self.view addSubview:webview];
    
    CGPoint point = webview.center;
    
    UIView* tools = [[UIView alloc] initWithFrame:CGRectMake(700, 30.0f, 150, 38)];
    tools.backgroundColor = [UIColor clearColor];
    
    
    UIButton *fontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fontBtn addTarget:self action:@selector(setWebViewSize:) forControlEvents:UIControlEventTouchUpInside];
    [fontBtn setImage:[UIImage imageNamed:@"newsWeb_Font.png"]
             forState:UIControlStateNormal];
    fontBtn.frame = CGRectMake(0.0f, 2.0f, 38.0f, 36.0f);
    [fontBtn setImageEdgeInsets:UIEdgeInsetsMake(6.0f, 5.0f, 3.0f, 5.0f)];
    [tools addSubview:fontBtn];
    if (webStyle != NewsWebrStylePhoneNews){
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"newsWeb_share.png"]
                     forState:UIControlStateNormal];
        shareButton.frame = CGRectMake(50.0f, 2.0f, 38.0f, 36.0f);
        [shareButton setImageEdgeInsets:UIEdgeInsetsMake(6.0f, 5.0f, 3.0f, 5.0f)];
        [shareButton addTarget:self action:@selector(shareNews:) forControlEvents:UIControlEventTouchUpInside];
        [tools addSubview:shareButton];
    }
    else{
        fontBtn.frame = CGRectMake(50.0f, 2.0f, 38.0f, 36.0f);
    }
    collection = [UIButton buttonWithType:UIButtonTypeCustom];
    [collection setImage:[UIImage imageNamed:@"newsWeb_faved.png"]
                forState:UIControlStateNormal];
    collection.frame = CGRectMake(100.0f, 2.0f, 38.0f, 36.0f);
    [collection setImageEdgeInsets:UIEdgeInsetsMake(6.0f, 5.0f, 3.0f, 5.0f)];
    [collection addTarget:self action:@selector(collectionNews:) forControlEvents:UIControlEventTouchUpInside];
    [tools addSubview:collection];
    
    [self.view addSubview:tools];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"backBtn"]
             forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0.0f, 32.0f, 38.0f, 36.0f);
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.0f, 5.0f, 3.0f, 5.0f)];
    [self.view addSubview:backBtn];
    
    loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"webview_loading"]];
    loadingView.center = point;
    loadingView.hidden = YES;
    [self.view addSubview:loadingView];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5.0f,
                                                             CGRectGetHeight(loadingView.frame) ,
                                                             CGRectGetWidth(loadingView.frame)+10.0f,
                                                             30.0f)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.text = @"新闻加载中";
    loadingLabel.textColor = [UIColor hexChangeFloat:@"908678"];
    loadingLabel.font = [UIFont systemFontOfSize:18.0f];
    [loadingView addSubview:loadingLabel];
    [self performSelector:@selector(loadLabelChanged) withObject:nil afterDelay:0.3f];
    
    
    loading_Eror = [UIButton buttonWithType:UIButtonTypeCustom];
    [loading_Eror setBackgroundImage:[UIImage imageNamed:@"loading_Eror"] forState:UIControlStateNormal];
    [loading_Eror addTarget:self action:@selector(reloadWebview) forControlEvents:UIControlEventTouchUpInside];
    loading_Eror.frame = CGRectMake(0.0f, 0.0f, 150.0f, 155.0f);
    loading_Eror.center = point;
    loading_Eror.hidden = YES;
    [self.view addSubview:loading_Eror];
    
    
    if (webStyle == NewsWebrStyleFav && [channels count]>0)
    {
        [webListView.headerView removeFromSuperview];
        webListView.headerView = nil;
        [webListView.footerView removeFromSuperview];
        webListView.footerView = nil;
        
        currentIndex = [channels indexOfObject:currentThread];
        if (currentIndex == NSNotFound) {
            currentIndex = 0;
        }
        [webListView reloadChannels:channels];
        [self tableView:[channels objectAtIndex:currentIndex]
         didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];
    }
    UIPanGestureRecognizer * tapGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    tapGR.delegate = self;
    [self.view addGestureRecognizer: tapGR];

}
- (void) moveActionGestureRecognizerStateChanged: (UIGestureRecognizer *) sender
{
    if (webview.hidden) {
        return;
    }
    CGPoint point = [sender locationInView: self.view];
    
    float y = point.y -webview.frame.size.height;
    if (y >0.0f) {
        y = 0.0f;
    }
    DJLog(@"%f",y);
    if (sender.state == UIGestureRecognizerStateBegan ||sender.state == UIGestureRecognizerStateChanged)
    {
        webview.frame = CGRectMake(0.0f, y,
                                   webview.frame.size.width,
                                   webview.frame.size.height);
    }
    else if (sender.state == UIGestureRecognizerStateEnded ||sender.state == UIGestureRecognizerStateCancelled)
    {
        if (y > -80.0f) {
            [UIView animateWithDuration:0.5 animations:^{
                webview.frame = CGRectMake(0.0f, 0.0f,
                                           webview.frame.size.width,
                                           webview.frame.size.height);
            }];
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                webview.frame = CGRectMake(0.0f, -webview.frame.size.height,
                                           webview.frame.size.width,
                                           webview.frame.size.height);
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
            }];
            
        }
    }

}
-(void)btnLong:(UIPanGestureRecognizer *)sender
{

#ifdef ipad
    CGPoint point = [sender translationInView: self.view];
    if (point.x > 70.0f && !webview.hidden)
    {
        [self popViewControllerAnimated:YES];
    }
#else
#endif
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef ipad
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    [rootController setSplitPosition:kSplitPositionMin animated:YES];
#else
    
#endif
    
    if ([channels count] != 0 && currentIndex !=NSNotFound) {
        return;
    }
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    //刷新数据
    if (webStyle == NewsWebrStyleHot && hotChannel)
    {
        [channels addObjectsFromArray:
         [tm getLocalThreadsForHotChannel:hotChannel]];
    }
    else if (webStyle == NewsWebrStyleSubs && subsChannel)
    {
        [channels addObjectsFromArray:
         [tm getLocalThreadsForSubsChannel:subsChannel]];
    }
    else if (webStyle == NewsWebrStyleNewest)
    {
        NewestManager *manager = [NewestManager sharedInstance];
        [channels addObjectsFromArray:[manager loadLocalNewestChannels]];
        
    }
    else if (webStyle == NewsWebrStyleFav && [channels count]>0)
    {
        return;
    }
    else if (webStyle == NewsWebrStylePhoneNews)
    {
        [webListView.headerView removeFromSuperview];
        webListView.headerView = nil;
        [webListView.footerView removeFromSuperview];
        webListView.footerView = nil;
        
        PhoneNewsManager *phoneNewsManager = [PhoneNewsManager sharedInstance];
        [channels addObjectsFromArray:[phoneNewsManager getLocalPhoneNew]];
        if ([channels count]<=0) {
            [self popViewControllerAnimated:YES];
        }
        currentIndex = [channels indexOfObject:currentNewsData];
        if (currentIndex == NSNotFound) {
            currentIndex = 0;
        }
        [webListView reloadChannels:channels];
        [self tableView:[channels objectAtIndex:currentIndex]
         didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];
        return;
    }
    if ([channels count] <= 0) {
        return;
    }
    for (NSInteger i= [channels count]-1; i>=0; --i) {
        ThreadSummary *item = [channels objectAtIndex:i];
        if (item.open_type == 1) {
            [channels removeObject:item];
        }
    }
    currentIndex = [channels indexOfObject:currentThread];
    if (currentIndex == NSNotFound) {
        currentIndex = 0;
    }
    [webListView reloadChannels:channels];
    [self tableView:[channels objectAtIndex:currentIndex]
     didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];// to LWK 在Pad版本下，这里会异常。
}
-(void)dealloc
{
    
    ThreadContentDownloader *downLoader = [ThreadContentDownloader sharedInstance];
    [downLoader cancelDownload:[channels objectAtIndex:currentIndex]];
    
    for(ImageDownloadingTask *task in imageDownloaderArr)
    {
        [[ImageDownloader sharedInstance] cancelDownload:task];
        
    }
    [imageDownloaderArr removeAllObjects];
}
-(void)loadLabelChanged
{
    NSString *str = loadingLabel.text;
    if (str.length < 11)
    {
        loadingLabel.text = [NSString stringWithFormat:@"%@.",str];
    }
    else
    {
        loadingLabel.text = @"新闻加载中.";
    }
    [self performSelector:@selector(loadLabelChanged) withObject:nil afterDelay:1.0f];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 网页加载
-(void)webLoadData:(PhoneNewsData *)data
          andStyle:(WebViewLoadHtmlAnimate)style
              html:(NSString *)html
{
    if (!data) {
        return;
    }
    
    currentNewsData = data;
    webview.animateStyle = style;
    
    PhoneNewsManager *manager = [PhoneNewsManager sharedInstance];
    NSString *path = [[manager getUnzipPath:currentNewsData] stringByAppendingPathComponent:@"index.html"];
    if (![FileUtil fileExists:path]) {
        path = [[manager getUnzipPath:currentNewsData] stringByAppendingPathComponent:@"index"];
    }
    if (![FileUtil fileExists:path]) {
        [SurfNotification surfNotification:@"未发现手机报路径"];
        loading_Eror.hidden = NO;
        loadingView.hidden = YES;
        webview.hidden = YES;
        DJLog(@"webview hidden  YES");
    }
    else
    {
        
        NSURL *url = [NSURL URLWithString:[PathUtil pathOfResourceNamed:@"Files"]];
        NSString* newHtml = [ThreadContentResolver resolveContent:html
                                                  OfPhoneNewsData:data];
        newHtml = [SurfHtmlGenerator generateWithNewsData:data andResolvedContent:newHtml];
        [webview loadHTMLString:newHtml baseURL:url];
    }
    
}
-(void)webLoadData:(NSData *)data withThread:(ThreadSummary*)thread andStyle:(WebViewLoadHtmlAnimate)style
{
    currentThread = thread;
    if (!data) {
        DJLog(@"data is nil");
    }
    float height = 748-kPaperTopY-kPaperBottomY;
    float width = kContentWidth - 10.f - CGRectGetMaxX(webListView.frame);
    if (webview) {
        
        //异步搞死旧的webview
        RefreshWebView* vi = webview;
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           vi.refreshDelegate = nil;
                           vi.delegate = nil;
                           [vi removeFromSuperview];
                       });
    }
    webview = [[RefreshWebView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(webListView.frame)+ 10.f,
                                                               kPaperTopY,
                                                               width,
                                                               height)];
    webview.refreshDelegate = self;
    webview.delegate = self;
    [self.view addSubview:webview];

    
    NSString *string = [[NSString alloc ]initWithData:data encoding:NSUTF8StringEncoding];
    
    string =[XmlUtils contentOfFirstNodeNamed:@"content" inXml:string];

    ThreadContentResolvingResultV2* result = [ThreadContentResolver resolveContentV2:string OfThread:thread];
    NSString* html = [SurfHtmlGenerator generateWithThread:thread andResolvedContent:result.resolvedContent];
    webview.animateStyle = style;
    //    [webview loadHTMLString:html baseURL:nil];
    DJLog(@"%@",html);
    [webview loadHTMLString:html baseURL:nil];
    
    [self downloadedImages:result.contentImgInfoArray];
}
#pragma mark - NewsWebListViewDelegate
-(NSInteger)getCurrentIndex{
    
    return currentIndex;
}
- (void)tableView:(NSObject *)item
   didSelectStyle:(WebViewLoadHtmlAnimate)style
{
    if (!item) {
        return;
    }
    webview.hidden = YES;
    loadingView.hidden = NO;

    
    loading_Eror.hidden = YES;
    if ([item isKindOfClass:[ThreadSummary class]])
    {
        //[webview loadHTMLString:@"" baseURL:[NSURL URLWithString:@"reload"]];
        ThreadSummary *channel = (ThreadSummary *)item;
        ThreadContentDownloader *downLoader = [ThreadContentDownloader sharedInstance];
        [downLoader cancelDownload:[channels objectAtIndex:currentIndex]];
        currentIndex = [channels indexOfObject:channel];
        NSString* targetPath = [PathUtil pathOfThreadContent:channel];
        [webListView refreshCell];
        //标记为已读
        [[ThreadsManager sharedInstance] markThreadAsRead:channel];
        
        //收藏
        FavsManager *manager = [FavsManager sharedInstance];
        BOOL collect = [manager isThreadInFav:channel];
        
        if (collect)
        {
            [collection setImage:[UIImage imageNamed:@"newsWeb_faved.png"]
                        forState:UIControlStateNormal];
            
        }else
        {
            [collection setImage:[UIImage imageNamed:@"newsWeb_fav.png"]
                        forState:UIControlStateNormal];
        }
        if(![[NSFileManager defaultManager] fileExistsAtPath:targetPath])
        {
            [downLoader download:channel withCompletionHandler:^(BOOL succeeded, NSString *content, ThreadSummary *thread)
            {
                if (succeeded) {
                    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                    [self webLoadData:data withThread:channel andStyle:style];
                }
                else
                {
                    [SurfNotification surfNotification:@"网络异常！"];
                    loading_Eror.hidden = NO;
                    loadingView.hidden = YES;
                    webview.hidden = YES;
                }
            }];
        }else
        {
            NSData *data = [NSData dataWithContentsOfFile:targetPath];
            [self webLoadData:data withThread:channel andStyle:style];
        }
    }
    else if ([item isKindOfClass:[PhoneNewsData class]])
    {
        PhoneNewsData *newsData = (PhoneNewsData *)item;
        currentIndex = [channels indexOfObject:newsData];
        [webListView refreshCell];
        PhoneNewsManager *manager = [PhoneNewsManager sharedInstance];
        [manager getPhoneNewsHtmlDate:newsData complete:^(BOOL succeeded, NSString * html)
         {
             if (succeeded && html.length >0)
             {
                 [self webLoadData:newsData andStyle:style html:html];
             }
             else
             {
                 [SurfNotification surfNotification:@"网络异常！"];
                 loading_Eror.hidden = NO;
                 loadingView.hidden = YES;
                 webview.hidden = YES;
             }
         }];
    }
    
    
    
}
// 加载更多频道内容
- (void)downloadMoreChannels
{
    NSInteger channelsCount = [channels count];
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if (hotChannel != nil
        &&![tm isHotChannelInRefreshing:self hotChannel:hotChannel ]
        &&![tm isHotChannelInGettingMore:self hotChannel:hotChannel]
        && webStyle == NewsWebrStyleHot)
    {
        [tm getMoreForHotChannel:self hotChannel:self.hotChannel
           withCompletionHandler:^(ThreadsFetchingResult *result) {
               if ([result succeeded] && [result.threads count]>0 )
               {
                   [channels addObjectsFromArray:result.threads];
                   for (NSInteger i= [channels count]-1; i>=0; --i) {
                       ThreadSummary *item = [channels objectAtIndex:i];
                       if (item.open_type == 1) {
                           [channels removeObject:item];
                       }
                   }
                   [webListView reloadChannels:channels];
                   [self tableView:[channels objectAtIndex:channelsCount]
                    didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];
               }else{
                   [webListView cancelLoading];
                   [SurfNotification surfNotification:@"网络异常！"];
               }
           }];
    }
    else if (subsChannel && ![tm isSubsChannelInRefreshing:subsChannel ]
             &&![tm isSubsChannelInGettingMore:subsChannel]
             && webStyle == NewsWebrStyleSubs)
    {
        [tm getMoreForSubsChannel:self subsChannel:self.subsChannel
            withCompletionHandler:^(ThreadsFetchingResult *result) {
                if ([result succeeded] && [result.threads count]>0 )
                {
                    
                    [channels addObjectsFromArray:result.threads];
                    for (NSInteger i= [channels count]-1; i>=0; --i) {
                        ThreadSummary *item = [channels objectAtIndex:i];
                        if (item.open_type == 1) {
                            [channels removeObject:item];
                        }
                    }
                    [webListView reloadChannels:channels];
                    [self tableView:[channels objectAtIndex:channelsCount]
                     didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];
                }else{
                    [webListView cancelLoading];
                    [SurfNotification surfNotification:@"网络异常！"];
                }
            }];
    }
    else if (webStyle == NewsWebrStyleNewest)
    {
        NewestManager *manager = [NewestManager sharedInstance];
        [manager getMoreForNewestCompletionHandler:^(NewestManagerResult * result) {
            if ([result succeeded] && [result.threads count] > 0) {
                [channels addObjectsFromArray:result.threads];
                for (NSInteger i= [channels count]-1; i>=0; --i) {
                    ThreadSummary *item = [channels objectAtIndex:i];
                    if (item.open_type == 1) {
                        [channels removeObject:item];
                    }
                }
                [webListView reloadChannels:channels];
                [self tableView:[channels objectAtIndex:channelsCount]
                 didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];
            }else{
                [webListView cancelLoading];
                [SurfNotification surfNotification:@"网络异常！"];
            }
        }];
    } else{
        [webListView cancelLoading];
        [SurfNotification surfNotification:@"网络异常！"];
    }
    
}
- (void)refreshChannels
{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if (hotChannel != nil
        &&![tm isHotChannelInRefreshing:self hotChannel:hotChannel ]
        &&![tm isHotChannelInGettingMore:self hotChannel:hotChannel]
        && webStyle == NewsWebrStyleHot)
    {
        [tm refreshHotChannel:self hotChannel:self.hotChannel
        withCompletionHandler:^(ThreadsFetchingResult *result) {
            if ([result succeeded] && [result.threads count]>0 )
            {
                [channels removeAllObjects];
                [channels addObjectsFromArray:result.threads];
                for (NSInteger i= [channels count]-1; i>=0; --i) {
                    ThreadSummary *item = [channels objectAtIndex:i];
                    if (item.open_type == 1) {
                        [channels removeObject:item];
                    }
                }
                [webListView reloadChannels:channels];
            }else{
                [webListView cancelLoading];
                [SurfNotification surfNotification:@"网络异常！"];
            }
        }];
    }
    else if (subsChannel && ![tm isSubsChannelInRefreshing:subsChannel ]
             &&![tm isSubsChannelInGettingMore:subsChannel]
             && webStyle == NewsWebrStyleSubs)
    {
        [tm refreshSubsChannel:self subsChannel:self.subsChannel
         withCompletionHandler:^(ThreadsFetchingResult *result) {
             if ([result succeeded] && [result.threads count]>0 )
             {
                 [channels removeAllObjects];
                 [channels addObjectsFromArray:result.threads];
                 
                 for (NSInteger i= [channels count]-1; i>=0; --i) {
                     ThreadSummary *item = [channels objectAtIndex:i];
                     if (item.open_type == 1) {
                         [channels removeObject:item];
                     }
                 }
                 [webListView reloadChannels:channels];
             }else{
                 [webListView cancelLoading];
                 [SurfNotification surfNotification:@"网络异常！"];
             }
         }];
    }
    else if (webStyle == NewsWebrStyleNewest)
    {
        NewestManager *manager = [NewestManager sharedInstance];
        [manager refreshNewestCompletionHandler:^(NewestManagerResult * result) {
            if ([result succeeded] && [result.threads count] > 0) {
                [channels removeAllObjects];
                [channels addObjectsFromArray:result.threads];
                
                for (NSInteger i= [channels count]-1; i>=0; --i) {
                    ThreadSummary *item = [channels objectAtIndex:i];
                    if (item.open_type == 1) {
                        [channels removeObject:item];
                    }
                }
                [webListView reloadChannels:channels];
            }else{
                [webListView cancelLoading];
                [SurfNotification surfNotification:@"网络异常！"];
            }
        }];
    } else{
        [webListView cancelLoading];
        [SurfNotification surfNotification:@"网络异常！"];
    }
}
#pragma mark - RefreshWebViewDelegate
-(BOOL)refreshWebView:(WebViewLoadHtmlAnimate)type
{
    if (type == WebViewLoadHtmlAnimateUpStyle)
    {
        if (currentIndex <= 0) {
            [SurfNotification surfNotification:@"当前第一页!"];
            return NO;
        }
        //        currentIndex --;
        if (channels) {
            [self tableView:[channels objectAtIndex:currentIndex-1]
             didSelectStyle:WebViewLoadHtmlAnimateUpStyle];
        }else
        {
            return NO;
        }
    }
    else if (type == WebViewLoadHtmlAnimateDownStyle)
    {
        
        if (currentIndex+1 >= [channels count]) {
            if (webStyle == NewsWebrStyleFav || webStyle == NewsWebrStylePhoneNews ) {
                //收藏
                [SurfNotification surfNotification:@"当前最后一页!"];
                return NO;
            }else
            {
                [self downloadMoreChannels];
                return YES;
            }
        }else if (channels) {
            [self tableView:[channels objectAtIndex:currentIndex+1]
             didSelectStyle:WebViewLoadHtmlAnimateDownStyle];
        }else
        {
            return NO;
        }
        
    }
    return YES;
}
-(NSString *)loadingViewTitle:(WebViewLoadHtmlAnimate)type
{
    
    if (type == WebViewLoadHtmlAnimateUpStyle)
    {
        if (currentIndex == 0)
        {
            return @"没有上一页了";
        }
        ThreadSummary *item = [channels objectAtIndex:currentIndex-1];
        return [NSString stringWithFormat:@"上一篇：%@",item.title];
        
    }else if (type == WebViewLoadHtmlAnimateDownStyle)
    {
        if  (currentIndex+1 >= [channels count])
        {
            return @"释放查看下一篇";
        }
        ThreadSummary *item = [channels objectAtIndex:currentIndex+1];
        return [NSString stringWithFormat:@"下一篇：%@",item.title];
        
    }
    else if (type == WebViewLoadHtmlAnimateWhiteStyle)
    {
        ThreadSummary *item = [channels objectAtIndex:currentIndex];
        return [NSString stringWithFormat:@"%@",item.title];
    }
    else
    {
        return nil;
    }
    
}
#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webview.htmlDomReady = NO;
}
- (void)webViewDidFinishLoad:(UIWebView *)web
{
    if ([web.request.URL.absoluteString isEqual:@"file://reload"]
        && webStyle != NewsWebrStylePhoneNews) {
        DJLog(@"%@",web.request.URL.absoluteString);
        return;
    }
    webview.htmlDomReady = YES;
    DJLog(@"webViewDidFinishLoad %d ",[imageDownloaderArr count]);
    for (NSInteger i= [imageDownloaderArr count]-1; i>=0; --i) {
        ImageDownloadingTask *idt = [imageDownloaderArr objectAtIndex:i];
        if ([FileUtil fileExists:idt.targetFilePath]) {
            DJLog(@"加载图片 %@ ",idt.targetFilePath);
            NSString *js = [NSString stringWithFormat:@"document.getElementById(\"%@\").src=\"file://%@\"",
                            idt.userData,idt.targetFilePath];
            DJLog(@"%@",[webview stringByEvaluatingJavaScriptFromString:js]);
            if ([FileUtil fileExists:idt.targetFilePath ]) {
                DJLog(@"YES");
            }else{
                DJLog(@"NO");
            }
            [imageDownloaderArr removeObject:idt];
        }
    }
    if (webview.animateStyle == WebViewLoadHtmlAnimateReloadStyle)
    {
        return;
    }
    DJLog(@"%@",web.request.URL.absoluteString);
    float width = web.frame.size.width;
    float height = web.frame.size.height;
    float y = web.frame.origin.y;
    if (webview.animateStyle != WebViewLoadHtmlAnimateUpStyle) {
        web.frame = CGRectMake(web.frame.origin.x, y+height , width, 0);
    }
    else
    {
        web.frame = CGRectMake(web.frame.origin.x, y , width, 0);
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        web.frame = CGRectMake(web.frame.origin.x, y , width, height);
    } completion:^(BOOL finished) {
    }];
    loadingView.hidden = YES;
    webview.hidden = NO;
    [webview webviewRefreshContentInset];
    
}
- (void)webView:(UIWebView *)web didFailLoadWithError:(NSError *)error
{

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    NSString *absoluteString = [url.absoluteString urlDecodedString];
    if ([webView.request.URL.absoluteString isEqual:@"file://reload"]
        && webStyle != NewsWebrStylePhoneNews) {
        return YES;
    }
    if ([[url scheme] isEqualToString:@"surf"])
    {
        
        if ([absoluteString isEqualToString:@"surf://reloadcontentclick"])
        {
            //重新加载
            [self tableView:[channels objectAtIndex:currentIndex]
             didSelectStyle:WebViewLoadHtmlAnimateReloadStyle];
            
        }
        else if ([absoluteString isEqualToString:@"surf://srcurlclick"])
        {
            //查看正文
            ThreadSummary *item = [channels objectAtIndex:currentIndex];
            if (item) {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                ReadNewsController *viewController = [[ReadNewsController alloc] init];
                viewController.webUrl = [item.newsUrl completeUrl];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
                UIViewController *rootController = appDelegate.window.rootViewController;
                [rootController presentModalViewController:nav animated:YES];
                
            }
            return NO;
        }
    }else if ([[url scheme] isEqualToString:@"imageclick"] )
    {
        if (webStyle == NewsWebrStylePhoneNews) {
            return NO;
        }
        //url形似：
        //imageclick://%7B%22width%22:200,%22height%22:132,%22x%22:250,%22y%22:171,%22src%22:%22file:///Users/yuleiming-mac/Library/Application%20Support/iPhone%20Simulator/5.1/Applications/AF2148AD-C582-49AD-B421-6504AB691FF4/Documents/HotChannels/4077/90476323/img0%22%7D
        //需要先进行urldecoding
        //NSString *json =[absoluteString stringByReplacingOccurrencesOfString:@"imageclick://" withString:@""];
       
        
        NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:request.URL.query];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
        
#ifdef ipad
        float x = [[dict objectForKey:@"x"] floatValue]
        + rootController.splitWidth
        + rootController.splitPosition
        + webView.frame.origin.x;
#else
        //TODO
        float x = 0;
#endif
        float y = [[dict objectForKey:@"y"] floatValue]+ webView.frame.origin.y ;
        float width = [[dict objectForKey:@"width"] floatValue];
        float height = [[dict objectForKey:@"height"] floatValue];
        NSString *path = request.URL.path;
        if (!path) {
            return NO;
        }
        
        NSString *imageId = [path lastPathComponent];
        if ([imageId isEqualToString:@"webview_img_loading.png"])
        {
            //Loading
        }
        else
        {
            NSString *filePath =[path stringByReplacingOccurrencesOfString:@"file/" withString:@""];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            if (image) {
                NewsGalleryView *galleryView = [NewsGalleryView sharedInstance];
                [galleryView showGallery:image :CGRectMake(x, y, width, height)];
                
            }
            
        }
    }else if(webStyle == NewsWebrStylePhoneNews){
        //手机报
        DJLog(@"手机报链接：%@",url.absoluteString);
        if (![url.absoluteString isEqual:@"about:blank"])
        {
            if ([[url scheme] isEqual:@"http"])
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                ReadNewsController *viewController = [[ReadNewsController alloc] init];
                viewController.USERAGENT = ReadNewsUSERAGENT_IPHONE;
                viewController.webUrl = [url.absoluteString completeUrl];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
                nav.modalPresentationStyle = UIModalPresentationCurrentContext;
                UIViewController *rootController = appDelegate.window.rootViewController;
                [rootController presentModalViewController:nav animated:YES];
                return  NO;                                                                        
            }
            else if ([[url scheme] isEqual:@"applewebdata"])
            {
                PhoneNewsData *item = [channels objectAtIndex:currentIndex];
                PhoneNewsManager *manager = [PhoneNewsManager sharedInstance];
                NSString *path = [NSString stringWithFormat:@"%@/%@",
                                  [manager getUnzipPath:item],
                                  [url.absoluteString lastPathComponent]];
                NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                if (html.length <=1) {
                    return NO;
                }
                DJLog(@"%@",html);
                
                [self webLoadData:item andStyle:WebViewLoadHtmlAnimateReloadStyle html:html];
                
                return YES;
            }
            
        }
        return YES;
    }
    
    
    return YES;
}

#pragma mark - 分享，字体，收藏
-(void)setWebViewSize:(UIButton *)sender
{
    WebviewFontController *controller = [[WebviewFontController alloc] initWithStyle:UITableViewStylePlain];
    controller.fontDelegate = self;
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:controller];
    
    //popover.arrowDirection = FPPopoverArrowDirectionAny;
    popover.tint = FPPopoverDefaultTint;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover.contentSize = CGSizeMake(240, 100);
    }
    popover.arrowDirection = FPPopoverArrowDirectionUp;
    //sender is the UIButton view
    [popover presentPopoverFromView:sender];
    
}

-(void)collectionNews:(UIButton *)sender
{
    
    
    if (webStyle == NewsWebrStylePhoneNews)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认取消收藏"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        [alertView show];
    }
    else if (webStyle == NewsWebrStyleFav)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认取消收藏"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        [alertView show];
        
    }
    else
    {
        ThreadSummary *item = [channels objectAtIndex:currentIndex];
        FavsManager *manager = [FavsManager sharedInstance];
        BOOL collect = [manager isThreadInFav:item];
        if (collect)
        {
            [collection setImage:[UIImage imageNamed:@"newsWeb_fav.png"]
                        forState:UIControlStateNormal];
            [manager removeFav:item];
        }else
        {
            [manager addFav:item withCompletionHandler:^(BOOL success) {
                [collection setImage:[UIImage imageNamed:@"newsWeb_faved.png"]
                            forState:UIControlStateNormal];
            }];
        }
    }
}

//分享新闻
- (void)shareNews:(UIButton*)sender
{
    ShareController *controller = [ShareController sharedInstance];
    NSString *text;
    if (webStyle != NewsWebrStylePhoneNews) {
        text = [NSString stringWithFormat:@"#冲浪快讯# 《%@》 %@",
                self.currentThread.title == nil ? @"" : self.currentThread.title,
                self.currentThread.desc == nil ? @"" : self.currentThread.desc];
        
    }
    [controller showShareViewWithShareText:text shareImage:nil shareURL:self.currentThread.newsUrl == nil ? @"" : self.currentThread.newsUrl];
}

#pragma mark - WebviewFontControllerDelegate
-(void)sliderChanged:(float)size
{
    [[AppSettings sharedInstance]setFloat:size forKey:FLOATKEY_ReaderBodyFontSize];
    NSString *js = [NSString stringWithFormat:@"setArticleFontSize(%f)",size];
    [webview stringByEvaluatingJavaScriptFromString:js];
}
#pragma mark - downloadedImages

-(void)downloadedImages:(NSArray *)imageArr
{
    for(ImageDownloadingTask *task in imageDownloaderArr)
    {
        [[ImageDownloader sharedInstance] cancelDownload:task];
        
    }
    [imageDownloaderArr removeAllObjects];
    
    
    ThreadSummary *item = [channels objectAtIndex:currentIndex];
    NSString *threadPath = [PathUtil pathOfThread:item];
    for(ThreadContentImageInfo * imageInfo in imageArr)
    {
        NSString *imgPath = [NSString stringWithFormat:@"%@/%@",threadPath,imageInfo.imageId];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:imgPath ]) {
            // 请求图片数据
            if (imageInfo.imageUrl != nil &&
                ![imageInfo.imageUrl isEqualToString:@""]){
                NSString *imageUrl = [NSString stringWithFormat:@"%@&w=600",imageInfo.imageUrl];
                ImageDownloadingTask *task = [[ImageDownloadingTask alloc] init];
                [task setImageUrl:imageUrl];
                task.userData = imageInfo.imageId;
                [task setTargetFilePath:imgPath];
                task.progressHandler = ^(double percent,ImageDownloadingTask* idt)
                {
                    if(!webview.hidden && webview.htmlDomReady)
                    {
                        [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setImgPercent('%@','%d%%');",imageInfo.imageId,(int)(percent * 100)]];
                    }
                };
                
                [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                    ///*
                    if(succeeded && idt != nil &&
                       [FileUtil fileExists:idt.targetFilePath]
                       && !webview.hidden && webview.htmlDomReady){
                        //隐藏下载进度
                        [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hideImgPercentDiv('%@');",imageInfo.imageId]];
                        // 通知图片发生改变
                        
                        [imageDownloaderArr removeObject:idt];
                        ThreadContentImageMapping *mapping = [[ThreadContentImageMapping alloc]
                                                              initWithThread:item];
                        [mapping addMappingWithUrl:imageInfo.imageUrl andImgLocalFileName:idt.targetFilePath];
                        
                        NSString *js = [NSString stringWithFormat:@"document.getElementById(\"%@\").src=\"file://%@\"",
                                        imageInfo.imageId,idt.targetFilePath];
                        NSString *script =[webview stringByEvaluatingJavaScriptFromString:js];
                        if ([script isEqualToString:@""]) {
                            //图片加载失败，未知道如何处理，返回script为空。
                            [webview stringByEvaluatingJavaScriptFromString:js];
                            DJLog(@"图片加载失败,图片存在,重新加载");
                        }
                    }
                    else
                    {
                        DJLog(@"图片加载失败,图片未存在%@",idt.imageUrl);
                    }
                    //*/
                }];
                [imageDownloaderArr addObject:task];
                [[ImageDownloader sharedInstance] download:task];
            }
        }
        else
        {
            ImageDownloadingTask *task = [[ImageDownloadingTask alloc] init];
            task.userData = imageInfo.imageId;
            [task setTargetFilePath:imgPath];
            [imageDownloaderArr addObject:task];
        }
    }
}
#pragma mark - TapDetectingWindowDelegate
- (void)userDidTapWebView:(id)tapPoint
{
    for (NSString *item in tapPoint) {
        DJLog(@"%@",item);
    }
}

-(void)multiDragBegan:(CGPoint)startPoint
{
    //DJLog(@"Began－|－|%@",NSStringFromCGPoint(startPoint));
}
-(void)multiVerticalDragDelta:(CGFloat)verticalChanged
{
    //DJLog(@"|||||| %f",verticalChanged);
}
-(void)multiVerticalDragEnded
{
    //DJLog(@"||||||%@",@"Ended");
}
-(void)multiHorizontalDragDelta:(CGFloat)horizontalChanged
{
    //DJLog(@"－－－－－%f",horizontalChanged);
    if (horizontalChanged >40.0f)
    {
        [self popViewControllerAnimated:YES];
    }
    
}
-(void)multiHorizontalDragEnded
{
    //DJLog(@"－－－－－%@",@"Ended");
}
-(void)backEvent
{
    [self popViewControllerAnimated:YES];
}
-(void)reloadWebview
{
    loading_Eror.hidden = YES;
    [self tableView:[channels objectAtIndex:currentIndex]
     didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];
}
#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 1) {
        if (webStyle == NewsWebrStylePhoneNews)
        {
            SurfNotification *surfNotification =  [SurfNotification surfNotificatioIndicatorAutoHide:NO];
            PhoneNewsManager *manager = [PhoneNewsManager sharedInstance];
            [manager cancelPhoneNewsFavs:currentNewsData complete:^(BOOL success)
             {
                 [surfNotification hideNotificatioIndicator:^(BOOL finished)
                  {
                      if (success)
                      {
                          [self popViewControllerAnimated:NO];
                          [SurfNotification surfNotification:@"操作成功"];
                      }else
                      {
                          [SurfNotification surfNotification:@"操作失败，请重新尝试"];
                      }
                  }];
             }];
        }
        else if (webStyle == NewsWebrStyleFav)
        {
            ThreadSummary *item = [channels objectAtIndex:currentIndex];
            FavsManager *manager = [FavsManager sharedInstance];
            [manager removeFav:item];
            [self popViewControllerAnimated:NO];
            [SurfNotification surfNotification:@"操作成功"];
        }
        
    }
}
@end
