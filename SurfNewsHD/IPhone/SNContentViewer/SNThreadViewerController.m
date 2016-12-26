//
//  SNContentViewerController.m
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-3.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SNThreadViewerController.h"
#import "DispatchUtil.h"
#import "SurfHtmlGenerator.h"
#import "PictureBox.h"
#import "PhoneReadController.h"
#import "ThreadsManager.h"
#import "SubsChannelSummaryViewController.h"
#import "HotChannelsManager.h"
#import "RssSourceData.h"
#import "SNPNEView.h"
#import "RankingShareCtl.h"
#import "SNNewsCommentViewController.h"
#import "AdvertisementManager.h"
#import "SubsChannelsManager.h"
#import "SurfNewsViewController.h"
#import "SNNewsContentInfoResponse.h"
#import "SNReportViewController.h"
#import "PhoneLoginController.h"
#import "UIView+NightMode.h"
#import "SNThreadImageBrowserController.h"


#define kUrlMenuItmes @[@"分享给朋友", @"其它方式打开",@"刷新页面"];

@interface SNThreadViewerController () <SurfEnergyDelegate,RankingShareCtlDelegate>
{
    
    __weak SNToolBar*          mToolBar;
    BOOL                       mToolBarInAnim;        //工具栏动画是否正在进行中
    BOOL                       mToolBarHidden;        //工具栏是否被隐藏（或者正在被隐藏的路上）
    
    
    // 图片预览模式
    __weak PictureBox *mPictureBox;
    RankingShareCtl *rankingShare;
    
    // 加载更多新闻数据
    BOOL mIsLoadingMoreDatas;
    
    SNPNEView *_energyView; // 正负能量
    
    long energyValue; //新闻能量值
    
    UIView *_energyShareView;
    
    // 右滑动进入评论手势
    UISwipeGestureRecognizer *_rightSwipeGestureRecognizer;
    
    __weak UIButton *_fontSizeButton;
    
    SNThreadViewer *_threadView;
    
    ThreadSummary *_thread;
    BOOL _isFromColler;
    
    UILabel *_newsTitle; // 新闻标题(用在外链类型新闻)
    
    UIImageView * _logoImageView;   //新闻正文的快讯logo图片
}
@end

@implementation SNThreadViewerController

+ (void)initialize {
    NSDictionary *dic =
    @{@"UserAgent":[NSMutableURLRequest surfNewsUserAgent]};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}


// 是否从收藏打开
-(id)initWithThread:(ThreadSummary*)thread
{
    self = [super init];
    if (self) {
        self.titleState = SNState_TopBar | SNState_GestureGoBack |
        SNState_TopBar_GoBack_Gray;
        _thread = thread;
    }
    return self;
}

