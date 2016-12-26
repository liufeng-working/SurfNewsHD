//
//  SNThreadViewer.m
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-3.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SNThreadViewer.h"
#import "DispatchUtil.h"
#import "RSWeakifySelf.h"
#import "NSString+Extensions.h"
#import "NSDictionary+QueryString.h"
#import "ThreadsManager.h"
#import "ThreadContentDownloader.h"
#import "ImageDownloader.h"
#import "ThreadContentResolver.h"
#import "SurfHtmlGenerator.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "AppSettings.h"
#import "UIView+NightMode.h"
#import "RssSourceData.h"
#import "SNNewsContentInfoResponse.h"
#import "MJExtension.h"
#import "FavsManager.h"
#import "SubsChannelsManager.h"
#import "SNEnergyTableCell.h"
#import "AdvertisementManager.h"
#import "NewsCommentCell.h"
#import "SNSubscribeRssCell.h"
#import "SNThreadSubscribeChannelCell.h"
#import "UIImage+animatedGIF.h"
#import "SNVoteTableCell.h"
#import "EzJsonParser.h"

#define kWebViewBgColor @"#2D2E2F"
#define kWebViewBgColor_night @"#F8F8F8"
#define kTableHeaderCellIdentifier @"header_cell"


/**
 网页滚动状态
 */
typedef enum {
    
    SNScrollViewStateIdle,                      //处于静止状态
    SNScrollViewStateScrollingUp,               //处于向上滚动状态（Dragging Down）
    SNScrollViewStateScrollingDown,             //处于向下滚动状态（Dragging Up）
    SNScrollViewStateBouncingTop,               //顶部处于弹簧拉伸状态
    SNScrollViewStateBouncingBottom,            //底部处于弹簧拉伸状态
    SNScrollViewStateBouncingTopRecover,        //顶部处于弹簧收缩状态
    SNScrollViewStateBouncingBottomRecover      //底部处于弹簧收缩状态
    
} SNScrollViewState;


typedef NS_ENUM(NSInteger, WebTableCellType)
{
    kWebTableType_webView = 10,         // webView
    kWebTableType_recommend_Header,     // 推荐头(固定格式)
    kWebTableType_recommend_News,       // 推荐新闻
    kWebTableType_advert_Text,          // 文字广告
    kWebTableType_advert_Image,         // 图片广告
    kWebTableType_Energy_Header,
    kWebTableType_Energy,               // 正负能量
    kWebTableType_hotComment_Header,    // 热门评论
    kWebTableType_hotComment_Content,   // 热门评论内容
    kWebTableType_hotComment_EnterButton,// 进入评论按钮
//    kWebTableType_Subscribe_Header,     // 相关阅读头
//    kWebTableType_Subscribe,            // 相关阅读
    kWebTableType_Vote_Header,          // 投票头
    kWebTableType_Vote,                 // 投票
    kWebTableType_EnterSubscribeChannel,// 进入订阅频道
    kWebTableType_End                   // 原网页
};


typedef void (^SNThreadViewerRecycleHandler)();



#pragma mark-/////////////// cell 数据类型 ///////////
@interface NewsCellData : NSObject

@property(nonatomic)WebTableCellType cellType;
@property(nonatomic,strong)id userData;

@end

@implementation NewsCellData
@end





@interface SNThreadViewer() <UITableViewDataSource, UITableViewDelegate>
{
    SNThreadViewerRecycleHandler     mRecycleHandler;
    SNViewerState              mState;
    ThreadSummary*       mThread;
    UIWebView*           mWebView;
    __weak UIImageView *mLoadingAction; //无敌风火轮
    
    BOOL                        mInUserInteraction;     //是否正处于用户拖动交互中
    CGPoint                     mLastScrollViewOffset;  //记录最近一次scrollview的偏移
    SNScrollViewState           mScrollViewState;       //scrollview的当前状态
    
    BOOL                        mWebViewRespondsToScrollWillBeginDragging;
    BOOL                        mWebViewRespondsToScrollDidEndDragging;
    BOOL                        mWebViewRespondsToScrollDidEndDecelerating;
    BOOL                        mWebViewRespondsToScrollDidScroll;
    
    
    
    // 5.0.0 and later
    SNNewsExtensionInfo *mNewsExtension;
    __weak UITableView *mWebTableView;
    NSMutableArray *mTableSourec;
    
    __weak UIButton *_loadingErrorButton;
    __weak UIImageView *_loadinErrorImageV;
    __weak SNEnergyTableCell* _energyCell;
    BOOL _isCollect;
    
    // 正文图片数组
    NSArray *_imageArray;
    
    // 赞、踩 按钮
    UIButton *_upButton;
    UIButton *_downButton;
    
    // 赞、踩 imageView
    UIImageView *_upImageView;
    UIImageView *_downImageView;
    
    // 赞、踩数量 label
    UILabel *_upLabel;
    UILabel *_downLabel;
}
@end

@implementation SNThreadViewer



-(void)dealloc
{
    [self removeObserverForWebViewContentSize];
}
- (id)init
{
    self = [super init];
    if (self) {
        self.autoresizesSubviews = YES;

        mState = SNViewerStateIdle;
        mScrollViewState = SNScrollViewStateIdle;
        self.backgroundColor = [UIColor clearColor];
       
        mTableSourec = [NSMutableArray array];
        UITableView *webTable = [self createWebTableView];
        mWebTableView = webTable;
        [self addSubview:webTable];
        
        
        // 初始化加载动画
        CGFloat imgW = 76;
        CGFloat imgH = 96;
        CGFloat imgX = (kContentWidth - imgW)/2;
        CGFloat imgY = kContentHeight/2 - imgH;
        UIImageView *loading =
        [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, imgW, imgH)];
        mLoadingAction = loading;
//        [loading setGifWithImageName:@"webview-loading-day.gif"];
        
        //设置加载动画
        NSMutableArray * loadingArray=[[NSMutableArray alloc]initWithCapacity:0];
        for (NSInteger i=1; i<11; i++)
        {
            NSString * nameStr=[NSString stringWithFormat:@"news_loading_%@",@(i)];
            UIImage * loadingimage=[UIImage imageNamed:nameStr];
            [loadingArray addObject:loadingimage];
        }
        loading.animationImages=loadingArray;
        loading.animationDuration=0.7;
        loading.animationRepeatCount=0;
        [loading setHidden:YES];
        loading.backgroundColor = [UIColor colorWithHexValue:0x7fffffff];
        loading.layer.cornerRadius = 5.f;
        loading.layer.masksToBounds = YES;
        [self addSubview:loading];
      

        
        [self registerShareMenuItem];
        
        /** 点赞动画 */
        NSArray *upImageNames = @[
                                  @"content_up1",
                                  @"content_up2",
                                  @"content_up3",
                                  @"content_up4",
                                  @"content_up5",
                                  ];
        _upImages = [NSMutableArray array];
        for (NSString *imageName in upImageNames) {
            UIImage *upImage = [UIImage imageNamed:imageName];
            [_upImages addObject:upImage];
        }
        
        /** 点踩 */
        NSArray *downImageNames = @[
                                    @"content_down1",
                                    @"content_down2",
                                    @"content_down3",
                                    @"content_down4",
                                    @"content_down5"
                                    ];
        _downImages = [NSMutableArray array];
        for (NSString *imageName in downImageNames) {
            UIImage *downImage = [UIImage imageNamed:imageName];
            [_downImages addObject:downImage];
        }
    }
    return self;
}

-(void)hideGradientBackgroundForWebView:(UIView*)theView
{
    for (UIView * subview in theView.subviews){
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        [self hideGradientBackgroundForWebView:subview];
    }
}


-(void)showActivityIndicator
{
    if (![mLoadingAction isAnimating]) {
        [mLoadingAction setHidden:NO];
        [mLoadingAction startAnimating];
    }
}

-(void)hideActivityIndicator
{
    [mLoadingAction stopAnimating];
    [mLoadingAction setHidden:YES];
}

