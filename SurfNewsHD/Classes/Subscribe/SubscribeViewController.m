//
//  SubscribeViewController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubscribeViewController.h"
#import "SubsChannelsManager.h"
#import "AppDelegate.h"
#import "SurfRootViewController.h"
#import "HotChannelsView.h"
#import "HotInfomationInChannelView.h"
#import "AppDelegate.h"
#import "ReadNewsController.h"
#import "NSString+Extensions.h"

@interface SubscribeViewController ()

@property(nonatomic,strong) HotChannelsView *leftNewsView;
@property(nonatomic,strong) HotInfomationInChannelView *rightNewsView;
@property(nonatomic,weak) HotChannel* hotchanel;

@end

@implementation SubscribeViewController
@synthesize subscribeID;
@synthesize subsChannel;
@synthesize leftNewsView;
@synthesize rightNewsView;


- (id)init
{
    self = [super init];
    if (self)
    {
        subsArray = [NSMutableArray new];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    
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
    
    
    // 订阅按钮
    if([self showSubscribeButton]){
        CGRect btnRect = CGRectMake(kContentWidth - 60.0f, 41.f, 60.0f, 24.0f);
        subsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [subsButton setFrame:btnRect];
        [subsButton addTarget:self action:@selector(subsButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        [self setSubsButtonState];
        [self.view addSubview:subsButton];
        
    
        // loading 状态
        float loadingWidth = 40.f;
        float loadingHeight = 40.f;
        btnRect.origin.x += ((btnRect.size.width - loadingWidth) * 0.5f);
        btnRect.origin.y += ((btnRect.size.height - loadingHeight) * 0.5f);
        btnRect.size.width = loadingWidth;
        btnRect.size.height = loadingHeight;
        subsBtnLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [subsBtnLoading setFrame:btnRect];
        [subsBtnLoading setHidden:YES];
        [self.view addSubview:subsBtnLoading];
        
        
    }
    
    // 返回按钮
    if ([self showBackButton]) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn addTarget:self action:@selector(backButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImage:[UIImage imageNamed:@"backBtn"]
                 forState:UIControlStateNormal];
        backBtn.frame = CGRectMake(0.0f, 32.0f, 38.0f, 36.0f);
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(6.0f, 5.0f, 3.0f, 5.0f)];
        [self.view addSubview:backBtn];

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestSubsChannels:subsChannel];
    [self requestHotInfomation:subsChannel];
    if ([self showBackButton]) {        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
        [rootController setSplitPosition:kSplitPositionMin animated:YES];
        UIPanGestureRecognizer * tapGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
        tapGR.delegate = self;
        [self.view addGestureRecognizer: tapGR];
    }
}
-(void)btnLong:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender translationInView: self.view];
    if (point.x > 70.0f)
    {
        [self popViewControllerAnimated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /*
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfWindow *window = appDelegate.window;
    [window detach];
    */
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSubsChannel:(SubsChannel *)_subsChannel
{
    subsChannel = _subsChannel;
    subscribeID = [NSString stringWithFormat:@"%ld",subsChannel.channelId];
    
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    [self setHotchanel:[tm getAboutSubsChannel:subsChannel]];
}

// 请求热门资讯
-(void)requestHotInfomation:(SubsChannel *)channel{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    HotChannel *hotchannel = [tm  getAboutSubsChannel:subsChannel];
    NSArray *subsS = [tm getLocalThreadsForHotChannel:hotchannel];
    NSDate *lastUpdate = [tm lastRefreshDateOfHotChannel:hotchannel];
    [self.rightNewsView loadHotInfomationWithArray:subsS updateTime:lastUpdate];
}

// 请求订阅详情
-(void)requestSubsChannels:(SubsChannel *)channel
{
// 旧版本
//    [subsArray removeAllObjects];// 删除旧数据    
//    ThreadsManager *tm = [ThreadsManager sharedInstance];
//    [subsArray addObjectsFromArray:[tm getLocalThreadsForSubsChannel:channel]];
//
//    NSDate* updateTime = [tm lastRefreshDateOfSubsChannel:channel];
//    [self.leftNewsView reloadChannels:nil array:subsArray date:updateTime];
//    [self.leftNewsView setLoadingState];
//
//    // 如何正在刷新，就取消刷新
//    if([tm isSubsChannelInRefreshing:channel]){
//        [tm cancelRefreshSubsChannel:channel];
//    }
//    
//    // 刷新频道详情
//    [tm refreshSubsChannel:channel withCompletionHandler:^(ThreadsFetchingResult* result){
//        if ([result succeeded] ) {
//            [subsArray removeAllObjects]; // 删除旧数据
//            [subsArray addObjectsFromArray:[result threads]];
//            [leftNewsView reloadChannels:nil array:subsArray date:[NSDate date]];
//        }
//        [leftNewsView cancelLoadingState];
//    }];
    
// by xuxg 替换版本
// 检测是否需要刷新，如何正在刷新，就取消刷新
    
    // 如何正在刷新，就取消刷新
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if([tm isSubsChannelInRefreshing:channel]){
        return;
    }

    [subsArray removeAllObjects];// 删除旧数据   
    [subsArray addObjectsFromArray:[tm getLocalThreadsForSubsChannel:channel]];

    NSDate* updateTime = [tm lastRefreshDateOfSubsChannel:channel];
    [self.leftNewsView reloadChannels:nil array:subsArray date:updateTime];
    [self.leftNewsView setLoadingState];

    // 刷新频道详情
    [tm refreshSubsChannel:self subsChannel:channel withCompletionHandler:^(ThreadsFetchingResult* result){
        if ([result succeeded] ) {
            [subsArray removeAllObjects]; // 删除旧数据
            [subsArray addObjectsFromArray:[result threads]];
            [leftNewsView reloadChannels:nil array:subsArray date:[NSDate date]];
        }
        [leftNewsView cancelLoadingState];
    }];
}

- (void)backButtonEvent
{
    [self popViewControllerAnimated:YES];
}

// 订阅/退订按钮事件
- (void)subsButtonEvent{
    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    BOOL isSubs = [scm isChannelSubscribed:[subsChannel channelId]];
    if (isSubs) {
        [scm removeSubscription:subsChannel];
    }
    else{
        [scm addSubscription:subsChannel];
    }
    
    [subsButton setHidden:YES];
    [subsBtnLoading setHidden:NO];
    [subsBtnLoading startAnimating];
    
    [scm commitChangesWithHandler:^(BOOL succeeded) {        
        [subsButton setHidden:NO];
        [subsBtnLoading setHidden:YES];
        [subsBtnLoading stopAnimating];        
        
        
        if (succeeded) {
            [self setSubsButtonState];
            
            // 弹出提示信息
            if([scm userSubsInfoUpSucesss]){
                NSString *notice = nil;
                if (_isSubs) {
                    notice = [NSString stringWithFormat:@"%@,订阅成功", [subsChannel name]];
                }
                else{
                    notice = [NSString stringWithFormat:@"%@,退订成功", [subsChannel name]];
                }
                [SurfNotification surfNotification:notice];
            }
        }
        else{
            // 提交失败处理，弹出提示框
            if([scm userSubsInfoUpSucesss]){
                NSString *notice = nil;
                if (_isSubs) {
                    notice = [NSString stringWithFormat:@"%@,退订失败", [subsChannel name]];
                }
                else{
                    notice = [NSString stringWithFormat:@"%@,订阅失败", [subsChannel name]];
                }
                [SurfNotification surfNotification:notice];
            }
        }
    }];
}
- (void)setSubsButtonState{
    UIImage *buttonImg = nil;
    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    _isSubs = [scm isChannelSubscribed:[subsChannel channelId]];   
    if (_isSubs) {
        buttonImg = [UIImage imageNamed:@"unsubscribeButton"];
    }
    else{
        buttonImg = [UIImage imageNamed:@"subscribeButton"];
    }
    [subsButton setBackgroundImage:buttonImg forState:UIControlStateNormal];
   
}
#pragma mark - MultiDragDelegate
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
    if (horizontalChanged > 40.0f)
    {
        [self popViewControllerAnimated:YES];
    }
    
}
-(void)multiHorizontalDragEnded
{
    //DJLog(@"－－－－－%@",@"Ended");
}


#pragma mark LoadContentDelegate
// 刷新热门资讯
- (void)refreshContent:(id)sender{
    if (sender == nil) { return; }    
    
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    if (sender == leftNewsView) {
        // 帖子管理器
        if([tm isSubsChannelInRefreshing:self.subsChannel] || [tm isSubsChannelInGettingMore:self.subsChannel]) {
            [leftNewsView cancelLoadingState];
        } else{
            [tm refreshSubsChannel:self subsChannel:self.subsChannel withCompletionHandler:^(ThreadsFetchingResult* result){
                if (self.subsChannel.channelId == result.channelId && [result succeeded]) {
                    NSDate* update = [tm lastRefreshDateOfSubsChannel:self.subsChannel];
                    if(![result noChanges]){
                        [subsArray removeAllObjects]; // 删除旧的频道详情                        
                        [subsArray addObjectsFromArray:[result threads]];
                        [leftNewsView reloadChannels:nil array:subsArray date:update];
                    } else {
                        // 提示数据是最新的
                        [SurfNotification surfNotification:@"现在是最新数据"];
                        [leftNewsView updateRefreshDate:update];
                    }
                } 
                [leftNewsView cancelLoadingState];               
            }];
        }
    }
    else if(sender == rightNewsView){
        // 帖子管理器
        if([tm isHotChannelInRefreshing:self hotChannel:self.hotchanel] ||
           [tm isHotChannelInGettingMore:self hotChannel:self.hotchanel]){
            [rightNewsView cancelLoading];
        }
        else{
            [tm refreshHotChannel:self hotChannel:self.hotchanel withCompletionHandler:^(ThreadsFetchingResult *result){
                [rightNewsView cancelLoading];
                if (self.hotchanel.channelId == result.channelId && [result succeeded])
                {
                    NSDate* update = [tm lastRefreshDateOfHotChannel:self.hotchanel];
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
}

// 加载更多热门资讯
- (void)loadMoreContent:(id)sender{
    if (sender == nil) { return; }
    
    
    ThreadsManager *tm = [ThreadsManager sharedInstance];    
    if (sender == leftNewsView) {
        if([tm isSubsChannelInRefreshing:self.subsChannel] || [tm isSubsChannelInGettingMore:self.subsChannel]) {
            [leftNewsView cancelLoadingState];
        } else{
            [tm getMoreForSubsChannel:self subsChannel:self.subsChannel withCompletionHandler:^(ThreadsFetchingResult* result){
                if ([result succeeded]) {
                    NSDate* update = [tm lastGetMoreDateOfSubsChannel:self.subsChannel];
                    if(![result noChanges]){                       
                        [subsArray addObjectsFromArray:[result threads]];
                        [leftNewsView moreChannels:nil array:[result threads] date:update];
                    } else {
                        // 提示数据是最新的
                        [leftNewsView updateMoreDate:update];
                        [SurfNotification surfNotification:@"现在没有更过数据"];
                    }
                }
                [leftNewsView cancelLoadingState];
            }];
        }
    }
    else if (sender == rightNewsView){
        if ([tm isHotChannelInRefreshing:self hotChannel:self.hotchanel]||
            [tm isHotChannelInGettingMore:self hotChannel:self.hotchanel]) {
            [rightNewsView cancelLoading];
        }
        else{
            [tm getMoreForHotChannel:self hotChannel:self.hotchanel withCompletionHandler:^(ThreadsFetchingResult *result)
             {
                 if (self.hotchanel.channelId == result.channelId && [result succeeded])
                 {
                    NSDate* update = [tm lastGetMoreDateOfHotChannel:self.hotchanel];
                     if (![result noChanges]) {                        
                         [rightNewsView loadMoreThreadsSummary:[result threads] updateTime:update];
                     }else{
                         [rightNewsView updateMoreDate:update];
                         [SurfNotification surfNotification:@"现在没有更过数据"];
                     }
                 }
                 [rightNewsView cancelLoading];
             }];
        }
    }
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
            viewController.subsChannel = subsChannel;
            viewController.webStyle = NewsWebrStyleSubs;
        }
        else if (sender == rightNewsView){
            ThreadsManager *tm = [ThreadsManager sharedInstance];
            HotChannel *hotChannel = [tm getAboutSubsChannel:subsChannel];
            viewController.hotChannel = hotChannel;
            viewController.webStyle = NewsWebrStyleHot;
        }
        viewController.currentThread = thread;
        viewController.title = subsChannel.name;
        [self pushViewController:viewController animated:YES];
    }
}
@end