// 是否从收藏打开
-(id)initWithThread:(ThreadSummary*)thread
      isFromCollect:(BOOL)isCollect
{
    self = [super init];
    if (self) {
        self.titleState = SNState_TopBar | SNState_GestureGoBack |
        SNState_TopBar_GoBack_Gray;
        _thread = thread;
        _isFromColler = isCollect;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGRect viewBounds = self.view.bounds;
    CGRect visibleFrame = viewBounds;
    visibleFrame.origin.y = self.StateBarHeight;
    visibleFrame.size.height -= (self.StateBarHeight);


    
    if ([_thread isUrlOpen]) {
        // 外联方式打开没有底部工具栏，有更多按钮
        UIImage *btnImg = [UIImage imageNamed:@"more_menu"];
        UIImage * btnImgH=[UIImage imageNamed:@"more_menu_highlighted"];
        CGSize btnSize = [self topGoBackView].bounds.size;
        CGFloat btnX = width - btnSize.width+10;
        CGFloat btnY = self.StateBarHeight - btnSize.height;
        CGFloat btnImgTop = (btnSize.height - btnImg.size.height) / 2.f;
        CGFloat btnImgLeft = (btnSize.width - btnImg.size.width) / 2.f;
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreBtn setImage:btnImg forState:UIControlStateNormal];
        [moreBtn setImage:btnImgH forState:UIControlStateHighlighted];
        [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(btnImgTop, btnImgLeft, btnImgTop, btnImgLeft)];
        [moreBtn setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
        [moreBtn addTarget:self action:@selector(webUrlMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [[self topBarView] addSubview:moreBtn];
        
        
        // 需要显示title
        CGFloat tX = 50;
        CGFloat tWith = width - tX - tX;
        UIFont *tFont = [UIFont systemFontOfSize:15];
        CGRect tR = CGRectMake(tX, 0, tWith, tFont.lineHeight);
        UILabel *title = [[UILabel alloc] initWithFrame:tR];
        _newsTitle = title;
        title.font = tFont;
        [title setUserInteractionEnabled:NO];
        title.textAlignment = NSTextAlignmentCenter;
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor colorWithHexString:@"999999"]; //修改字体颜色
        title.numberOfLines = 1;
        title.center = CGPointMake(title.center.x, [self topGoBackView].center.y);
        [title setHighlighted:YES];
        [[self topBarView] addSubview:title];
        
    }
    else {
        // 正文模式打开
        UIImage *btnImg = [UIImage imageNamed:@"newsFontSize"];
        CGSize btnSize = [self topGoBackView].bounds.size;
        CGFloat btnX = width - btnSize.width+10;
        CGFloat btnY = self.StateBarHeight - btnSize.height;
        CGFloat btnImgTop = (btnSize.height - btnImg.size.height) / 2.f;
        CGFloat btnImgLeft = (btnSize.width - btnImg.size.width) / 2.f;
        UIButton *fontButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fontButton setHidden:YES];
        [fontButton setImage:btnImg forState:UIControlStateNormal];
        [fontButton setImageEdgeInsets:UIEdgeInsetsMake(btnImgTop, btnImgLeft, btnImgTop, btnImgLeft)];
        [fontButton setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
        [fontButton addTarget:self action:@selector(webFontSizeClick:) forControlEvents:UIControlEventTouchUpInside];
        [[self topBarView] addSubview:_fontSizeButton = fontButton];
        
        visibleFrame.size.height -= [SNToolBar normalHeight];
        
        //“快讯“字样的logo
        UIImage * logoImg = [UIImage imageNamed:@"kx_logo"];
        CGFloat logoW = logoImg.size.width;
        CGFloat logoH = logoImg.size.height;
        CGRect logoR = CGRectMake(0, 0, logoW, logoH);
        UIImageView * logoView = [[UIImageView alloc]initWithFrame:logoR];
        _logoImageView = logoView; //全局变量，留着备用
        CGPoint center = CGPointMake([self topBarView].center.x, [self topGoBackView].center.y-2.f); // 加上2，为了视觉效果
        logoView.center = center;
        logoView.image = logoImg;
        [[self topBarView] addSubview:logoView];
    }
    
    _threadView = [SNThreadViewer new];
    _threadView.delegate = self;
    _threadView.frame = visibleFrame;
    [_threadView loadWithThread:_thread
                      isCollect:_isFromColler];
    [self.view addSubview:_threadView];
    
    
    // 工具栏初始化
    SNToolBar* toolBar =
    [[SNToolBar alloc] initWithToolBarType:SNToolBarTypeWeb
                                    thread:_thread];
    [toolBar setDeletage:self];
    [toolBar setHidden:YES];
    toolBar.isCollect = _isFromColler;
    [self.view addSubview:mToolBar = toolBar];

    
    // 左边距滑动返回，需要把工具栏排除在外
    CGFloat noGestureH = [SNToolBar normalHeight];
    CGFloat noGestureW = CGRectGetWidth(self.view.bounds);
    CGFloat noGestureY = CGRectGetHeight(self.view.bounds)-noGestureH;
    self.noGestureRecognizerRect = CGRectMake(0, noGestureY, noGestureW, noGestureH);
    
    
    // 标记已读
    [[ThreadsManager sharedInstance] markThreadAsRead:_thread];
    
    
    // 右滑动进入评论手势
    _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_rightSwipeGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 更新底部工具评论状态
    [mToolBar refreshCommentItem];
    
    // 判断是否是开启评论功能的新闻正文，提示手势引导弹层
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasCache = [userDefaults boolForKey:@"hasCache"];
    ThreadSummary *ts = [self currentThread];
    if ([ts isComment] && !hasCache) {
        UIImageView *guideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_right"]];
        [guideView.image setAccessibilityIdentifier:@"right"];
        guideView.frame = [UIScreen mainScreen].bounds;
        guideView.userInteractionEnabled = YES;
        guideView.tag = 100;
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"guide_btn_right"] forState:UIControlStateNormal];
        btn.bounds = CGRectMake(0, 0, btn.currentImage.size.width, btn.currentImage.size.height);
        btn.center = CGPointMake(guideView.center.x, guideView.frame.size.height - 95);
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [guideView addSubview:btn];
        [self.view addSubview:guideView];
    }
}

- (void)btnClicked:(UIButton *)button {

    UIImageView *guideView = (UIImageView *)[self.view viewWithTag:100];
    
    if ([[guideView.image accessibilityIdentifier] isEqualToString:@"right"]) {
        guideView.image = [UIImage imageNamed:@"guide_left"];
        [guideView.image setAccessibilityIdentifier:@"left"];
        [button setImage:[UIImage imageNamed:@"guide_btn_left"] forState:UIControlStateNormal];
    } else {

        [guideView removeFromSuperview];
        // 向文件中写入 设置 缓存清理为NO
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"hasCache"];
        [userDefaults synchronize];
    }
}

- (void)setClippingRect:(CGRect)rect
{
    // Create a mask layer and the frame to determine what will be visible in the view.
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    // Create a path with the rectangle in it.
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    
    // Set the path to the mask layer.
    maskLayer.path = path;
    
    // Release the path since it's not covered by ARC.
    CGPathRelease(path);
    
    // Set the mask of the view.
    self.view.layer.mask = maskLayer;
}


#pragma mark -
#pragma mark ----private utilities----

- (void)showToolBarAnimated:(void (^)(BOOL finished))completion
{
    /**
     UIViewAnimationOptionBeginFromCurrentState 选项使得一个新动画可以从一个尚未结束的动画状态中继续
     UIViewAnimationOptionAllowUserInteraction  选项使得动画可以被交互（从layer中移除）
     */
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         mToolBar.center = CGPointMake(mToolBar.center.x, self.view.bounds.size.height - mToolBar.bounds.size.height / 2);
                     }
                     completion:^(BOOL finished){
                         mToolBarInAnim = NO;
                         if (completion) {
                             completion(finished);
                         }
                     }];
    mToolBarHidden = NO;
    mToolBarInAnim = YES;
}