//清空前进后退历史列表
-(void)clearBackForwardList
{
    StartSuppressPerformSelectorLeakWarning
    
    SEL sel = NSSelectorFromString([@"_do" stringByAppendingString:@"cumentView"]);
    if([mWebView respondsToSelector:sel]) {
        id docView = [mWebView performSelector:sel];
        id internal = [docView performSelector:NSSelectorFromString(@"webView")];
        if(internal) {
            BOOL yes = YES;
            BOOL no = NO;
            SEL selector = NSSelectorFromString([@"setMaintains" stringByAppendingString:@"BackForwardList:"]);
            NSMethodSignature* sig = [internal methodSignatureForSelector:selector];
            if(sig) {
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
                [invocation setTarget:internal];
                [invocation setSelector:selector];
                [invocation setArgument:&no atIndex:2];
                [invocation invoke];
                
                [invocation setArgument:&yes atIndex:2];
                [invocation invoke];
            }
        }
    }

    EndSuppressPerformSelectorLeakWarning
}

//回收SNContent控件
-(void)recycle:(SNThreadViewerRecycleHandler)handler
{   
    if(mState == SNViewerStateIdle) {
        if(handler)
            handler();
        
    } else if(mState == SNViewerStateLoading ||
              mState == SNViewerStateLoaded) {
        
        
        //解锁帖子资源锁定
        [[ThreadsManager sharedInstance] unlockThreadResource:mThread];
        
        //终止webview的载入
        [mWebView stopLoading];
        
        //加载空白html
        NSString *jswithBG = [NSString stringWithFormat:@"<html><body bgcolor='%@' /></html>",DayBackgroundColor];
        [mWebView loadHTMLString:jswithBG baseURL:nil];
    
        
        [self clearBackForwardList];
        [self stopWebViewLoading];
        mWebView.hidden = YES;
        mRecycleHandler = handler;
        mState = SNViewerStateRecycling;
        [self.delegate snThreadViewerStateChanged:self];
           
    } else if(mState == SNViewerStateRecycling) {
        NSLog(@"recycle received when Recycling");
        
        mRecycleHandler = handler;
        
    }
    
    ////reset
    mThread = nil;
    mInUserInteraction = NO;
    mLastScrollViewOffset = CGPointZero;
    mScrollViewState = SNScrollViewStateIdle;
    _isAtBottom = NO;
}



