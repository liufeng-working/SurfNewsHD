//
//  NewestRootController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NewestRootController.h"
#import "GTMHTTPFetcher.h"
#import "SubsChannelsManager.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelThreadsResponse.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "NewsWebController.h"
#import "PathUtil.h"
#import "AppDelegate.h"
#import "ReadNewsController.h"


@interface NewestRootController ()

@property(nonatomic,strong) HotChannelsView *leftNewsView;
@property(nonatomic,strong) HotInfomationInChannelView *rightNewsView;
@property(nonatomic,weak) HotChannel* hotchanel;

@end

@implementation NewestRootController
@synthesize leftNewsView;
@synthesize rightNewsView;
@synthesize hotchanel;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = @"最近更新";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    CGRect tempRect = CGRectMake(0.0f, kPaperTopY, kPaperLeftWidth, kContentHeight-kPaperTopY-kPaperBottomY);
    self.leftNewsView =[[HotChannelsView alloc] initWithFrame:tempRect];
    self.leftNewsView.delegate = self;
    [self.leftNewsView setRefreshDelegate:self];
    [self.view addSubview:self.leftNewsView];
    

    tempRect.origin.x += tempRect.size.width + kPaperWhiteWidth;
    tempRect.size.width = kHotInformationWidth;
    self.rightNewsView =[[HotInfomationInChannelView alloc] initWithFrame:tempRect];
    [self.rightNewsView setReadThreadDelegate:self];
    [self.rightNewsView setRefreshDelegate:self];
    [self.view addSubview:self.rightNewsView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - request
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestNewsData];         // 请求新闻数据
    [self requestHotInfomation];    // 请求热门资讯
}

// 请求新闻数据
-(void)requestNewsData
{
    NewestManager *manager = [NewestManager sharedInstance];
    [leftNewsView reloadChannels:nil array:[manager loadLocalNewestChannels] date:[manager lastUpdateTime]];
    [leftNewsView setLoadingState];
    
    // 刷新新闻
    [manager refreshNewestCompletionHandler:^(NewestManagerResult *result)
     {
         if (result.succeeded && [result.threads count]>0) {
             [leftNewsView reloadChannels:nil array:result.threads date:[manager lastUpdateTime]];
         }
         [leftNewsView cancelLoadingState];
     }];
}

// 请求热门资讯
-(void)requestHotInfomation{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    HotChannel *hotChannel =[tm getAboutSubsChannel:nil];
    NSArray *subsS = [tm getLocalThreadsForHotChannel:hotChannel];
    NSDate *lastUpdate = [tm lastRefreshDateOfHotChannel:hotChannel];
    [rightNewsView loadHotInfomationWithArray:subsS updateTime:lastUpdate];
}

//判断帖子是否模糊存在
-(BOOL)isDuplicatedThreadExist:(ThreadSummary*)thread
                       inArray:(NSArray*)threadsArray
{
    for (ThreadSummary* t in threadsArray)
    {
        if(t.threadId == thread.threadId
           || [t.title isEqualToString:thread.title])
            return YES;
    }
    return NO;
}

#pragma mark ReadThreadContentDelegate

- (void)readThreadContent:(id)sender threadSummary:(ThreadSummary *)thread{
    if (sender == nil || thread == nil) { return; }
    
    if (![thread isUrlOpen]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        ReadNewsController *viewController = [[ReadNewsController alloc] init];
        viewController.webUrl = [thread.newsUrl completeUrl];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.modalPresentationStyle = UIModalPresentationCurrentContext;
        UIViewController *rootController = appDelegate.window.rootViewController;
        [rootController presentModalViewController:nav animated:YES];
    }
    else
    {
        NewsWebController *viewController = [[NewsWebController alloc] init];
        if (sender == leftNewsView) {
            viewController.webStyle = NewsWebrStyleNewest;
        }
        else if (sender == rightNewsView){
            ThreadsManager *tm = [ThreadsManager sharedInstance];
            HotChannel *hotChannel =[tm getAboutSubsChannel:nil];
            viewController.webStyle = NewsWebrStyleHot;
            viewController.hotChannel = hotChannel;
        }
        viewController.currentThread = thread;
        viewController.title = @"最近更新";;
        [self pushViewController:viewController animated:YES];
    }
}


#pragma mark LoadContentDelegate
// 刷新内容
- (void)refreshContent:(id)sender{
    if (sender == leftNewsView) {
        NewestManager *manager = [NewestManager sharedInstance];
        [manager refreshNewestCompletionHandler:^(NewestManagerResult *result)
         {
             if (result.succeeded) {
                 if ([result.threads count] > 0) {
                     [leftNewsView reloadChannels:nil array:result.threads date:[NSDate date]];
                 }
                 else {
                     [leftNewsView updateRefreshDate:[NSDate date]];
                     [SurfNotification surfNotification:@"现在是最新数据"];
                 }                 
             }
             [leftNewsView cancelLoadingState];
         }];
    }
    else if(sender == rightNewsView){        
        ThreadsManager *tm = [ThreadsManager sharedInstance]; // 帖子管理器        
        __block SubsChannel* subsChannel= [tm getAboutHotChannel:hotchanel]; 
        [tm refreshSubsChannel:self subsChannel:subsChannel withCompletionHandler:^(ThreadsFetchingResult* result){
            [rightNewsView cancelLoading];
            if (subsChannel.channelId == result.channelId && [result succeeded])
            {
                NSDate* update = [tm lastRefreshDateOfSubsChannel:subsChannel];
                if(![result noChanges]){              
                    [rightNewsView loadHotInfomationWithArray:[result threads] updateTime:update];
                }
                else{
                    // 提示数据是最新的
                    [rightNewsView updateRefreshDate:update];
                    [SurfNotification surfNotification:@"现在是最新数据"];
                }
            }
        }];
    }
}
// 加载更多
- (void)loadMoreContent:(id)sender{
    NewestManager *manager = [NewestManager sharedInstance];
    if (sender == leftNewsView) {                
        [manager getMoreForNewestCompletionHandler:^(NewestManagerResult *result)
         {
             if (result.succeeded && [result.threads count]>0) {
                 [leftNewsView moreChannels:nil array:result.threads date:[NSDate date]];
             }
             else{
                 [leftNewsView updateMoreDate:[NSDate date]];
                 [SurfNotification surfNotification:@"现在没有更多数据"];   
             }
             [leftNewsView cancelLoadingState];
         }];
    }
    else if(sender == rightNewsView){
        ThreadsManager *tm = [ThreadsManager sharedInstance];
        __block SubsChannel* subsChannel= [tm getAboutHotChannel:hotchanel];        
        if ([tm isSubsChannelInRefreshing:subsChannel] || [tm isSubsChannelInGettingMore:subsChannel]) {
            [rightNewsView cancelLoading];
        }
        else{
            [tm getMoreForSubsChannel:self subsChannel:subsChannel withCompletionHandler:^(ThreadsFetchingResult *result)
             {
                 if (subsChannel.channelId == result.channelId && [result succeeded])
                 {
                     NSDate* update = [tm lastGetMoreDateOfSubsChannel:subsChannel];
                     if (![result noChanges]) {                        
                         [rightNewsView loadMoreThreadsSummary:[result threads] updateTime:update];
                     }else{
                         [rightNewsView updateMoreDate:update];
                         [SurfNotification surfNotification:@"现在没有更多数据"];                        
                     }
                 }
                 [rightNewsView cancelLoading];
             }];
        }
    }
}


@end