- (void)hideToolBarAnimated:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         mToolBar.center = CGPointMake(mToolBar.center.x, mToolBar.bounds.size.height / 2 + [SNToolBar normalHeight]);
                     }
                     completion:^(BOOL finished) {
                         mToolBarInAnim = NO;
                         if (completion) {
                             completion(finished);
                         }
                     }];
    mToolBarHidden = YES;
    mToolBarInAnim = YES;
}

- (void)toolBarChangedAnimated
{
    // 删除正在进行中的动画
    if (mToolBarInAnim) {
        [mToolBar.layer removeAllAnimations];
    }
    

    ThreadSummary *ts = [self currentThread];
    SNToolBarType oldType = [mToolBar toolBarType];
    SNToolBarType t = SNToolBarTypeNews;
    
    // 是否显示正能量按钮
    if (ts.is_energy) {
        t = SNToolBarTypeNews;
    }
    [mToolBar changeBarType:t thread:[self currentThread]];
    
    // 标记已读
    [[ThreadsManager sharedInstance] markThreadAsRead:ts];
    
    
    // 工具栏动画
    if (!mToolBarHidden) {
        // 状态栏没有隐藏
        if (oldType != t) {
            [self hideToolBarAnimated:^(BOOL finished) {
                if (t == SNToolBarTypeWeb) {
//                    SNThreadViewer *curViewer = [self currentViewer];
//                    [mToolBar setCanGoBack:[curViewer canGoBack]];
//                    [mToolBar setCanGoForward:[curViewer canGoForward]];
                }
                
                [mToolBar refreshToolsBar];
                [self showToolBarAnimated:nil];
            }];
        }
        else{
            [mToolBar refreshToolsBar];
        }
    }
    else {
        // 工具栏在隐藏状态
//        if (t == SNToolBarTypeWeb) {
//            SNThreadViewer *curViewer = [self currentViewer];
//            [mToolBar setCanGoBack:[curViewer canGoBack]];
//            [mToolBar setCanGoForward:[curViewer canGoForward]];
//        }
        
        [mToolBar refreshToolsBar];
        [self showToolBarAnimated:nil];
    }
}

/**
 将某个viewer放置在某个page处
 */
- (void)moveViewer:(SNThreadViewer*)v toPage:(int)p
{
    if(p < 0 || p > 2) return;
    CGRect frame = v.frame;
    frame.origin.x = p * frame.size.width;
    v.frame = frame;
}

/**
 获取当前页的SNWebViewer
 */
- (SNThreadViewer*)currentViewer
{
    return _threadView;
}

/**
 获取当前页关联的帖子
 */
- (ThreadSummary*)currentThread
{
    return [[self currentViewer] thread];
}


// 清除Viewers资源
-(void)cleanViewersResource
{
    // 释放内存
    SNThreadViewer *curViewer = [self currentViewer];
    // 需要延迟释放
    [DispatchUtil dispatch:^{
        [curViewer cleanResourceForDealloc];
    } after:0.4];
}

-(void)webFontSizeClick:(UIButton*)fontButton
{
    [mToolBar showFontsSettingView];
}

-(void)webUrlMoreButton:(UIButton*)btn
{
    // 显示二级菜单
    [self pushWebUrlMenu];
}

// 处理手势向左边滑动逻辑
- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGPoint p = [sender locationInView:self.view];
        if (p.x > width - 20.f && p.y > self.StateBarHeight) {
            ThreadSummary *ts = [self currentThread];
            if ([ts isComment]) {
                [self toolBarActionNewComment:[self currentThread]];
            }
        }
    }
}


-(void)setUrlNewsTitle:(NSString *)title
{
    if (title && ![title isEmptyOrBlank]) {
        [_newsTitle setHighlighted:NO];
        _newsTitle.text = title;
        NSString * threadTitle = [self currentThread].title;
        if (!threadTitle | [threadTitle isEmptyOrBlank]) {
            [self currentThread].title = title;
        }
    }
    else {
        [_newsTitle setHighlighted:YES];
    }
}

#pragma mark -
#pragma mark ----SNThreadViewerDelegate----

/**
 开始向上滑动
 */
-(void)snThreadViewerBeginScrollUp:(SNThreadViewer*)w
{
    //显示工具栏
    [self showToolBarAnimated:nil];
}

/**
 开始向下滑动
 */
-(void)snThreadViewerBeginScrollDown:(SNThreadViewer*)w
{
    return;//暂时取消隐藏功能以显示能量工具栏
    //隐藏工具栏
//    [self hideToolBarAnimated:nil];
}

/**
 向下滑动到达底部
 */
-(void)snThreadViewerScrollReachBottom:(SNThreadViewer*)w
{
    //显示工具栏
//    [self showToolBarAnimated:nil];
//
}

/**
 加载状态改变后的回调
 */
-(void)snThreadViewerStateChanged:(SNThreadViewer*)v
{
}

/**
 新闻图片下载成功
 仅针对于正文模式
 */
-(void)snThreadViewer:(SNThreadViewer*)v newsImageDownloaded:(ThreadContentImageInfoV2*)info
{
    // 通知图片浏览模式图片准备好了
    if (mPictureBox && info) {
        [mPictureBox notifyImageInfoChenged:info];
    }
}