#pragma mark ----private method----
-(UITableView *)createWebTableView
{
    UITableView *webTable =
    [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    webTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webTable.backgroundColor = [UIColor clearColor];
    [webTable setDataSource:self];
    [webTable setDelegate:self];
    webTable.bounces = NO;
    [webTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return webTable;
}
-(UIWebView*)createWebViwe
{
    if (mWebView) {
        return mWebView;
    }
    
    CGRect webR = [mWebTableView bounds];
    UIWebView* web = [[UIWebView alloc] initWithFrame:webR];
    mWebView = web;
    web.scalesPageToFit = YES;
    web.dataDetectorTypes = UIDataDetectorTypeNone;
    web.delegate = self;
    web.clipsToBounds = YES;
    web.userInteractionEnabled = YES;
    web.multipleTouchEnabled = YES;
    web.backgroundColor = [UIColor clearColor];
    web.scrollView.scrollEnabled = YES;
    web.scrollView.bounces = NO;
    web.scrollView.delegate = self;
    web.layer.cornerRadius = 0.f;
    
    // 添加contentSize观察KVO
    // 添加一个tableView观察者
    [self addObserverForWebViewContentSize];

    mWebViewRespondsToScrollWillBeginDragging = [web respondsToSelector:@selector(scrollViewWillBeginDragging:)];
    mWebViewRespondsToScrollDidEndDragging = [web respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)];
    mWebViewRespondsToScrollDidEndDecelerating= [web respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
    mWebViewRespondsToScrollDidScroll= [web respondsToSelector:@selector(scrollViewDidScroll:)];

//设置webview初始背景色
//    ThemeMgr* themeMgr = [ThemeMgr sharedInstance];
//    [mWebView stringByEvaluatingJavaScriptFromString:
//     [NSString stringWithFormat:@"document.body.style.backgroundColor='%@';",
//      [themeMgr isNightmode]?NightBackgroundColor:DayBackgroundColor]];

    //_setDrawInWebThread:
    BOOL yes = YES;
    SEL selector = NSSelectorFromString([@"_s" stringByAppendingFormat:@"%@raw%@eb%@ad:",@"etD",@"InW",@"Thre"]);
    NSMethodSignature* sig = [web methodSignatureForSelector:selector];
    if(sig) {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:web];
        [invocation setSelector:selector];
        [invocation setArgument:&yes atIndex:2];
        [invocation invoke];
    }


    if(!IOS7) {
        [self hideGradientBackgroundForWebView:web];
    }
    
    return web;
}

// 因需要动态计算WebView高度给Cell使用
-(void)cleckWebViewFrame:(BOOL)isFirst
{
    if([mThread isUrlOpen])
        return;
    
    
    if (mState != SNViewerStateLoaded) {
        return;
    }
    
    CGRect webFrame = mWebView.frame;
    if (isFirst) {
        webFrame.size.height = 100.f;
        [mWebView setFrame:webFrame];
    }
    
    
    // Asks the view to calculate and return the size that best fits its subviews.
    CGFloat oldWebH = CGRectGetHeight(mWebView.frame);
    CGSize fittingSize = [mWebView sizeThatFits:CGSizeZero];
    if (fittingSize.height != oldWebH) {
        if (mThread.isBeauty == 5) {
            fittingSize.height += 100.f;
        }
        webFrame.size = fittingSize;
        mWebView.frame = webFrame;
        
        [mWebTableView beginUpdates];
        [mWebTableView  endUpdates];
    }
    
}

// webView 大小发生改变
-(void)webViewFrameChanged
{
    // 检查webView 高度
    [self cleckWebViewFrame:YES];
    
    // 添加 赞、踩 按钮
    [self addUpDownButtons];
    
    // 相关推荐
    if ([[mNewsExtension recommendation_list] count] > 0) {
        NewsCellData *cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_recommend_Header;
        [mTableSourec addObject:cellData];
        
        for (id obj in [mNewsExtension recommendation_list]) {
            NewsCellData *cellData = [NewsCellData new];
            cellData.cellType = kWebTableType_recommend_News;
            cellData.userData = obj;
            [mTableSourec addObject:cellData];
        }
        
        // 进入RSS频道(暂时关闭，订阅新闻接口字段改版)
        if (mNewsExtension.rssId &&
            [mNewsExtension.rssName length] > 0) {
            NewsCellData *cellData = [NewsCellData new];
            cellData.cellType = kWebTableType_EnterSubscribeChannel;
            [mTableSourec addObject:cellData];
        }
    }
    
   
    
    
    // 正负能量
    if([[mNewsExtension is_energy] boolValue]) {
        NewsCellData *cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_Energy_Header;
        [mTableSourec addObject:cellData];
        
        
        cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_Energy;
        [mTableSourec addObject:cellData];
    }
    
    // 参与投票
    if([mNewsExtension isVote])
    {
        NewsCellData *cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_Vote_Header;
        [mTableSourec addObject:cellData];
        
        cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_Vote;
        cellData.userData = mNewsExtension;
        [mTableSourec addObject:cellData];
    }

    
    // 热门评论
    if ([[mNewsExtension hot_comment_list] count] > 0) {
        NewsCellData *cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_hotComment_Header;
        [mTableSourec addObject:cellData];
        
        // 添加评论内容
        for(id obj in [mNewsExtension hot_comment_list]) {
            NewsCellData *cellData = [NewsCellData new];
            cellData.cellType = kWebTableType_hotComment_Content;
            cellData.userData = obj;
            [mTableSourec addObject:cellData];
        }
        
        cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_hotComment_EnterButton;
        [mTableSourec addObject:cellData];
    }
    
    // 相关订阅rss源
//    HotChannelRec *rec = [[RssSourceManager sharedInstance] getRandomRssDataWithChannelId:mThread.channelId];
//    mThread.rssId = 0; // 恢复默认值
//    if (rec.recimg && rec.recname &&
//        mThread.channelType == 0 &&
//        mThread.ctype == 0)
//    {
//        mThread.rssId = rec.recid;
//        
//        NewsCellData *cellData = [NewsCellData new];
//        cellData.cellType = kWebTableType_Subscribe_Header;
//        [mTableSourec addObject:cellData];
//        
//        
//        // 相关阅读内容
//        NewsCellData *cellData2 = [NewsCellData new];
//        cellData2.cellType = kWebTableType_Subscribe;
//        cellData2.userData = rec;
//        [mTableSourec addObject:cellData2];
//    }

    // 广告数据
    NSArray *adList = [[AdvertisementManager sharedInstance] getAdvertisementOfCoid:mThread.channelId];
    for (NSInteger i=0; i<[adList count]; ++i) {
        AdvertisementInfo *adInfo = [adList objectAtIndex:i];
        if ([[adInfo type] isEqualToString:@"0"]) {
            NewsCellData *cellData = [NewsCellData new];
            cellData.cellType = kWebTableType_advert_Text;
            cellData.userData = adInfo;
            [mTableSourec addObject:cellData];
        }
        else if ([[adInfo type] isEqualToString:@"1"]) {
            // 图片新闻
            NewsCellData *cellData = [NewsCellData new];
            cellData.cellType = kWebTableType_advert_Image;
            cellData.userData = adInfo;
            [mTableSourec addObject:cellData];
        }
    }
    
    // 查看原网页
    NSString *sourceUrl = mNewsExtension.newsUrl;
    if (sourceUrl && ![sourceUrl isEmptyOrBlank] &&
        mThread.open_type == 0) {
        NewsCellData *cellData = [NewsCellData new];
        cellData.cellType = kWebTableType_End;
        [mTableSourec addObject:cellData];
    }
    
    
    [mWebTableView reloadData];
}

// webView上添加 赞、踩 按钮
- (void)addUpDownButtons {
    if (mThread.isBeauty == 5) {    // 是段子频道才添加 赞、踩 按钮
        // webView的高度增加，放置两个点赞、踩按钮
//        mWebView.height += 100;
        // webView 添加按钮
        // 点赞
        UIButton *upButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [upButton setBackgroundImage:[UIImage imageNamed:@"content_btn_bg"] forState:UIControlStateNormal];
        upButton.size = upButton.currentBackgroundImage.size;
        upButton.left = 52.f;
        upButton.bottom = mWebView.height - 64.5f;
        [upButton addTarget:self action:@selector(upButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _upButton = upButton;
        
        UIImageView *upImageView = [[UIImageView alloc] init];
        if (mThread.uped) {
            upImageView.image = [UIImage imageNamed:@"content_up_on"];
        } else {
            upImageView.image = [UIImage imageNamed:@"content_up_off"];
        }
        
        upImageView.size = CGSizeMake(upButton.width * 0.4, upButton.height);
        upImageView.left = upButton.left;
        upImageView.top = upButton.top;
        upImageView.contentMode = UIViewContentModeRight;
        _upImageView = upImageView;
        
        UILabel *upLabel = [[UILabel alloc] init];
        upLabel.size = CGSizeMake(upButton.width - upImageView.width, upButton.height);
        upLabel.left = upImageView.right;
        upLabel.top = upImageView.top;
        upLabel.font = [UIFont systemFontOfSize:13];
        upLabel.textAlignment = NSTextAlignmentLeft;
        upLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        upLabel.text = [NSString stringWithFormat:@" %ld", (long)mThread.upCount];
        _upLabel = upLabel;
        
        [mWebView addSubview:upButton];
        [mWebView addSubview:upImageView];
        [mWebView addSubview:upLabel];
        
        // 点踩
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downButton setBackgroundImage:[UIImage imageNamed:@"content_btn_bg"] forState:UIControlStateNormal];
        downButton.size = downButton.currentBackgroundImage.size;
        downButton.left = mWebView.width - 52.f - downButton.currentBackgroundImage.size.width;
        downButton.bottom = mWebView.height - 64.5f;
        [downButton addTarget:self action:@selector(downButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _downButton = downButton;
        
        UIImageView *downImageView = [[UIImageView alloc] init];
        if (mThread.downed) {
            downImageView.image = [UIImage imageNamed:@"content_down_on"];
        } else {
            downImageView.image = [UIImage imageNamed:@"content_down_off"];
        }
        
        downImageView.size = CGSizeMake(downButton.width * 0.4, downButton.height);
        downImageView.left = downButton.left;
        downImageView.top = downButton.top;
        downImageView.contentMode = UIViewContentModeRight;
        _downImageView = downImageView;
        
        UILabel *downLabel = [[UILabel alloc] init];
        downLabel.size = CGSizeMake(downButton.width - downImageView.width, downButton.height);
        downLabel.left = downImageView.right;
        downLabel.top = downImageView.top;
        downLabel.font = [UIFont systemFontOfSize:13];
        downLabel.textAlignment = NSTextAlignmentLeft;
        downLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        downLabel.text = [NSString stringWithFormat:@" %ld", (long)mThread.downCount];
        _downLabel = downLabel;
        
        [mWebView addSubview:downButton];
        [mWebView addSubview:downImageView];
        [mWebView addSubview:downLabel];
    }
}

// 更新 赞、踩 按钮高度
- (void)updateUpDownFrames {
    if (mThread.isBeauty == 5) {
        _upButton.bottom = mWebView.height - 64.5f;
        _upImageView.top = _upButton.top;
        _upLabel.top = _upButton.top;
        
        _downButton.top = _upButton.top;
        _downImageView.top = _upButton.top;
        _downLabel.top = _upButton.top;
    }
}


// 显示一个加载失败的控件
// 从新加载页面
-(void)showLoadingErrorView
{
    if (!_loadingErrorButton) {
        
        [self hideActivityIndicator];
        
        CGFloat w = CGRectGetWidth(self.bounds);
        CGFloat h = CGRectGetHeight(self.bounds);
        
        UIImage *btnImg = [UIImage imageNamed:@"news_error"];
        CGFloat btnH = btnImg.size.height;
        UIImageView *errImageV =
        [[UIImageView alloc] initWithImage:btnImg];
        _loadinErrorImageV = errImageV;
        errImageV.center = CGPointMake(w /2, h/2-btnH);
        [self addSubview:errImageV];
    
        
        
        UIButton *errorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loadingErrorButton = errorBtn;
        [errorBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        [errorBtn setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
        [errorBtn setBackgroundColor:[UIColor colorWithHexValue:0xffAD2F2F]];
        [errorBtn addTarget:self
                     action:@selector(loadedErrorButtonClick:)
           forControlEvents:UIControlEventTouchUpInside];
        CGSize btnSize = [errorBtn sizeThatFits:CGSizeZero];
        btnSize.width += 20;
        CGFloat btnX = (w - btnSize.width)/2;
        CGFloat btnY = h / 2 - btnSize.height;
        [errorBtn setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
        errorBtn.layer.cornerRadius = 5.f;
        errorBtn.clipsToBounds = YES;
        errorBtn.center = self.center;
        [self addSubview:errorBtn];
    }
}
-(void)loadedErrorButtonClick:(UIButton *)sender
{
    // 从新加载控件
    [_loadingErrorButton removeFromSuperview];
    [_loadinErrorImageV removeFromSuperview];
    
    ThreadSummary *t = mThread; // 把弱引用变成强引用
    mState = SNViewerStateIdle;
    [self loadWithThread:t];
}

/**
 *  点赞按钮点击
 */
- (void)upButtonClick {
    
    if (!mThread.uped && !mThread.downed) {
        // 点赞动画
        [self upButtonClickAnimation];
        // 更新服务器数据
        [SurfRequestGenerator commitUpDownShareWithNewsId:mThread.newsId type:1 withCompletionHandler:^(BOOL successed) {
            if (successed) {
                // 赞或踩存储到数据库
                [[ThreadsManager sharedInstance] markJokeThreadAsUpedOrDowned:mThread];
            } else {
                [PhoneNotification autoHideJokeWithText:@"网络异常"];
            }
        }];
        
    } else {
        if (mThread.uped) {
            [PhoneNotification autoHideJokeWithText:@"已点过赞"];
        } else {
            [PhoneNotification autoHideJokeWithText:@"已点过踩"];
        }
    }
}

/**
 *  点踩按钮点击
 */
- (void)downButtonClick {
    
    if (!mThread.uped && !mThread.downed) {
        // 点踩动画
        [self downButtonClickAnimation];
        // 更新服务器数据
        [SurfRequestGenerator commitUpDownShareWithNewsId:mThread.newsId type:2 withCompletionHandler:^(BOOL successed) {
            if (successed) {
                // 赞或踩存储到数据库
                [[ThreadsManager sharedInstance] markJokeThreadAsUpedOrDowned:mThread];
            } else {
                [PhoneNotification autoHideJokeWithText:@"网络异常"];
            }
        }];
        
    } else {
        if (mThread.downed) {
            [PhoneNotification autoHideJokeWithText:@"已点过踩"];
        } else {
            [PhoneNotification autoHideJokeWithText:@"已点过赞"];
        }
    }
}

/**
 *  点赞动画
 */
- (void)upButtonClickAnimation {
    _upImageView.image = [UIImage imageNamed:@"content_up_on"];
    _upImageView.animationImages = _upImages;
    _upImageView.animationDuration = 0.7f;
    _upImageView.animationRepeatCount = 1;
    [_upImageView startAnimating];
    
    mThread.uped = YES;
    mThread.upCount ++;
    _upLabel.text = [NSString stringWithFormat:@"%ld", (long)mThread.upCount];
}

/**
 *  点踩动画
 */
- (void)downButtonClickAnimation {
    _downImageView.image = [UIImage imageNamed:@"content_down_on"];
    _downImageView.animationImages = _downImages;
    _downImageView.animationDuration = 0.7f;
    _downImageView.animationRepeatCount = 1;
    [_downImageView startAnimating];
    
    mThread.downed = YES;
    mThread.downCount ++;
    _downLabel.text = [NSString stringWithFormat:@"%ld", (long)mThread.downCount];
}

#pragma mark ----SNContentViewer----

-(SNViewerState)viewerState
{
    return mState;
}

//获取当前展示（或载入中）的帖子
//当状态为Idle或Recycling时返回nil
-(ThreadSummary*)thread
{
    return mThread;
}

/**
 *  加载帖子
 *
 *  @param t   帖子信息
 *  @param isCollect 是否收藏
 */
-(void)loadWithThread:(ThreadSummary*)t
            isCollect:(BOOL)isCollect
{
    _isCollect = isCollect;
    [self loadWithThread:t];
}

-(void)loadWithThread:(ThreadSummary*)t
{
    // 5.0.0 之后新闻都是URL类型
    if(mState == SNViewerStateIdle) {
       
        // 创建webView
        UIView *webView = [self createWebViwe];
        if(![t isUrlOpen]){
        
            //锁定帖子资源
            [[ThreadsManager sharedInstance] lockThreadResource:t];
        
        
            // 5.0.0 之后新闻都是URL类型改版
            mNewsExtension = nil;
            [mTableSourec removeAllObjects];
            
            NewsCellData *newsData = [NewsCellData new];
            newsData.cellType = kWebTableType_webView;
            [mTableSourec addObject:newsData];
            
            [mWebTableView setHidden:NO];
            [mWebTableView reloadData];

        
            // 1.请求新闻信息(每次请求，不保存)
            __block typeof(self) weakSelf = self;
            ThreadContentDownloader *downLoader =
            [ThreadContentDownloader sharedInstance];
            
            [downLoader download:t
                       isCollect:_isCollect
           withCompletionHandler:^(BOOL succeeded,NSString *content ,ThreadSummary *thread)
            {
                // 新闻相关的“评论，正负能量，”
                BOOL isError = YES;
                if(content && ![content isEmptyOrBlank]){
                    SNNewsContentInfoResponse *resp =
                    [SNNewsContentInfoResponse objectWithKeyValues:content];
                    if([resp.res.reCode isEqualToString:@"1"]) {
                
                        // TODO: 加载内容
                        mNewsExtension = resp.news;
                        mNewsExtension.newsId = t.threadId;
                        
                        // 专题过来的新闻没有TITle
                        if([mThread.title isEmptyOrBlank])
                            mThread.title = mNewsExtension.title;
                        
                        BOOL isEnergy = [[mNewsExtension is_energy] boolValue];
                        if (isEnergy != mThread.is_energy) {
                            mThread.is_energy = isEnergy;
                            mThread.positive_energy = [[mNewsExtension positive_energy] integerValue];
                            mThread.negative_energy = [[mNewsExtension negative_energy] integerValue];
                        }
                        
                        // 评论参数不对，已正文为准
                        if(mNewsExtension.isComment.boolValue &&
                           !mThread.isComment){
                            mThread.isComment = YES;
                            mThread.comment_count = mNewsExtension.comment_count.integerValue;
                        }
                        
                        //用于分享的链接
                        mThread.contentUrl = resp.news.content_url;
                        
                        // 没有新闻内容链接，就以URL类型打开
                        NSString *newsUrl = resp.news.content_url;
                        if (!newsUrl || [newsUrl isEmptyOrBlank]) {
                            newsUrl = resp.news.newsUrl;
                            mThread.open_type = 1;// 网页模式。
                            if (!newsUrl || [newsUrl isEmptyOrBlank]) {
                                newsUrl = t.newsUrl;
                            }
                            
                            // 这种方式打开URl，不能调节字体
                            [_delegate snHiddenFontSizeView:YES];
                            
                            
                            // 这样使用，可以让图片适合WebView
                            NSURL *url = [NSURL URLWithString:[newsUrl completeUrl]];
                            NSURLRequest *req = [NSURLRequest requestWithURL:url];
                            isError = NO;
                            [mWebView loadRequest:req];
                        }
                        else {
                            // 这种方式打开，可以调节字体
                            [_delegate snHiddenFontSizeView:NO];
                            isError = NO;
                            
                            newsUrl = [t getNowebpWithUrlString:newsUrl];

                            // 微精选频道 newsUrl为空，导致分享微博不成功。
                            if(!t.newsUrl || [t.newsUrl isEmptyOrBlank]){
                                t.newsUrl = newsUrl;
                            }
                            
                            [weakSelf webViewLoadUrl:[newsUrl completeUrl]];
                        }
                    }
                }
     
                // 异常加载从新加载页面
                if (isError) {
                    [weakSelf showLoadingErrorView];
                }
            }];
        }
        else {
            if (![self.subviews containsObject:webView]) {
                [self insertSubview:webView
                       belowSubview:mLoadingAction];
            }
            [mWebTableView setHidden:YES];
            
            // 直接是加载,发现里面的网址导航, 进入专题。
            NSString *newsUrl = [t buildActivityNewUrl];
            if (newsUrl && ![newsUrl isEmptyOrBlank]) {
                NSURL *url = [NSURL URLWithString:[newsUrl completeUrl]];
                NSURLRequest *req = [NSURLRequest requestWithURL:url];
                [mWebView loadRequest:req];
                
            }
        }
        
        
        // 显示一个加载风火轮
        [self showActivityIndicator];
        mState = SNViewerStateLoading;
        [self.delegate snThreadViewerStateChanged:self];
        mThread = t;
    }
    else if(mState == SNViewerStateLoading) {
        
        //防止重复加载
        if([self thread] == t || [self thread].threadId == t.threadId) return;
        
        //先回收，再加载
        [self recycle:weakifySelf(^(void) {
            [self loadWithThread:t];
        })];
        
    }
    else if(mState == SNViewerStateLoaded) {
        
        //防止重复加载
        if([self thread] == t || [self thread].threadId == t.threadId) return;
        
        //先回收，再加载
        [self recycle:weakifySelf(^(void) {
            [self loadWithThread:t];
        })];
        
    } else if(mState == SNViewerStateRecycling) {
        mRecycleHandler = weakifySelf(^(void) {
            [self loadWithThread:t];
        });
    }
}

/**
 在销毁前手动调用以释放内存
 */
-(void)cleanResourceForDealloc
{
    [self recycle:nil];
    mWebView.delegate = nil;
     
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    // 清除浏览图片缓存
    [[SDImageCache sharedImageCache] cleanDisk];
}


// 显示底部工具栏
-(void)showToolsBar:(BOOL)isShow
{
    if ([mThread isUrlOpen]) {
        return;
    }
    
    
    // 改变工具栏类型
    if ([_delegate respondsToSelector:@selector(snToolsBarTypeChanged: isCollect:)]) {
        BOOL isC = [mNewsExtension.is_collected boolValue];
        [_delegate snToolsBarTypeChanged:SNToolBarTypeNews
                               isCollect:isC];
    }
    
    // 显示工具栏
    if ([_delegate respondsToSelector:@selector(snToolsBarVisible:)]) {
        [_delegate snToolsBarVisible:isShow];
    }
}


// 刷新正负能量值
-(void)refreshEnergy:(long)energyScore
{
    if (!_energyCell || energyScore == 0) {
        return;
    }

    
    if (energyScore > 0) {
        mNewsExtension.positive_energy = @(energyScore + mNewsExtension.positive_energy.integerValue);
        mNewsExtension.positive_count = @(mNewsExtension.positive_count.integerValue + 1);
    }
    else {
        mNewsExtension.negative_energy = @(energyScore + mNewsExtension.negative_energy.integerValue);
        mNewsExtension.negative_count = @(mNewsExtension.negative_count.integerValue + 1);
    }
    [_energyCell loadEnergyInfo:mNewsExtension];
}



-(void)webViewLoadUrl:(NSString*)url;
{
    NSURL *webUrl = [NSURL URLWithString:url];
    // 这里必须使用NSMutableURLRequest，否则无法设置http user-agent
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:webUrl];
    if (![mThread isUrlOpen]) {
        NSString* contentPath = [PathUtil pathOfThreadContent:mThread];
        if(![FileUtil fileExists:contentPath]) {
            // 正文不存在，需要下载
            GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
             {
                 NSURLResponse *response = [fetcher response];
                 NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
                 if(!error && 404 != statusCode && 403 != statusCode)
                 {
                     // 保存到文件中
                     [data writeToFile:contentPath atomically:YES];
                     [mWebView loadData:data
                               MIMEType:[response MIMEType]
                       textEncodingName:[response textEncodingName]
                                baseURL:[request URL]];
                 }
                 else {
                     
                     // 加载失败或404问题
                     // 显示重新加载
                     [DispatchUtil dispatch:^{
                         [self showLoadingErrorView];
                     } after:0.5f];
                 }
             }];
        }
        else {
            NSData *data = [NSData dataWithContentsOfFile:contentPath];
            [mWebView loadData:data
                      MIMEType:@"text/html"
              textEncodingName:@""
                       baseURL:[request URL]];

            
//            NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"iOS 7 Programming Cookbook.pdf" withExtension:nil];
//            
//            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
//
//            
//            
//            NSURL *url = [NSURL fileURLWithPath:contentPath];
//            NSURLRequest *request = [NSURLRequest requestWithURL:url];
//            [mWebView loadRequest:request];
        }
    }
}
-(BOOL)canGoBack
{
    return [mWebView canGoBack];
}
-(BOOL)canGoForward
{
    return [mWebView canGoForward];
}
-(BOOL)isWebViewLoading
{
    return [mWebView isLoading];
}
-(void)stopWebViewLoading
{
    return [mWebView stopLoading];
}
-(void)goBack
{
    [mWebView goBack];
}
-(void)goForward
{
    [mWebView goForward];
}
-(void)refresh
{
    if ([mWebView isLoading]) {
        [mWebView stopLoading];
    }
    

    [self showActivityIndicator];
    [mWebView reload];
}

/**
 *  进入更多评论
 *
 *  @param btn 按钮数据
 */
-(void)enterMoreComment:(UIButton*)btn
{
    if (!mThread) {
        return;
    }
    // 进入更多评论界面
    UIViewController *vc =
    [self findUserObject:[UIViewController class]];
    SEL sel = @selector(toolBarActionNewComment:);
    if ([vc respondsToSelector:sel]) {
        StartSuppressPerformSelectorLeakWarning
        [vc performSelector:sel withObject:mThread];
        EndSuppressPerformSelectorLeakWarning
    }
}

-(ThreadContentResolvingResultV2*) threadResolvingResult
{
    return nil;
//    return mNewsContentRslvResult;
}

// 设置字体大小
- (void)setWebViewFontSize:(float)fontSize
{
//    //字体颜色
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'gray'"];
//    //页面背景色
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.background='#2E2E2E'"];
    
    
//    
//    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@%%'", @(fontSize)];
//    [mWebView stringByEvaluatingJavaScriptFromString:jsString];
    

    NSDictionary *fontSizes =
  @{@(kWebContentSize1):@"s",
    @(kWebContentSize2):@"m",
    @(kWebContentSize3):@"l",
    @(kWebContentSize4):@"sl"};
    NSString *fs = [fontSizes objectForKey:@(fontSize)];
    if (!fs) {
        fs = @"m";
    }
    
    NSString *jsStr = [NSString stringWithFormat:@"javascript:ChangeSize('%@')",fs];
    [mWebView stringByEvaluatingJavaScriptFromString:jsStr];
    
    // WebView 加载完成，更新tableView
    [DispatchUtil dispatch:^{
        [self cleckWebViewFrame:YES];
        
        // 更新 赞、踩 高度
        [self updateUpDownFrames];
    } after:0.5f];
    
}

// 网页中用户选择的内容
-(NSString*)userSelectContent
{
    NSString *js = @"window.getSelection().toString()";
    return [mWebView stringByEvaluatingJavaScriptFromString:js];
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    for(UIView *v in [mWebTableView visibleCells]) {
        [v viewNightModeChanged:isNight];
    }
    
    
//    if (mState == SNViewerStateLoaded) {
//        // 修改夜间模式
//        NSString *js =
//        [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.background='%@';",
//         (isNight?kWebViewBgColor:kWebViewBgColor_night)];
//        [mWebView stringByEvaluatingJavaScriptFromString:js];
//    }
}

#pragma mark ----UIWebViewDelegate----
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DJLog(@"request.URL.absoluteString: %@",request.URL.absoluteString);
    
#pragma mark - 页面上插入js
    if ([request.URL.absoluteString hasPrefix:@"http://go.10086.cn"]) {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"10086_images_handle" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil]];
    } else if ([request.URL.absoluteString hasPrefix:@"http://mobapp.chinaso.com"]) {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"chinaso_images_handle" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil]];
        DJLog(@"这是中国搜索");
    }
    
    
    //    else if([request.URL.absoluteString isEqualToString:RELOAD_CONTENT_CLICK_PREFIX]) {
//        //重新加载
//        [self reloadThreadContentByUserClick];
//        return NO;
//    }
    if([request.URL.absoluteString isEqualToString:SOURCE_URL_CLICK_PREFIX]) {
        //查看原文
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventViewSource withInfo:nil];
        return NO;
        
    } else if ([request.URL.absoluteString hasPrefix:Ad_Click_PREFIX]) {
        // 正文广告点击事件
        NSString *decoded = [request.URL.query urlDecodedString];
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventAdLinkClicked withInfo:decoded];
        return NO;
    } else if([request.URL.absoluteString hasPrefix:Activity_Share_PREFIX]) {
        NSString *decoded = [request.URL.query urlDecodedString];
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventActivityShareClicked withInfo:decoded];
        return NO;

    }
    else if([request.URL.absoluteString hasPrefix:RSS_Click_PREFIX]) {
    
        NSString *decoded = [request.URL.query urlDecodedString];
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventRssClicked withInfo:decoded];
        return NO;
    }
    else if([request.URL.absoluteString hasPrefix:Dissertation_PREFIX])
    {
//    surfnews://news.ifeng.com/a/20151008/44794609_0.shtml&surfcid=847598&surfnid=3268331&issurf=0&surftype=1

        // 专题 + 新闻玩命猜  = surfnews:// 开头的url
        NSString *url = request.URL.absoluteString;
        [self.delegate snThreadViewer:self
                            eventOccurred:SNThreadViewerEventDissertationClicked
                                 withInfo:url];
        return NO;
    }
    else if ([request.URL.absoluteString hasPrefix:IMAGE_URL_CLICK_PREFIX]) {
        // 正文图片点击事件
#pragma mark - 点击图片url
        DJLog(@"点击图片url");
        NSString *imgUrl = [request.URL.absoluteString substringFromIndex:[IMAGE_URL_CLICK_PREFIX length]];
//        NSUInteger index = [self.imgArray indexOfObject:imgString];
        // 弹出图片轮播器
        NSDictionary *urlDic = @{imgUrl : _imageArray};
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventBodyImageClicked withInfo:urlDic];
        
        return NO;
    }
    else if ([request.URL.absoluteString hasPrefix:IMAGE_URL_ARRAY]) {
        DJLog(@"图片数组");
        
        // 取图片数组
        NSString *imgUrls = [request.URL.absoluteString substringFromIndex:[IMAGE_URL_ARRAY length]];
        _imageArray = [imgUrls componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DJLog(@"----webViewDidStartLoad----");
    

    /////纯网页形式
    //这里可能是用户点击页面链接后的二次加载
    if([mThread isUrlOpen]) {
        mState = SNViewerStateLoading;
    }

}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivityIndicator]; // 隐藏loading界面
    
    if(mState == SNViewerStateLoading) {
        
        mState = SNViewerStateLoaded;
        [self.delegate snThreadViewerStateChanged:self];
    

        ////////纯webview
        if ([mThread isUrlOpen]) {
            if([mWebView canGoBack] || [mWebView canGoForward]) {
                if ([self.delegate respondsToSelector:@selector(snThreadViewerCheckGoBackOrGoForward:)]) {
                    [self.delegate snThreadViewerCheckGoBackOrGoForward:self];
                }
            }
            
            
            
            // url 打开方式需要显示title
            NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            if(title && ![title isEmptyOrBlank]) {
                if([_delegate respondsToSelector:@selector(snSetUrlNewsTitle:)]){
                    [_delegate snSetUrlNewsTitle:title];
                }
            }
        
        }
        else {
            
#pragma mark - 执行函数
            [webView stringByEvaluatingJavaScriptFromString:@"setImageClickFunction()"];
            
            // 修改字体大小
            CGFloat fontsize =
            [AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize];
            if (fontsize != kWebContentSize2) {
                [self setWebViewFontSize:fontsize];
            }
            
            // WebView 加载完成，更新tableView
            [DispatchUtil dispatch:^{
                [self webViewFrameChanged];
            } after:0.5f];

        }
        
        // 显示底部工具栏
        [self showToolsBar:YES];
        
    }
    else if(mState == SNViewerStateRecycling) {
        
        //夜间模式时，可能会出现白色闪屏现象，所以应该延时再显示webview
        if([[ThemeMgr sharedInstance] isNightmode]) {
            [DispatchUtil dispatch:^(void){
                mWebView.hidden = NO;
            } after:0.25];
        } else {
            mWebView.hidden = NO;
        }
        
        mState = SNViewerStateIdle;
        [self.delegate snThreadViewerStateChanged:self];
        
        if(mRecycleHandler) {
            [DispatchUtil dispatch:^(void){
                mRecycleHandler();
            } after:0.01];
        }
    }
   
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == NSURLErrorCancelled) {
        //show error alert, etc.
        return;
    }
    
    [self hideActivityIndicator];
    
    
    if (![mThread isUrlOpen]) {
        // 显示加载异常的界面
        [self showLoadingErrorView];
    }
    
    ////////纯webview
    if(mState == SNViewerStateLoading) {
        mState = SNViewerStateLoaded;
        [self.delegate snThreadViewerStateChanged:self];
    }

    
    if([mWebView canGoBack] || [mWebView canGoForward]) {
        if ([self.delegate respondsToSelector:@selector(snThreadViewerCheckGoBackOrGoForward:)]) {
            [self.delegate snThreadViewerCheckGoBackOrGoForward:self];
        }
    }
}