/**
 *  观察者处理特殊事件
 *
 *  @param v    帖子view
 *  @param evt  事件
 *  @param info 数据信息
 */
-(void)snThreadViewer:(SNThreadViewer*)v eventOccurred:(SNThreadViewerEvent)evt withInfo:(id)info
{
    if (evt == SNThreadViewerEventViewSource) {
        // 查看原网页
        ThreadSummary *ts = [ThreadSummary new];
        ts.webView = 1;
        ts.newsUrl = info;
        SNThreadViewerController *vc = [[SNThreadViewerController alloc] initWithThread:ts];
        [self presentController:vc animated:PresentAnimatedStateFromRight];
    }
    else if(evt == SNThreadViewerEventImageClicked){
        // 图片浏览
        NSInteger imgIdx = 0;
        NSMutableArray *imageArr = [NSMutableArray array];
        ThreadContentResolvingResultV2 *resultV2 = [v threadResolvingResult];
        ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
        for (int i = 0 ; i< [resultV2.contentImgInfoArray count]; i++) {
            ThreadContentImageInfoV2 *imgInfo1 = [resultV2.contentImgInfoArray objectAtIndex:i];
            if(picMode == ReaderPicOn ||
               (picMode == ReaderPicManually && imgInfo1.isLocalImageReady)) {
                [imageArr addObject:imgInfo1];
            }
        }

        // 图片下标判断
        if ([info isKindOfClass:[NSString class]]) {
            imgIdx = [(NSString*)info integerValue];
            if (imgIdx < 0 || imgIdx == NSNotFound) {
                imgIdx = 0;
            }
        }
        if ([imageArr count] > 0) {
            [self openPictureBox:[self currentThread].title
                          images:imageArr imageIdx:imgIdx];
        }
    }
    else if(evt == SNThreadViewerEventRelativeLinkClicked) {
        // 相关推荐
        if([info isKindOfClass:[SNRecommendationInfo class]])
        {
            SNRecommendationInfo *recommendation = info;
            u_long channelId = [recommendation.channelId doubleValue];
            u_long newsId = [recommendation.newsId doubleValue];        
            
            // 在本地缓存中查找
            ThreadsManager *tm = [ThreadsManager sharedInstance];
            ThreadSummary *ts = [tm getThreadSummaryForCoid:channelId threadId:newsId];
            
            // 本地没有找到
            if (ts == nil) {
                ts = [ThreadSummary new];
                ts.threadId = newsId;
                ts.channelId = channelId;
                ts.title = recommendation.newsTitle;
                ts.time = recommendation.updateTime.doubleValue;
                ts.threadM=HotChannelThread;
                ts.channelType = [recommendation.newsType integerValue ];
                ts.newsUrl = recommendation.content_url;
                ts.source = recommendation.source;
                [ts ensureFileDirExist]; // 避免没有文件夹，会导致正文内容无法保存
            }
            
            SNThreadViewerController* vv = [[SNThreadViewerController alloc] initWithThread:ts];
            [self presentController:vv animated:PresentAnimatedStateFromRight];
        }
    }
    else if(evt == SNThreadViewerEventAdLinkClicked) {
        //广告链接点击事件
        if ([info isKindOfClass:[AdvertisementInfo class]]) {
            AdvertisementInfo* advInfo = (AdvertisementInfo*)info;
            
            ThreadSummary *tempTS = [ThreadSummary new];
            tempTS.webView = 1;
            tempTS.newsUrl = advInfo.newsUrl;
            SNThreadViewerController *controller =
            [[SNThreadViewerController alloc] initWithThread:tempTS];
            [self presentController:controller animated:PresentAnimatedStateFromRight];
        }
    }
    else if(evt == SNThreadViewerEventActivityShareClicked) {
        NSString *urlString = info;
        NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:urlString];
        
//        NSInteger newsId = [[dict valueForKey:@"id"] integerValue];
        NSString *title = [[dict valueForKey:@"title"] urlDecodedString];
        NSString *desc = [[dict valueForKey:@"content"] urlDecodedString];
        NSString *url = [[dict valueForKey:@"link"] urlDecodedString];
       
        PhoneshareWeiboInfo *weiboInfo =
        [[PhoneshareWeiboInfo alloc] initWithWeiboSource:kWeiboData_Content];
        [weiboInfo setWeiboTitle:title desc:desc url:url];
        weiboInfo.showWeiboType = (kWeixin|kWeiXinFriendZone|kSinaWeibo|kSMS);
        [self showShareView:kWeiboView_Center shareInfo:weiboInfo];
    }
    else if(evt == SNThreadViewerEventShareSelectText){
        // 正文选择文字的分享
        if ([info isKindOfClass:[NSString class]]) {
            PhoneshareWeiboInfo *weiboInfo =
            [[PhoneshareWeiboInfo alloc] initWithWeiboSource:kWeiboData_Content];
            ThreadSummary *ts = [self currentThread];
            [weiboInfo setWeiboTitle:ts.title desc:info url:ts.newsUrl];
            weiboInfo.showWeiboType = kAllWeiboType;
            [self showShareView:kWeiboView_Center shareInfo:weiboInfo];
        }
    }
    else if(evt == SNThreadViewerEventShareNews){
        if ([info isKindOfClass:[ThreadSummary class]]) {
            
            PhoneshareWeiboInfo *weiboInfo =
            [[PhoneshareWeiboInfo alloc] initWithWeiboSource:kWeiboData_Content];
            [weiboInfo setThread:info isShareEnergy:NO];
            weiboInfo.showWeiboType = kAllWeiboType;
            [self showShareView:kWeiboView_Center shareInfo:weiboInfo];
        }
    }
    else if(evt == SNThreadViewerEventRssSubscribe){
        // RSS订阅 处理订阅事件
        if ([info isKindOfClass:[HotChannelRec class]]) {
            HotChannelRec *rec = info;
            // 从订阅源中查找，找不到在创建一个新的
            SubsChannel* subsChannel = [[SubsChannelsManager sharedInstance] getChannelById:rec.recid];
            if (subsChannel == nil) {
                subsChannel = [rec buildSubsChannel];
            }
            
            //添加订阅
            [[SubsChannelsManager sharedInstance] addSubscription:subsChannel];
            [self PhoneNotification];
        }
       
        
//        if ([[SubsChannelsManager sharedInstance] isChannelSubscribed:subsId]) {
//            // 暂时确认是把取消订阅选项去掉 改成进入详情列表
//            SubsChannelSummaryViewController *summaryController = [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummarySubs];
//            [summaryController setSubsFromStyle:subsChannelContent];
//            [summaryController setSubsChannel:subsChannel];
//            [self presentController:summaryController animated:PresentAnimatedStateFromRight];
//        }
//        else
//        {
//            SNThreadViewer *curViewer = [self currentViewer];
//            [curViewer rssSubscribeState:YES];
//            
//            //添加订阅
//            [[SubsChannelsManager sharedInstance] addSubscription:subsChannel];
//            [self PhoneNotification];
//        }
    }
    else if(evt == SNThreadViewerEventRssClicked){
         //RSS 点击事件
        SubsChannelSummaryViewController *summaryController = [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummarySubs];
        [summaryController setSubsFromStyle:subsChannelContent];

        NSDictionary *paramsDict = [NSDictionary dictionaryWithFormEncodedString:info];
        long subsId = [[paramsDict objectForKey:@"recid"] doubleValue];
        NSString *name = [[paramsDict objectForKey:@"recname"] urlDecodedString];
        NSString *imgUrl = [[paramsDict objectForKey:@"imgUrl"] urlDecodedString];
        
        // 从订阅源中查找，找不到在创建一个新的
        SubsChannel* subsChannel = [[SubsChannelsManager sharedInstance] getChannelById:subsId];
        if (subsChannel == nil) {
            subsChannel = [[SubsChannel alloc] init];
            [subsChannel setChannelId:subsId];
            [subsChannel setName:name];
            [subsChannel setImageUrl:imgUrl];
        }
        
        [summaryController setSubsChannel:subsChannel];
        [self presentController:summaryController animated:PresentAnimatedStateFromRight];
    }
    else if(evt == SNThreadViewerEventDissertationClicked) {
//        url格式为：surfnews://+地址+surfcid=？？？+surfnid=？？？+issurf=？？？+surftype =？？？。
//        surfcid为channelId;
//        surfnid为newsId;
//        issurf为isHot;
//        surftype : 0是url打开，1是正文方式打开。
        
//    surfnews://ent.qq.com/a/20150310/061092.htm&surfcid=4061&surfnid=498065&issurf=0&surftype=1
        
        
        NSString *url = nil;
        NSString *parameter = nil;
        
        
        // url替换前缀
        url = [info stringByReplacingOccurrencesOfString:Dissertation_PREFIX withString:@"http://"];
        
        
        // 删除参数
        NSRange idx = [url rangeOfString:@"?"];
        if (idx.location == NSNotFound || idx.length == 0) {
            idx = [url rangeOfString:@"&"];
        }
        
        if (idx.location != NSNotFound && idx.length > 0 ) {
            parameter = [url substringFromIndex:idx.location+idx.length];
            url = [url substringToIndex:idx.location];
        }
        
        // 避免无效的URL
        if (!url || [url isEmptyOrBlank] ||
            !parameter || [parameter isEmptyOrBlank]) {
            return;
        }
        
        
        NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:parameter];
        long channelId = [[dict objectForKey:@"surfcid"] doubleValue];
        long newsId = [[dict objectForKey:@"surfnid"] doubleValue];