#pragma mark ----UIScrollViewDelegate----

//即将开始被拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    mInUserInteraction = YES;
    if(mWebViewRespondsToScrollWillBeginDragging)
        [mWebView scrollViewWillBeginDragging:scrollView];
    mLastScrollViewOffset = scrollView.contentOffset;
}

//拖拽结束，是否会出现惯性滑动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(mWebViewRespondsToScrollDidEndDragging)
        [mWebView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if(decelerate) {
        //会出现惯性滑动
        
    } else {
        //不会出现惯性滑动
        mInUserInteraction = NO;
        mScrollViewState = SNScrollViewStateIdle;
    }
}

//惯性滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(mWebViewRespondsToScrollDidEndDecelerating)
        [mWebView scrollViewDidEndDecelerating:scrollView];
    mInUserInteraction = NO;
    mScrollViewState = SNScrollViewStateIdle;
}

//发生滑动后的回调，即contentoffset改变
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(mWebViewRespondsToScrollDidScroll)
        [mWebView scrollViewDidScroll:scrollView];
    
    //用户未进行操作时，系统也可能进行回调，对这种情况必须予以排除
    if(!mInUserInteraction) return;
    
    CGPoint p = scrollView.contentOffset;
    
    if(p.y > mLastScrollViewOffset.y) {
        ////向上拖动
        if(p.y > scrollView.contentSize.height - scrollView.frame.size.height) {
            if(mScrollViewState != SNScrollViewStateBouncingBottom) {
                mScrollViewState = SNScrollViewStateBouncingBottom;
                _isAtBottom = YES;
//                [self.delegate snThreadViewerScrollReachBottom:self];
            }
        }
        else {
            if(p.y < 0) {
                if(mScrollViewState != SNScrollViewStateBouncingTopRecover) {
                    mScrollViewState = SNScrollViewStateBouncingTopRecover;
                }
            } else if(p.y > 0) {
                if(mScrollViewState != SNScrollViewStateScrollingDown) {
                    mScrollViewState = SNScrollViewStateScrollingDown;
//                    [self.delegate snThreadViewerBeginScrollDown:self];
                }
            }
        }
        
    }
    else if(p.y < mLastScrollViewOffset.y) {
        ///向下拖动
        if(p.y < 0) {
            if(mScrollViewState != SNScrollViewStateBouncingTop) {
                mScrollViewState = SNScrollViewStateBouncingTop;
            }
            
            if(scrollView.contentSize.height <= scrollView.bounds.size.height) {
                //竖直方向无须滚动
                //因此在第一次bouncing top时，必须认为是离开底部事件
                if(_isAtBottom) {
                    _isAtBottom = NO;
                }
            }
        } else {
            if(p.y > scrollView.contentSize.height - scrollView.frame.size.height) {
                if(mScrollViewState != SNScrollViewStateBouncingBottomRecover) {
                    mScrollViewState = SNScrollViewStateBouncingBottomRecover;
                }
                
            } else if(p.y < scrollView.contentSize.height - scrollView.frame.size.height) {
                
                if(_isAtBottom) {
                    _isAtBottom = NO;
                }
                
                if(mScrollViewState != SNScrollViewStateScrollingUp) {
                    mScrollViewState = SNScrollViewStateScrollingUp;
//                    [self.delegate snThreadViewerBeginScrollUp:self];
                }
            }
        }
    }
    
    mLastScrollViewOffset = scrollView.contentOffset;
}

#pragma mark ----Share----

//网页选中文字分享
-(void)registerShareMenuItem
{
    [self becomeFirstResponder];
    
    UIMenuController *popMenu = [UIMenuController sharedMenuController];
    UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(systemShareHandle:)];
    
    NSArray *menuItems = [NSArray arrayWithObjects:shareItem,nil];
    [popMenu setMenuItems:menuItems];
    [popMenu setArrowDirection:UIMenuControllerArrowDown];
    [popMenu setTargetRect:CGRectMake(162,195,0,0) inView:self];
    
    //如果将系统默认的菜单也显示出来，那么自定义的菜单将作为第二菜单
    [popMenu setMenuVisible:NO animated:YES];
}

-(BOOL) canBecomeFirstResponder{
    return YES;
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(systemShareHandle:)){
        return YES;
    }
    //隐藏系统默认的菜单项
    return NO;
}

//对接中部弹出分享框
- (void)systemShareHandle:(id)sender
{
    NSString *des = [self userSelectContent];
    if (des && ![des isEmptyOrBlank]) {
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventShareSelectText withInfo:des];
    }
}


#pragma mark ----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [mTableSourec count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    BOOL isN = [ThemeMgr sharedInstance].isNightmode;
    NewsCellData *cellData = mTableSourec[indexPath.row];
    WebTableCellType cellType = cellData.cellType;
    if (cellType == kWebTableType_webView ) {
        static NSString *identifier = @"web_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell addSubview:mWebView];
        }
    }
    else if(cellType == kWebTableType_recommend_Header){
        // 推荐头
        static NSString *identifier = @"recommend_header_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            cell = [self createCellHeader:identifier
                                    title:@"更多新闻"
                               cellHeight:cellH];
        }
    }
    else if (cellType == kWebTableType_recommend_News) {
        // 推荐新闻
        static NSString *identifier = @"recommend_News_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            
            // 设置标题属性
            [[cell textLabel] setTextColor:[UIColor colorWithHexValue:0xff333333]];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:15.f]];
            
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            CGFloat cellW = CGRectGetWidth(tableView.bounds);
            
            // 自定义风格线
            CGFloat lineX = 10.f;
            if ([cell respondsToSelector:@selector(separatorInset)]) {
                lineX = cell.separatorInset.left;
            }
            CGRect lineR = CGRectMake(lineX, cellH, cellW-lineX-lineX, 1);
            [cell.layer addSublayer:[self createSeparatorWithFrame:lineR dotLine:YES]];
            
            
            UIView *bgView = [UIView new];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
        }
        
        // 设置标题
        SNRecommendationInfo* recommendInfo = cellData.userData;
        [[cell textLabel] setText:recommendInfo.newsTitle];
        
        
        // 修改背景颜色
        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
        cell.selectedBackgroundView.backgroundColor = bgColor;
    }
    else if(cellType == kWebTableType_EnterSubscribeChannel) {
        // 进入订阅频道
        static NSString *identifier = @"enterSubscribeChannel";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            
            // title
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12.f];
            cell.textLabel.textColor = [UIColor colorWithHexValue:0xffd71919];
            
            // 自定义风格线（说是不需要分割线，暂时去掉了）