//        NSInteger isHot = [[dict objectForKey:@"issurf"] integerValue];
        NSInteger surftype = [[dict objectForKey:@"surftype"] integerValue];
        
        if (channelId == 0 || newsId == 0) {
            return;
        }
        
        
        // 查找新闻是否存在
        ThreadsManager *tm = [ThreadsManager sharedInstance];
        ThreadSummary *ts = [tm getThreadSummaryForCoid:channelId
                                               threadId:newsId];
        
        // 创建一个新的新闻帖子信息
        if (!ts) {
            ts = [ThreadSummary new];
            ts.threadId = newsId;
            ts.channelId = channelId;
            ts.threadM = HotChannelThread;
            ts.newsUrl = url;
            ts.channelType = 0;
            
            // surftype : 0是url打开，1是正文方式打开。
            ts.webView = (surftype==1)?0:1;
            [ts ensureFileDirExist]; // 避免没有文件夹，会导致正文内容无法保存
        }
        
        SNThreadViewerController* vv = [[SNThreadViewerController alloc] initWithThread:ts];
        [self presentController:vv animated:PresentAnimatedStateFromRight];
    }
    else if(evt == SNThreadViewerEventEnterRssChannel) {
        // 进入Rss频道
        if (![info isKindOfClass:[SNNewsExtensionInfo class]]) return;
        
         //  先找到频道信息
        SNNewsExtensionInfo *newsInfo = info;
        u_long channelId = [newsInfo.rssId doubleValue];
        SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
        SubsChannel *subsChennel = nil;
        for (SubsChannel *sc in [scm visibleSubsChannels]) {
            if (sc.channelId == channelId) {
                subsChennel = sc;
                break;
            }
        }
        
        if (!subsChennel) {
            subsChennel = [SubsChannel new];
            subsChennel.channelId = channelId;
            subsChennel.name = newsInfo.rssName;
            subsChennel.ImageUrl = newsInfo.rssIcon;
        }
        

        SubsChannelSummaryViewController *summaryController =
        [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummarySubs];
        [summaryController setSubsFromStyle:subsChannelCommon];
        summaryController.title = subsChennel.name;
        summaryController.subsChannel = subsChennel;
        [self presentController:summaryController animated:PresentAnimatedStateFromRight];
        
    } else if (evt == SNThreadViewerEventBodyImageClicked) {
        // 新闻图片url、数组
        NSDictionary *urlDic = (NSDictionary *)info;
        NSString *urlString = urlDic.allKeys[0];
        NSArray *urlArray = urlDic.allValues[0];
        // 点击的图片索引
        NSUInteger curPage = [urlArray indexOfObject:urlString];
        // 图片浏览器
        SNThreadImageBrowserController *imageBrowerController = [[SNThreadImageBrowserController alloc] initWithImgUrlArr:urlArray CurPage:curPage];
        imageBrowerController.photoFrame = CGRectMake(0, kScreenHeight / 3, kScreenWidth, kScreenHeight / 3);
        // 弹出
        [self presentController:imageBrowerController animated:PresentAnimatedStateFromRight];
    }

}