//            CGFloat lineX = 10.f;
//            if ([cell respondsToSelector:@selector(separatorInset)]) {
//                lineX = cell.separatorInset.left;
//            }
//            CGRect lineR = CGRectMake(lineX, cellH, cellW-lineX-lineX, 1);
//            [cell.layer addSublayer:[self createSeparatorWithFrame:lineR dotLine:YES]];
            
            // 背景
            UIView *bgView = [UIView new];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
            
        }
    
        // 修改背景颜色
        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
        cell.selectedBackgroundView.backgroundColor = bgColor;
        
        // 进入⌈**⌋频道
        cell.textLabel.text = [NSString stringWithFormat:@"进入「%@」>",mNewsExtension.rssName];
        
    }
    else if(cellType == kWebTableType_advert_Text) {
        // 文字广告
        static NSString *identifier = @"advert_cell_text";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            
            UIView *bgView = [UIView new];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
            
            
            UIColor *textColor = [UIColor colorWithHexValue:0xff999999];
            [[cell textLabel] setTextColor:textColor];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:15.f]];
            
            // 添加虚线，分割线
            CGFloat lineX = 10.f;
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            CGFloat cellW = CGRectGetWidth(tableView.bounds);
            if ([cell respondsToSelector:@selector(separatorInset)]) {
                lineX = cell.separatorInset.left;
            }
            CGRect lineR = CGRectMake(lineX, cellH, cellW-lineX-lineX, 1);
            [cell.layer addSublayer:[self createSeparatorWithFrame:lineR dotLine:YES]];
        }
        
        // 修改背景颜色
        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
        cell.selectedBackgroundView.backgroundColor = bgColor;
        
        
        // 广告信息
        AdvertisementInfo *adInfo = [cellData userData];
        [[cell textLabel] setText:adInfo.title];
    }
    else if(cellType == kWebTableType_advert_Image) {
        // 图片广告
        NSInteger imgViewTag = 100;
        static NSString *identifier = @"advert_cell_image";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIView *bgView = [UIView new];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
            
            
            // 广告图片
            CGFloat edge = 15.f;
            CGFloat cellW = CGRectGetWidth(tableView.bounds);
            CGFloat imgX = edge;
            CGFloat imgW = cellW - edge - edge;
            CGFloat imgH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            UIImageView *imgView = [UIImageView new];
            [imgView setFrame:CGRectMake(imgX, 0, imgW, imgH)];
            [imgView setContentMode:UIViewContentModeScaleAspectFit];
            [imgView setTag:imgViewTag];
            [[cell contentView] addSubview:imgView];
        }
    
        // 广告信息
        AdvertisementInfo *adInfo = [cellData userData];
        NSString *imgPath = [PathUtil pathOfAdvertisementImage:adInfo];
        UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
        UIView *imgView =
        [[cell contentView] viewWithTag:imgViewTag];
        if ([imgView isKindOfClass:[UIImageView class]]) {
            [(UIImageView*)imgView setImage:img];
        }
        
        // 修改背景颜色
        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
        cell.selectedBackgroundView.backgroundColor = bgColor;
    }
    else if (cellType == kWebTableType_Energy_Header){
        static NSString *identifier = @"Energy_Header_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            cell = [self createCellHeader:identifier
                                    title:@"新闻能量"
                               cellHeight:cellH];
        }
    }
    else if(cellType == kWebTableType_Energy) {
        // 正负能量
        static NSString *identifier = @"Energy_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SNEnergyTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            _energyCell =(SNEnergyTableCell*)cell;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        [cell viewNightModeChanged:isN];
        [(SNEnergyTableCell*)cell loadEnergyInfo:mNewsExtension];
    }
    else if(cellType == kWebTableType_hotComment_Header) {
        // 热评论
        static NSString *identifier = @"hotComment_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            cell = [self createCellHeader:identifier
                                    title:@"热门评论"
                               cellHeight:cellH];
        }
    }
    else if (cellType == kWebTableType_hotComment_Content){
        // 热门评论内容
        static NSString *identifier = @"hotCommentContent_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NewsCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
            CGFloat dotsEdge = 10.f;
            if ([cell respondsToSelector:@selector(separatorInset)]) {
                dotsEdge = [cell separatorInset].left;
            }
            
            ((NewsCommentCell*)cell).isDots = YES;
            ((NewsCommentCell*)cell).dotsEdge = dotsEdge;
            ((NewsCommentCell*)cell).isShowPraiseButton = NO;
        }
        
        CommentBase *comment = cellData.userData;
        [(NewsCommentCell*)cell loadCommentData:comment isFirstComment:NO];
    }
    else if (cellType == kWebTableType_hotComment_EnterButton) {
        // 进入评论界面
        static NSString *identifier = @"enterComment_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
            // 查看更多评论
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            CGFloat cellW = CGRectGetWidth(tableView.bounds);
            CGFloat bX = 20.f, bH = 30.f;
            CGFloat bY = (cellH-bH)/2.f;
            CGFloat bW = cellW - bX - bX;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn setTitle:@"查看更多评论" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexValue:0xffd71919] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            btn.backgroundColor = [UIColor whiteColor];
            [btn setFrame:CGRectMake(bX, bY, bW, bH)];
            btn.layer.borderWidth = 1.f;
            btn.layer.cornerRadius = 2.f;
            btn.layer.borderColor = [UIColor colorWithHexValue:0x7f999999].CGColor;
            [btn addTarget:self action:@selector(enterMoreComment:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:btn];
        }
    }