- (void)PhoneNotification
{
    [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
        if (succeeded) {
            [PhoneNotification autoHideWithText:@"操作成功"];
        } else {
            [PhoneNotification hideNotification];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交订阅失败，是否重试？"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"重试",nil];
            [alertView show];
        }
    }];
}

// 检查goBack和goForward状态
-(void)snThreadViewerCheckGoBackOrGoForward:(SNThreadViewer*)v
{
//    SNThreadViewer *curViewer = [self currentViewer];
//    if (curViewer == v) {
//        [mToolBar setCanGoBack:[curViewer canGoBack]];
//        [mToolBar setCanGoForward:[curViewer canGoForward]];
//    }
}
-(void)snShowEnergyView
{
    [self pushEnergyView:[self currentThread]];
}

-(void)snSetUrlNewsTitle:(NSString *)title
{
    [self setUrlNewsTitle:title];
}

// 隐藏字体设置
-(void)snHiddenFontSizeView:(BOOL)isHidden
{
    [_fontSizeButton setHidden:isHidden];
}

// 界面中间弹出的分享框，分享的type
-(void)snThreadViewerShareType:(ShareWeiboType)type
{
    [mToolBar setShareType:type withInfo:nil];
}

// 工具栏类型发生改变
-(void)snToolsBarTypeChanged:(SNToolBarType)toolBarType
                   isCollect:(BOOL)isC
{
    // TODO: 改变工具栏类型
    mToolBar.isCollect = isC;
    [mToolBar changeBarType:toolBarType thread:[self currentThread]];
    [mToolBar refreshToolsBar];
}
-(void)snToolsBarVisible:(BOOL)isShow
{
    [mToolBar setHidden:!isShow];
}

#pragma mark-- SNToolBarDelegate
-(void)toolBarActionFontSizeChanged:(float)size
{
    [[self currentViewer] setWebViewFontSize:size];
}


-(void)toolBarActionRefresh
{
    [[self currentViewer] refresh];
}

-(void)toolBarActionEnergy:(ThreadSummary *)ts
{
    [self pushEnergyView:ts];
}
-(NSString*)toolBarActionGetWeiboContent
{
    SNThreadViewer *curViewer = [self currentViewer];
    return [curViewer userSelectContent];
}
// 工具栏新闻评论
- (void)toolBarActionNewComment:(ThreadSummary *)ts
{
    if (!ts) return;
    
    SNNewsCommentViewController *newsComment =
    [SNNewsCommentViewController new];
    newsComment.thread = ts;
    [self presentController:newsComment
                   animated:PresentAnimatedStateFromRight];
}
//进去登陆界面
-(void)toolBarGotoLogin
{
    PhoneLoginController *loginController = [[PhoneLoginController alloc] init];
    [self presentController:loginController animated:PresentAnimatedStateFromRight];
    
}

// 点击分享
- (void)toolBarActionShare:(ThreadSummary *)ts
{
    theApp.jokeThread = ts; // 传模型(段子cell分享和正文界面分享都经过这里)
    PhoneshareWeiboInfo *info = [[PhoneshareWeiboInfo alloc]initWithWeiboSource:kWeiboData_userCenter];
    [info setThread:ts isShareEnergy:NO];
    info.showWeiboType = kAllWeiboType;
    [self showShareView:kWeiboView_Bottom shareInfo:info];
    
}
// 举报
- (void)toolBarActionReport:(ThreadSummary *)ts
{
    SNReportViewController *reportVC =
    [SNReportViewController new];
    reportVC.ts = ts;
    [self presentController:reportVC
                   animated:PresentAnimatedStateFromRight];
}