//    else if (cellType == kWebTableType_Subscribe_Header) {
//        static NSString *identifier = @"subscribe_header_cell";
//        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (!cell) {
//            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
//            cell = [self createCellHeader:identifier
//                                    title:@"相关订阅"
//                               cellHeight:cellH];
//        }
//    }
//    else if (cellType == kWebTableType_Subscribe) {
//        static NSString *identifier = @"subscribe_cell";
//        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (!cell) {
//            cell = [[SNThreadSubscribeChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            cell.backgroundColor = [UIColor clearColor];
//            
//            
//            // cell 选择后的背景View
//            UIView *bgView = [UIView new];
//            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            cell.selectedBackgroundView = bgView;
//            
//        }
//        
//        HotChannelRec *rec = cellData.userData;
//        [(SNThreadSubscribeChannelCell*)cell loadDataWithHotChannelRec:rec];
//        
//        // 修改背景颜色
//        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
//        cell.selectedBackgroundView.backgroundColor = bgColor;
//     
//    }
    else if(cellType == kWebTableType_Vote_Header){
        // 评论头
        static NSString *identifier = @"vote_header_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            CGFloat cellH = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            cell = [self createCellHeader:identifier
                                    title:@"参与投票"
                               cellHeight:cellH];
        }
    }
    else if(cellType == kWebTableType_Vote){
        // 投票
        static NSString *identifier = @"vote_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
    
            cell = [[SNVoteTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        SNNewsExtensionInfo *newsInfo = cellData.userData;
        [(SNVoteTableCell*)cell loadDataWithVote:newsInfo];
    }
    else if (cellType == kWebTableType_End) {
        
        static NSString *identifier = @"webEnd_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            
            
            // cell 选择后的背景View
            UIView *bgView = [UIView new];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
            
            
            
            UIFont *textFont = [UIFont systemFontOfSize:12.f];
            cell.textLabel.text = @"原网页已经由手机冲浪转码";
            cell.textLabel.font = textFont;
            cell.textLabel.textColor = [UIColor colorWithHexValue:0xff999999];
            
            
            cell.detailTextLabel.text = @"查看原网页";
            cell.detailTextLabel.font = textFont;
            cell.detailTextLabel.textColor =
            [UIColor colorWithHexValue:0xff2167bd];
        }
        
        
        // 修改背景颜色
        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
        cell.selectedBackgroundView.backgroundColor = bgColor;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCellData *cellData = mTableSourec[indexPath.row];
    WebTableCellType cellType = [cellData cellType];
    if (cellType == kWebTableType_webView) {
        return mWebView.frame.size.height;
    }
    else if(cellType == kWebTableType_Energy)
        return [SNEnergyTableCell energyCellHeight];
    else if(cellType == kWebTableType_recommend_Header)
        return 60.f;
    else if (cellType == kWebTableType_advert_Image) {
        // 480 * 80
        CGFloat edge = 15.f;
        CGFloat cellW = CGRectGetWidth(tableView.bounds);
        return (cellW - edge - edge)/6;
    }
    else if (cellType == kWebTableType_hotComment_Content){
        return [NewsCommentCell calcCellHeight:cellData.userData];
    }
//    else if (cellType == kWebTableType_Subscribe ) {
//        return [SNThreadSubscribeChannelCell cellSizeWithFits];
//    }
    else if (cellType == kWebTableType_EnterSubscribeChannel)
        return 30.f;
    else if (cellType == kWebTableType_End)
        return 45.f;
    else if (cellType == kWebTableType_Vote)
        return [SNVoteTableCell cellHeight:cellData.userData];
    
    
    return 45.f;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NewsCellData *cellData = mTableSourec[indexPath.row];
    WebTableCellType cellType = [cellData cellType];
    
    // 推荐新闻
    if (cellType == kWebTableType_recommend_News) {
        // 相关推荐点击
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventRelativeLinkClicked withInfo:cellData.userData];
    }
//    else if(cellType == kWebTableType_Subscribe) {
//        // 正文订阅rss
//        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventRssSubscribe withInfo:cellData.userData];
//    }
    else if (cellType == kWebTableType_advert_Image ||
        cellType == kWebTableType_advert_Text) {
        
        // 正文广告点击事件
        [self.delegate snThreadViewer:self
                        eventOccurred:SNThreadViewerEventAdLinkClicked
                             withInfo:cellData.userData];
    }
    else if (cellType == kWebTableType_Energy) {
        [self.delegate snShowEnergyView];
    }
    else if (cellType == kWebTableType_End) {
        [self.delegate snThreadViewer:self eventOccurred:SNThreadViewerEventViewSource withInfo:mNewsExtension.newsUrl];
    }
    else if(cellType == kWebTableType_EnterSubscribeChannel) {
        // 进入RSS频道
       [self.delegate snThreadViewer:self
                       eventOccurred:SNThreadViewerEventEnterRssChannel
                            withInfo:mNewsExtension];
    }
}


-(UITableViewCell *)createCellHeader:(NSString*)identifier
                               title:(NSString*)title
                          cellHeight:(CGFloat)cH
{
    
    NSInteger separator_red_width = 70.f;
    UIFont *tFont = [UIFont boldSystemFontOfSize:15.f];
    UIColor *textColor = [UIColor colorWithHexValue:0xffd71919];
    UIColor *lineColor = [UIColor colorWithHexValue:0xff999999];
    
    UITableViewCell *cell =
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                           reuseIdentifier:identifier];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    CGFloat sX = 10.f;
    if ([cell respondsToSelector:@selector(separatorInset)]) {
        sX = [cell separatorInset].left;
    }

    CGFloat tY = cH - tFont.lineHeight - 10.f;
    CGRect titleR = CGRectMake(sX, tY, 100, tFont.lineHeight);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleR];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleLabel setTextColor:textColor];
    [[cell contentView] addSubview:titleLabel];
    
    // 自定义分割线
    CGFloat lineX = sX + separator_red_width;
    CGFloat lineWidth = kContentWidth- sX- sX-separator_red_width;
    CGRect lineR = CGRectMake(lineX, cH-1, lineWidth, .5f);
    CALayer *lineLayer = [CALayer new];
    [lineLayer setFrame:lineR];
    [lineLayer setBackgroundColor:lineColor.CGColor];
    [[cell contentView].layer addSublayer:lineLayer];
    
    
    // 自定义红色分割线
    CGRect separatorR = CGRectMake(sX, cH-1, separator_red_width, .5f);
    CALayer *separator_red_Layer = [CALayer new];
    [separator_red_Layer setFrame:separatorR];
    [separator_red_Layer setBackgroundColor:textColor.CGColor];
    [[cell contentView].layer addSublayer:separator_red_Layer];
    
    return cell;
}

// 创建一个虚线的分隔符
-(CALayer*)createSeparatorWithFrame:(CGRect)r
                            dotLine:(BOOL)isDotLine
{
    UIColor *lineColor = [UIColor colorWithHexValue:0xffeeeeee];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = r;
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:lineColor.CGColor];
    
    // 设置虚线的宽度
    [shapeLayer setLineWidth:.5f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    // 3=线的宽度 1=每条线的间距
    if (isDotLine) {
        [shapeLayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:3],
          [NSNumber numberWithInt:1],nil]];
    }
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL, 0, 0);
    CGPathAddLineToPoint(path,NULL, CGRectGetWidth(r), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    return shapeLayer;
}

#pragma mark - KVO 监听webView的scrollView的contentSize变化
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        
//        CGSize contentSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        if (mState == SNViewerStateLoaded) {
            [self cleckWebViewFrame:NO];
            
        }
    }
    
//    [self removeObserverForWebViewContentSize];
//    
//    CGSize contentSize = mWebView.scrollView.contentSize;
//    mWebView.scrollView.contentSize = CGSizeMake(contentSize.width, contentSize.height + 100);
//    DJLog(@"%@", NSStringFromCGSize(mWebView.scrollView.contentSize));
//    
//    [self addObserverForWebViewContentSize];
}

- (void)addObserverForWebViewContentSize{
    [mWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObserverForWebViewContentSize{
    [mWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

@end