-(NSMutableArray*)getContentImgArr{
    SNThreadViewer *curViewer = [self currentViewer];
    NSMutableArray *imageArr = [NSMutableArray array];
    ThreadContentResolvingResultV2 *resultV2 = [curViewer threadResolvingResult];

    for (int i = 0 ; i< [resultV2.contentImgInfoArray count]; i++) {
        ThreadContentImageInfoV2 *imgInfo1 = [resultV2.contentImgInfoArray objectAtIndex:i];
        if(imgInfo1.isLocalImageReady) {
            [imageArr addObject:imgInfo1.expectedLocalPath];
        }
    }
    return imageArr;
}

// 顶部工具栏返回
-(void)dismissBackController
{
    if ([_threadView canGoBack]) {
        [_threadView goBack];
    }else{
        [super dismissBackController];
        [self cleanViewersResource]; // 释放内存
    }
}

// 底部工具栏返回
-(void)toolBarActionExit
{
    [self dismissBackController];
}

// 手势返回的处理函数(继承函数)
- (void)didBackGestureEndHandle
{
    [super didBackGestureEndHandle];
    [self cleanViewersResource]; // 释放内存
}
#pragma mark - NightModeChangedDelegate
-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    backGView.backgroundColor = [UIColor whiteColor];
    
    [[self currentViewer] viewNightModeChanged:night];
    [mToolBar viewNightModeChanged:night];
    
    if (night) {
        [[UIApplication sharedApplication] setStatusBarStyle:YES];
        self.view.backgroundColor = [UIColor colorWithHexString:NightBackgroundColor];
    }
    else{
        self.view.backgroundColor = [UIColor colorWithHexString:DayBackgroundColor];
    }
    
    if (IOS7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

#pragma mark-- PictureBoxDelegate
-(void)pictureBoxShowFinish
{
    [self hiddenPictureBox];
}

-(void)hiddenPictureBox
{
    // 做一个渐隐的动画
    [UIView animateWithDuration:0.4f animations:^{
        mPictureBox.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [mPictureBox removeFromSuperview];
        mPictureBox = nil;
    }];
}


-(void)openPictureBox:(NSString *)title
               images:(NSArray*)imgs
             imageIdx:(NSInteger)ImgIdx
{
    
    // 这个是用到创建，不用删除的一个View
    if (!mPictureBox) {
        CGRect pR = [self view].bounds;
        PictureBox *pb = [[PictureBox alloc] initWithFrame:pR];
//        pb.delegate = self;
        pb.hidden = NO;
        pb.alpha = 0.0f;
        pb.backgroundColor = [UIColor blackColor];
        [self.view addSubview:pb];
        mPictureBox = pb;
        
        // 加载数据（针对正文使用）
        [pb setShareUrl:[[self currentThread] newsUrl]];
        [pb reloadDataWithImageInfoV2Array:title
                                imageArray:imgs
                                imageIndex:ImgIdx
                         isHightDefinition:YES];
        
        
        // 做一个渐显的动画
        [UIView animateWithDuration:0.4f animations:^{
            mPictureBox.alpha = 1.0f;
        }];
    }
}

#pragma mark 正负能量
// 弹出正负能量View energy
-(void)pushEnergyView:(ThreadSummary*)ts
{
    if (!ts || ![ts is_energy]) {
        return;
    }
    
    if (!_energyView) {
        _energyView = [[SNPNEView alloc] initWithFrame:self.view.bounds];
        [_energyView setDelegate:self];
        [_energyView loadingWithThread:ts];
        [self.view addSubview:_energyView];
    }
}

-(void)popEnergyView
{
    if(_energyView) {
        [_energyView clearResource];
        [_energyView removeFromSuperview];
    }
    _energyView = nil;
}
#pragma mark SurfEnergyDelegate
-(void)shareEnergy:(long)energyScore
{
    // 刷新当前webView能量值
    [[self currentViewer] refreshEnergy:energyScore];
    [self popEnergyView];

    
    PhoneshareWeiboInfo *info = [[PhoneshareWeiboInfo alloc]initWithWeiboSource:kWeiboData_Energy];
    [info setThread:[self currentThread] isShareEnergy:YES];
    info.showWeiboType = (kWeixin|kWeiXinFriendZone|kSinaWeibo|kQQFriend|kQZone);
    [self showShareView:kWeiboView_Center shareInfo:info];

    
    //TODO 显示分享界面
//    [self showShareView];
//    energyValue = energyScore;
}

-(void)closeEnergyView:(long)energyScore
{
    [[self currentViewer] refreshEnergy:energyScore];
    [self popEnergyView];
}

- (void)showShareView
{
    if (!_energyShareView) {
        CGRect r = self.view.bounds;
        _energyShareView = [[UIView alloc] initWithFrame:r];
        [self.view addSubview:_energyShareView];
        
        
        UIControl *bgView = [[UIControl alloc]initWithFrame:r];
        [bgView setBackgroundColor:[UIColor blackColor]];
        bgView.alpha = 0.6f;
        [bgView addTarget:self action:@selector(hiddenEnergyShareView) forControlEvents:UIControlEventTouchUpInside];
        [_energyShareView addSubview:bgView];
        
        
        
        float shareW = 200.f;
        float shareH = 180.f;
        float w = CGRectGetWidth(self.view.bounds);
        float h = CGRectGetHeight(self.view.bounds);
        float shareX = (w-shareW)/2;
        float shareY = (h-shareH)/2;
        CGRect shareR = CGRectMake(shareX, shareY, shareW, shareH);
        ShareView_Ranking *rankShare = [[ShareView_Ranking alloc] initWithFrame:shareR];
        rankShare.delegate = self;
        [rankShare setBackgroundColor:[UIColor whiteColor]];
        [_energyShareView addSubview:rankShare];
    }
}
-(void)hiddenEnergyShareView
{
    [_energyShareView removeFromSuperview];
    _energyShareView = nil;
}
#pragma mark RankingShareCtlDelegate
- (void)shareMenuSelected:(ShareWeiboType)type
{
    [self hiddenEnergyShareView];
    [mToolBar setShareType:type energy:energyValue];
}


#pragma mark- webUrl 菜单选项
// 显示二级菜单
-(void)pushWebUrlMenu
{
    UIControl *pView =
    [[UIControl alloc] initWithFrame:self.view.bounds];
    [pView addTarget:self
              action:@selector(hiddenWebUrlMenu:)
    forControlEvents:UIControlEventTouchUpInside];
    [pView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat width= CGRectGetWidth(pView.bounds);
    NSArray* btnStrList = kUrlMenuItmes;
    CGFloat btnWidth = 100.f;
    CGFloat btnHeight = 30.f;
    CGFloat cX = width - 10 - btnWidth;
    CGFloat cY = self.StateBarHeight;
    UIColor *bgColor = [UIColor whiteColor];
    CGRect cR = CGRectMake(cX, cY, btnWidth, btnHeight*btnStrList.count);
    UIView *containerV = [[UIView alloc] initWithFrame:cR];
    containerV.layer.cornerRadius = 5.f;
    containerV.backgroundColor = bgColor;
    [containerV viewShadow:YES];
    
    // 添加一个箭头
    CGFloat arwW = 15.f, arwH = 10.f;
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.frame = CGRectMake(btnWidth-35, -arwH+1, arwW, arwH);
    CGMutablePathRef arrowPath =  CGPathCreateMutable();
    [arrowLayer setFillColor:[bgColor CGColor]];
    arrowLayer.lineWidth = .0f ;
    CGPathMoveToPoint(arrowPath, NULL, arwW/2, 0);
    CGPathAddLineToPoint(arrowPath, NULL, 0,arwH);
    CGPathAddLineToPoint(arrowPath, NULL, arwW, arwH);
    CGPathCloseSubpath(arrowPath);
    [arrowLayer setPath:arrowPath];
    CGPathRelease(arrowPath);
    [containerV.layer addSublayer:arrowLayer];
    
    // 子控件
    UIFont *btnFont = [UIFont systemFontOfSize:13];
    for (NSInteger i=0; i<[btnStrList count]; ++i) {
        
        CGRect btnR = CGRectMake(0, i*btnHeight, btnWidth, btnHeight);
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:btnStrList[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn titleLabel].font = btnFont;
        [btn setFrame:btnR];
        [btn addTarget:self action:@selector(webUrlMenuItemSelect:) forControlEvents:UIControlEventTouchUpInside];
        [containerV addSubview:btn];
        
        // 分割线
        if(i < [btnStrList count]-1) {
            CALayer *lineLayer = [CALayer layer];
            CGFloat lineY = btnR.origin.y + btnHeight;
            lineLayer.frame = CGRectMake(0, lineY, btnWidth, 0.5);
            lineLayer.backgroundColor = [UIColor grayColor].CGColor;
            [containerV.layer addSublayer:lineLayer];
        }
        
    }
    
    
    [pView addSubview:containerV];
    [self.view addSubview:pView];
}
-(void)hiddenWebUrlMenu:(id)ctrl
{
    if ([ctrl isKindOfClass:[UIView class]]) {
        [ctrl removeFromSuperview];
        ctrl = nil;
    }
}

-(void)webUrlMenuItemSelect:(UIButton*)btn
{
//    "分享给朋友", @"其它方式打开",@"刷新页面"];
    NSString *itemStr = [btn titleLabel].text;
    if ([itemStr isEqualToString:@"分享给朋友"]) {
        PhoneshareWeiboInfo *weiboInfo =
        [[PhoneshareWeiboInfo alloc] initWithWeiboSource:kWeiboData_Content];
        [weiboInfo setThread:[self currentThread] isShareEnergy:NO];
        weiboInfo.showWeiboType = kAllWeiboType;
        [self showShareView:kWeiboView_Center shareInfo:weiboInfo];
    }
    else if([itemStr isEqualToString:@"其它方式打开"]) {
        NSURL *url = [NSURL URLWithString:[self currentThread].newsUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if ([itemStr isEqualToString:@"刷新页面"]) {
        [[self currentViewer] refresh];
    }
    
    id superV = btn.superview.superview;
    if ([superV isKindOfClass:[UIControl class]]) {
        [self hiddenWebUrlMenu:superV];
    }
}

@end
