//
//  PhoneHotRootcontrollerViewController.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneHotRootcontroller.h"
#import "GTMHTTPFetcher.h"
#import "EzJsonParser.h"
#import "ThreadsManager.h"
#import "AppDelegate.h"
#import "ReadNewsController.h"
#import "NSString+Extensions.h"
#import "PhoneSelectCityController.h"
#import "AppSettings.h"
#import "WeatherView.h"
#import "OfflineDownloader.h"
#import "FutureWeatherView.h"
#import "FlowIndicatorViewController.h"
#import "iTunesLookupUtil.h"
#import "DownLoadViewController.h"
#import "ThreadsManager.h"
#import "NetworkStatusDetector.h"
#import "UIAlertView+Blocks.h"
#import "SelectLocalCityNewsController.h"
#import "DispatchUtil.h"
#import "UIColor+extend.h"
#import "SurfFlagsManager.h"
#import "ShowWeatherViewController.h"
#import "UIButton+Block.h"
#import "SearchViewController.h"
#import "OrderViewController.h"
#define HotChannelItemWidth  54.0f
#define HotChannelItemHeight 35.0f
#define ITEM_TAGOFFSET  500

@implementation HotChannelItemView

@synthesize hotChannal;

- (id)initWithFrame:(CGRect)frame controller:(id)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = controller;
        
        channelItemLabel = [[UILabel alloc] initWithFrame:self.bounds];
        channelItemLabel.backgroundColor = [UIColor clearColor];
        channelItemLabel.font = [UIFont systemFontOfSize:15.0f];
        [channelItemLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:channelItemLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                    action:@selector(channelItemDidTap:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        
        
    }
    return self;
}

- (void)setHotChannal:(HotChannel *)theHotchannel
{
    hotChannal = theHotchannel;
    channelItemLabel.text = [self isTranslateName:hotChannal.channelName];
}

- (NSString*)isTranslateName:(NSString*)str{
    NSString* name = nil;
    if ([str isEqualToString:@"本地"]) {
        WeatherInfo *cityInfo = [[WeatherManager sharedInstance] weatherInfo];
        name = cityInfo.cityName;
        
        //如果城市名字大于3个字符
        if ([name length] > 3 ) {
            name = @"本地";
        }
    }
    else{
        name = str;
    }
    
    return name;
}

- (void)channelItemDidTap:(UITapGestureRecognizer*)gestureRecognizer
{
    [self.delegate channelItemDidSelected:hotChannal];
}

- (void)setItemSelected
{
    channelItemLabel.textColor = [UIColor colorWithHexValue:0xffAD2F2F];
}

- (void)setItemUnselected
{
    if (isNightMode) {
        channelItemLabel.textColor = [UIColor whiteColor];
    } else {
        channelItemLabel.textColor = [UIColor colorWithHexValue:0xff34393D];
    }
}

- (void)applyTheme:(BOOL)isNight
{
    isNightMode = isNight;
    
    if (isNightMode) {
        channelItemLabel.textColor = [UIColor whiteColor];
    } else {
        channelItemLabel.textColor = [UIColor colorWithHexString:@"34393D"];
    }
}

- (void)setImageView:(BOOL)show{
    if (show) {
        [isnewView setImage:[SurfFlagsManager flagImage]];
    }
    else{
        [isnewView setImage:nil];
    }
}

- (void)setItemIsNew:(HotChannel *)hotCh
{
    if (hotCh.isnew) {
        
        SurfFlagsManager *manager = [SurfFlagsManager sharedInstance];
        [isnewView setImage:nil];
        if([manager checkNewsChannelIsAddChannel:hotCh])
        {
            //根据字符长度 设置红点标示位置
            if(hotCh.channelName.length == 2)
                isnewView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 7, 7)];
            else if(hotCh.channelName.length == 3){
                isnewView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 0, 7, 7)];
            }
            
            [isnewView setImage:[SurfFlagsManager flagImage]];
            [self addSubview:isnewView];
        }
    }
}

@end

#define ScrollViewOffSet 34.0f

@implementation HotChannelScrollView
+ (CGFloat)fitHeight
{
    return 37.f;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        baImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:baImageView];
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.tag = 1000;
        scrollView.bounces = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:scrollView];
        
        
        selectedView = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 32.0f, 37.5f, 2.0f)];
        selectedView.backgroundColor =
        [UIColor colorWithHexValue:0xffAD2F2F];
        [selectedView setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)reloadViewWithArray:(NSArray*)array controller:(id)controller
{
    _channelArray = array;
    
    for (UIView *view in [scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    CGFloat drawX =15+4.5;  //距离最左边的距离
    CGFloat H = 20;         //scrollView的高度
    for (NSInteger i = 0; i < [_channelArray count]; i ++) {
        
        HotChannel * hotChannal=[_channelArray objectAtIndex:i];
        NSString * str=hotChannal.channelName;
        //根据字符串 获取应该需要的尺寸
        CGSize size=[str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        CGFloat W=size.width;
                H=size.height;

        HotChannelItemView *itemView = [[HotChannelItemView alloc] initWithFrame:CGRectMake(drawX, ([HotChannelScrollView fitHeight]-3-2-H)/2.0, W, H) controller:controller];
        drawX+=W+25;//两个频道间隔25
        
//        HotChannelItemView *itemView = [[HotChannelItemView alloc] initWithFrame:CGRectMake(HotChannelItemWidth * i, 0.0f, HotChannelItemWidth, HotChannelItemHeight) controller:controller];
        itemView.hotChannal = hotChannal;
        itemView.tag = i;
        [itemView applyTheme:isNightMode];
        [itemView setItemIsNew:itemView.hotChannal];
        [scrollView addSubview:itemView];
    }
    [scrollView addSubview:selectedView];
    
    //ScrollViewOffSet是多出的一块
    [scrollView setContentSize:CGSizeMake(drawX + ScrollViewOffSet, H)];
}

- (void)setSelectedImageWithTag:(NSInteger)tag
{
    //设置选中和未选中的状态
    for (HotChannelItemView *view in [scrollView subviews])
    {
        if ([view isKindOfClass:[HotChannelItemView class]]) {
            if (view.tag == tag) {
                _itemView = view;
                [view setImageView:NO];
                [view setItemSelected];
                [self setSelectedViewLocation:view];
            } else {
                [view setItemUnselected];
            }
        }
    }
}

-(void)setSelectedViewLocation:(UIView*)itemView
{
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat centerX = itemView.center.x;
        CGPoint selCenter = selectedView.center;
        selCenter.x = centerX;
        selectedView.center = selCenter;
    } completion:^(BOOL finished) {
        
        // 滑动HeaderView
        CGFloat offX = scrollView.contentOffset.x;
        CGFloat halfWidth = CGRectGetWidth(scrollView.bounds)/2;
        CGFloat targetX = halfWidth + offX;
        CGFloat itemX = itemView.center.x;
        if (itemView.center.x < targetX-10) {
            CGFloat more =  targetX - itemX;
            offX -= more;
            offX = offX < 0?0:offX;
            
            CGPoint offPoint = scrollView.contentOffset;
            offPoint.x = offX;
            [scrollView setContentOffset:offPoint animated:YES];
        }
        else if(itemView.center.x > targetX + 10)
        {
            CGFloat offMaxX = scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds);
            CGFloat more = itemX - targetX;
            offX += more;
            offX = offX > offMaxX ? offMaxX:offX;
            
            CGPoint offPoint = scrollView.contentOffset;
            offPoint.x = offX;
            [scrollView setContentOffset:offPoint animated:YES] ;
        }
    }];
}

-(void)setSelectedViewMoveLocation:(CGFloat)percent
{
    if (_itemView) {
        CGFloat sX = _itemView.center.x;
        CGFloat more = HotChannelItemWidth * percent;
        CGPoint selCenter = selectedView.center;
        selCenter.x = sX + more;
        selectedView.center = selCenter;
    }
}

//在gridView上点击时滑动的特定位置
- (void)scrollToTheLocationWhenClickGridView:(NSInteger)tag
{
    if (scrollView.contentOffset.x > tag * HotChannelItemWidth) {
        [scrollView setContentOffset:CGPointMake(tag* HotChannelItemWidth, 0.0f) animated:YES];
    } else if (((tag - 5) * HotChannelItemWidth + ScrollViewOffSet) > scrollView.contentOffset.x) {
        [scrollView setContentOffset:CGPointMake((tag - 5) * HotChannelItemWidth + ScrollViewOffSet, 0.0f) animated:YES];
    }
}

- (void)applyTheme:(BOOL)isNight
{
    isNightMode = isNight;
    
    if (isNight) {
        UIImage *image = [UIImage imageNamed:@"hot_gridview_bg_night"];
        [baImageView setImage:[image stretchableImageWithLeftCapWidth:1.0f topCapHeight:0.0f]];
    } else {
        UIImage *image = [UIImage imageNamed:@"hot_gridview_bg"];
        [baImageView setImage:[image stretchableImageWithLeftCapWidth:1.0f topCapHeight:0.0f]];
    }
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[HotChannelItemView class]]) {
            HotChannelItemView *hView = (HotChannelItemView*)view;
            [hView applyTheme:isNight];
        }
    }
}

@end

@implementation PhoneHotRootController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = SNState_TopBar;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    UIImageView *topBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, [self topBarView].frame.size.height-20)];
    [topBgImage setImage:[UIImage imageNamed:@"kx_bg"]];
    [[self topBarView] addSubview:topBgImage];
    
    // 增加一个刷新按钮
//    UIImage *logoImg = [UIImage imageNamed:@"newsLogo"];
    UIImage *logoImg = [UIImage imageNamed:@"kx_logo"];
    UIImage *topRefreshImg = [UIImage imageNamed:@"topUI_refresh"];
    CGFloat logoW = logoImg.size.width;
    CGFloat logoH = logoImg.size.height;
    CGFloat refreshW = topRefreshImg.size.width;
    CGFloat refreshH = topRefreshImg.size.height;
//    CGFloat logoX = (width - (logoW + refreshW))/2.f;
    CGFloat logoX = (width - logoW)/2.f;
    CGFloat logoY = self.StateBarHeight - logoH - 10.f;
    CGRect logoR = CGRectMake(logoX, logoY, logoW, logoH);
    
    /****UIImageView换成UIButton，增大了导航条上刷新按钮的范围
    logoImageView = [[UIImageView alloc] initWithFrame:logoR];
    logoImageView.image = logoImg;
    [logoImageView setUserInteractionEnabled:NO];
    */
    UIButton * logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoBtn setBackgroundImage:logoImg
                          forState:UIControlStateNormal];
    [logoBtn addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    logoBtn.frame = logoR;
    [[self topBarView] addSubview:logoBtn];
    
    refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setBackgroundImage:topRefreshImg
                          forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    refreshBtn.frame = CGRectMake(0, 0, refreshW, refreshH);
    CGPoint btnCenter = logoBtn.center;
    btnCenter.x += (logoW + refreshW)/2 + 5.f;
    refreshBtn.center = btnCenter;
    [refreshBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [[self topBarView] addSubview:refreshBtn];
    
    // 添加天气
    CGSize weatherSize = [WeatherView suitableSize];
    CGPoint weatherPoint =
    CGPointMake(15,
                [self StateBarHeight]-weatherSize.height+5);
    weatherView = [[WeatherView alloc] initWithPoint:weatherPoint];
    [weatherView addTarget:self action:@selector(weatherViewClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self topBarView] addSubview:weatherView];
    
    //添加一个搜索按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * btnImage=[UIImage imageNamed:@"searchImageView"];
    CGFloat btnH=btnImage.size.height;
    btn.frame = CGRectMake(320-btnH-24, (44-btnH)/2.0+12, 36, 36);
//    btn.backgroundColor = [UIColor redColor];
    [btn setImage:btnImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [[self topBarView] addSubview:btn];

    
    // 新闻频道列表滚动View
    CGFloat headerHeight = [HotChannelScrollView fitHeight];
    headerScrollView = [[HotChannelScrollView alloc] initWithFrame:CGRectMake(0.0f, [self StateBarHeight], kContentWidth, headerHeight)];
    
    expandButtonBg = [[UIImageView alloc] initWithFrame:CGRectMake(kContentWidth - 45.0f, self.StateBarHeight, 45.0f, headerHeight)];
    [expandButtonBg setUserInteractionEnabled:NO];
    
    expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expandButton.frame = CGRectMake(kContentWidth - 40.0f, [self StateBarHeight], 40.0f, headerHeight);
    [expandButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [expandButton addTarget:self
                     action:@selector(expandGridView:)
           forControlEvents:UIControlEventTouchUpInside];
    
    isnewView = [[UIImageView alloc] initWithFrame:CGRectMake(30,5,7,7)];
    
    
    CGRect tempRect = CGRectMake(0.0f,[self StateBarHeight] + headerHeight,
                                 kContentWidth,
                                 kContentHeight - [self StateBarHeight] - headerHeight - kTabBarHeight);
    hotScrollView = [[HotChannelsScrollScreenView alloc] initWithFrame:tempRect];
    hotScrollView.hotChannelChangedDelegate = self;
    hotScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:hotScrollView];
    [self.view addSubview:headerScrollView];
    [self.view addSubview:expandButtonBg];
    [self.view addSubview:expandButton];
    
    // 频道详情数组
    threads = [NSMutableArray arrayWithCapacity:20];
    
    // 请求频道列表
    [self requestHotChannelsList];
    
    // 添加一个cityID 改变委托
    [[WeatherManager sharedInstance] addCityIdChangeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeChanel:) name:@"SELECTCHANEL" object:nil];
}
- (void)searchBtnClick
{
    SearchViewController *searchVC = [SearchViewController new];
    [self presentController:searchVC animated:PresentAnimatedStateFromRight];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 检查天气是否需要更新
    [weatherView checkWeatherChange];
    
    if (currentHotChannel == nil) {
        [self requestHotChannelsList];
    } else {
        NSUInteger index = [[HotChannelsManager sharedInstance].visibleHotChannels indexOfObject:currentHotChannel];
        [headerScrollView setSelectedImageWithTag:index];
        
        
        // 刷新数据
        [hotScrollView reloadHotChannels:NO isReloadEqualHotchannel:YES];
    }
    
    
    if (_disappearPurpose == PhoneHotRootDisapperPurposeOpenThread)
    {
        // 执行帖子Cell 展示开可视区域
        ThreadSummary *thread = [[ThreadsManager sharedInstance] getLastReadThread];
        if (thread) {
            [[hotScrollView curHotChannelsView] setScrollOfThread:thread];
        }
    }
    
    // 2014.12.23 add by xuxg 选择本地新闻城市之后，需要从新刷新频道列表
    if (_disappearPurpose == PhoneHotRootDisapperPurposeSelectLocalCityNew){
        // 如何判断用户切换城市呢?
        // 1 拿到就的本地频道名，有可能没有
        NSString *oldLocalCityName = nil;
        HotChannelsManager *manager = [HotChannelsManager sharedInstance];
        for (NSInteger i=1; i<manager.visibleHotChannels.count; ++i) {
            HotChannel *hc = manager.visibleHotChannels[i];
            if (hc.channelId == 0){
                oldLocalCityName = hc.channelName;
                break;
            }
        }
        
        // 2 和用户选择城市新闻对比
        NSString *selectCityName = [AppSettings stringForKey:StringKey_LocalCity];
        if (selectCityName && ![selectCityName isEmptyOrBlank]) {
            if (!oldLocalCityName ||
                ![oldLocalCityName containsCasInsensitive:selectCityName]) {
                _isLocalNewsCityChanged = YES;
                [self requestHotChannelsList];
            }
        }
    }
    
    //复位
    self.disappearPurpose = PhoneHotRootDisapperPurposeUnknown;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self unexpandGridViewWithAnimate:NO];
    
    if (_disappearPurpose != PhoneHotRootDisapperPurposeSelectCity) {
        [self hiderFutureWeather];
    }
}

#pragma mark- 新闻频道请求

// 请求频道列表
-(void)requestHotChannelsList
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    
    if ([manager.visibleHotChannels count] > 0 && currentHotChannel == nil) {
        [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
        [headerScrollView setSelectedImageWithTag:0];
        currentHotChannel = [manager.visibleHotChannels objectAtIndex:0]; // 默认刚启动的是热推频道
    }
    [manager refreshWithCompletionHandler:^(BOOL succeeded,BOOL noChanges) {
        if (succeeded && !noChanges) {
            NSUInteger index = 0;
            if (currentHotChannel != nil) {
                // 获取一样Id的热门频道
                HotChannel *hc = [[HotChannelsManager sharedInstance] getChannelWithSameId:currentHotChannel inArray:manager.visibleHotChannels];
                if (hc) {
                    index = [manager.visibleHotChannels indexOfObject:hc];
                }
                
                // 在本地频道的时候，切换天气城市出现的Crash问题
                index = (index == NSNotFound) ? 0 : index;
            }
 
            
            if (index < [manager.visibleHotChannels count]) {
                 currentHotChannel = [manager.visibleHotChannels objectAtIndex:index];
                
                [self newsIsUpate];
                [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
                [headerScrollView setSelectedImageWithTag:index];
                [headerScrollView scrollToTheLocationWhenClickGridView:index];
                [hotScrollView setCurrentHotChannel:currentHotChannel];// 热门频道发生改变，就需要通知滚屏更新
                
                // 2014.12.23 add by xuxg 新增本地频道切换，需要刷新本地频道的新闻列表
                if (_isLocalNewsCityChanged) {
                    _isLocalNewsCityChanged = NO;
                    [hotScrollView refreshLocalChannel];
                }
            }
        }
    }];
}
- (void)newsIsUpate
{
    SurfFlagsManager *sfm = [SurfFlagsManager sharedInstance];
    BOOL Update = [sfm isExistNewsChannelFlag];
    UIImage* imgNews = nil;
    if (Update) {
        [isnewView setImage:[SurfFlagsManager flagImage]];
    }
    else{
        [isnewView setImage:imgNews];
    }
    
    
    if (isnewView.superview == nil) {
        [expandButton addSubview:isnewView];
    }
    
}

- (void)selectChannelFromSpalshWithChannelId:(long)channelId
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    for (HotChannel *channel in manager.visibleHotChannels) {
        if (channel.channelId == channelId) {
            NSUInteger index = [manager.visibleHotChannels indexOfObject:channel];
            [headerScrollView scrollToTheLocationWhenClickGridView:index];
            [headerScrollView setSelectedImageWithTag:index];
            currentHotChannel = channel;
            [hotScrollView setCurrentHotChannel:currentHotChannel];
            break;
        }
    }
}


#pragma mark 弹出菜单
//- (void)showPopMenu
//{
//    float btnWidth = 170;          // 按钮宽度
//    float menuHeight = [UserManager sharedInstance].loginedUser.userID? 3 * 44 + 15 : 2 * 44 + 15;
//    CGRect menuRect = CGRectMake(kContentWidth-btnWidth - 10,
//                                 self.StateBarHeight - 10,
//                                 btnWidth, menuHeight);
//
//    if (!_popMenu)
//    {
//        _popMenu = [[PopMenuView alloc] initWithFrame:menuRect];
//        [_popMenu setPopMenuViewDelegate:self];
//    }
//    
//    if (!popBgView)
//    {
//        popBgView = [[BgScrollView alloc] initWithFrame:theApp.window.frame];
//        [popBgView setBgSvDelegate:self];
//        [popBgView setBackgroundColor:[UIColor clearColor]];
//    }
//    [popBgView addSubview:_popMenu];
//
//
//    [self.view addSubview:popBgView];
//
//    
//    CGAffineTransform transform = _popMenu.transform;
//    transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
//    _popMenu.transform = transform;
//    
//    [UIView animateWithDuration:0.05f animations:^
//     {
//         CGAffineTransform transform = _popMenu.transform;
//         transform = CGAffineTransformScale(transform, 1.3f, 1.3f);
//         _popMenu.transform = transform;
//         
//     } completion:^(BOOL finished) {
//         [UIView animateWithDuration:0.05f animations:^{
//             _popMenu.transform = CGAffineTransformIdentity;
//         }];
//         
//     }];
//}
//
//-(void)hidePopMenu
//{
//    if(popBgView && [popBgView.subviews containsObject:_popMenu])
//    {
//        [UIView animateWithDuration:0.08f animations:^{
//            CGAffineTransform transform = _popMenu.transform;
//            transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
//            _popMenu.transform = transform;
//            
//        } completion:^(BOOL finished) {
//            [_popMenu removeFromSuperview];
//            [popBgView removeFromSuperview];
//            
//            _popMenu = nil;
//            popBgView = nil;
//        }];
//    }
//}

#pragma mark PopMenuViewDelegate
//- (void)clickMenuBt:(UIButton *)bt
//{
//    if (10 == bt.tag)
//    {
//        if ([[ThemeMgr sharedInstance] isNightmode])
//        {
//            [[ThemeMgr sharedInstance] changeNightmode:NO];
//        }
//        else
//        {
//            [[ThemeMgr sharedInstance] changeNightmode:YES];
//        }
//        
//    }
//    if (50 == bt.tag)
//    {
//        [self offlineDownloadClick:bt];
//    }
//    else if(100 == bt.tag)
//    {
//        [UIView beginAnimations:@"animationName" context:nil];
//        [UIView setAnimationDuration:0.08]; //动画持续的秒数
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(showFlowIndicatorViewCrl)];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        CGAffineTransform transform = _popMenu.transform;
//        transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
//        _popMenu.transform = transform;
//        
//        [UIView commitAnimations];
//        
//    }
//}

#pragma mark BgScrollViewDelegate
//- (void)cilickBgScrollView:(BgScrollView *)bgScroll
//{
//}

#pragma mark HotChannelItemViewDelegate methods
- (void)channelItemDidSelected:(HotChannel *)channel
{
    HotChannel* temHC = channel;
    [[SurfFlagsManager sharedInstance] markNewsChnannelAsRead:channel];
    [self newsIsUpate];

    HotChannelsManager *manager = [HotChannelsManager sharedInstance];    
    channel = [manager getChannelWithSameId:channel inArray:manager.visibleHotChannels];
    if (channel == nil) {
        [manager.visibleHotChannels addObject:temHC];
        [manager.invisibleHotChannels removeObject:temHC];
        channel = temHC;
    }
    NSUInteger index = [manager.visibleHotChannels indexOfObject:channel];
    manager.selectChannelIndex = (int)index;
    if (channel.channelId == currentHotChannel.channelId) {//再次选择当前频道,不做操作
        currentHotChannel = channel;
        return;
    }
    
    [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
//    [headerScrollView setSelectedImageWithTag:index];
    [headerScrollView scrollToTheLocationWhenClickGridView:index];
    [hotScrollView setCurrentHotChannel:currentHotChannel];// 热门频道发生改变，就需要通知滚屏更新
    
    [headerScrollView setSelectedImageWithTag:index];
    currentHotChannel = channel;
    [hotScrollView setCurrentHotChannel:channel];
}
- (void)changeChanel:(NSNotification *)noti
{
    OrderViewController * orderVC = [self.childViewControllers objectAtIndex:0];
    [[[self.childViewControllers  objectAtIndex:0] view] removeFromSuperview];
    [orderVC removeFromParentViewController];

    
    NSDictionary*info=[noti object];
    NSLog(@"%@",info);
    HotChannel* hc = [info objectForKey:@"Model"];
    [self channelItemDidSelected:hc];
    
}
-(void)backAction
{
    OrderViewController * orderVC = [self.childViewControllers objectAtIndex:0];
    [[[self.childViewControllers  objectAtIndex:0] view] removeFromSuperview];
    [orderVC removeFromParentViewController];
    
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSMutableArray* array1 = [[NSMutableArray alloc]init];
    for (int i=0; i<orderVC.viewArr1.count; i++) {
        TouchView* touchview = [orderVC.viewArr1 objectAtIndex:i];
        [array1 addObject:touchview.touchViewModel];
    }
    
    NSMutableArray* array2 = [[NSMutableArray alloc]init];
    for (int i=0; i<orderVC.viewArr2.count; i++) {
        TouchView* touchview = [orderVC.viewArr2 objectAtIndex:i];
        [array2 addObject:touchview.touchViewModel];
    }
    
    manager.visibleHotChannels = array1;
    manager.invisibleHotChannels = array2;
    [manager handleHotChannelsResorted];
    [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
    

    // 刷新数据
    NSUInteger index = [manager.visibleHotChannels indexOfObject:currentHotChannel];
    if (index == NSNotFound) {
        index = 0;
        currentHotChannel = manager.visibleHotChannels[index];
    }

    [HotChannelsManager sharedInstance].selectChannelIndex = (int)index;
    [headerScrollView setSelectedImageWithTag:index];
    [hotScrollView setCurrentHotChannel:currentHotChannel];
}
- (void)expandGridView:(UIButton*)button
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSArray* channels = manager.visibleHotChannels;
    OrderViewController * orderVC = [[OrderViewController alloc] init];
    orderVC.titleArr = channels;
    orderVC.urlStringArr = [NSArray array];
    UIView * orderView = [orderVC view];
    [orderView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [orderView setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
    [orderVC.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:orderView];
    [self addChildViewController:orderVC];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [orderView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
        
    } completion:^(BOOL finished){
        
    }];
    
    /*
    if (gridView) {
        return;
    }
    
    
    //搞死其他控件的触摸操作
    hotScrollView.userInteractionEnabled = NO;
    headerScrollView.userInteractionEnabled = NO;
    
    //注意，这里的singleFingerTap是个傀儡，它的处理函数中啥都不干
    //我们利用的是其delegate回调：- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
    //因为我们的需求是在触摸开始时就把展开的面板搞死，而不是在单击操作结束后
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    [self.view addGestureRecognizer:singleFingerTap];
    
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    
    gridView = [PhoneHotChannelGridView new];
    gridView.delegate = self;
    gridView.dataSource = self;
    gridView.widthOfView = kContentWidth;
    gridView.edgeInsets = UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f);
    gridView.itemHorizontalSpacing = 10.0f;
    gridView.itemVerticalSpacing = 5.0f;
    gridView.itemCountPerRow = 4;
    gridView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gridView];
    
    [gridView applyTheme:[[ThemeMgr sharedInstance] isNightmode]] ;
    
    topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight, kContentWidth, 37.0f)];
    UIImage *image = [UIImage imageNamed:isN ? @"hot_gridview_bg_night" : @"hot_gridview_bg"];
    [topImageView setImage:[image stretchableImageWithLeftCapWidth:1.0f topCapHeight:0.0f]];
    topImageView.alpha = 0.0f;
    [self.view addSubview:topImageView];
    

    
    unexpandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unexpandButton.alpha = 0.0f;
    unexpandButton.frame = CGRectMake(kContentWidth - 40.0f, [self StateBarHeight], 40.0f, 37.0f);
    [unexpandButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [unexpandButton addTarget:self
                     action:@selector(unexpandGridView:)
           forControlEvents:UIControlEventTouchUpInside];
    unexpandButton.transform = CGAffineTransformRotate(unexpandButton.transform, M_PI);
    [self newsIsUpate];
    
    [self.view addSubview:unexpandButton];
    

    
    allChannelsLabel = [[UILabel alloc] initWithFrame:CGRectMake(-180.0f, self.StateBarHeight + 5.0f, 60.0f, 25.0f)];
    allChannelsLabel.text = @"所有频道";
    allChannelsLabel.font = [UIFont systemFontOfSize:15.0f];
    allChannelsLabel.backgroundColor = [UIColor clearColor];
    allChannelsLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
    [self.view addSubview:allChannelsLabel];
    
    clickChannelLabel = [[UILabel alloc] initWithFrame:CGRectMake(-100.0f, self.StateBarHeight + 5.0f, 100.0f, 25.0f)];
    clickChannelLabel.text = @"点击进入频道";
    clickChannelLabel.font = [UIFont systemFontOfSize:12.0f];
    clickChannelLabel.backgroundColor = [UIColor clearColor];
    clickChannelLabel.textColor = [[ThemeMgr sharedInstance] isNightmode] ? [UIColor whiteColor] : [UIColor colorWithHexString:@"999292"];
    [self.view addSubview:clickChannelLabel];

    //赋值
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    gridView.hotChannelArray = manager.visibleHotChannels;
    [gridView reloadView];
    gridView.frame = CGRectMake(0.0f, -(gridView.heightOfView - self.StateBarHeight - HotChannelItemHeight), kContentWidth, gridView.heightOfView);

    
    [self.view bringSubviewToFront:gridView];
    [self.view bringSubviewToFront:self.topBarView];
    [self.view bringSubviewToFront:headerScrollView];
    [self.view bringSubviewToFront:expandButtonBg];
    [self.view bringSubviewToFront:expandButton];
    [self.view bringSubviewToFront:topImageView];
    [self.view bringSubviewToFront:unexpandButton];
    [self.view bringSubviewToFront:allChannelsLabel];

    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         topImageView.alpha = 1.0f;
                         unexpandButton.alpha = 1.0f;
                         gridView.frame = CGRectMake(0.0f, [self StateBarHeight] + HotChannelItemHeight, kContentWidth, gridView.heightOfView);
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         allChannelsLabel.frame = CGRectMake(10.0f, self.StateBarHeight + 5.0f, 60.0f, 25.0f);
                         clickChannelLabel.frame = CGRectMake(90.0f, self.StateBarHeight + 5.0f, 100.0f, 25.0f);
                     }
                     completion:nil];*/
}

- (void)unexpandGridView:(UIButton*)button
{   
    [self unexpandGridViewWithAnimate:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    //do nothing
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(self.view.gestureRecognizers[0] == gestureRecognizer)
    {
        //先判断触摸的点的位置是否在gridview里

        if (CGRectContainsPoint(gridView.frame, [touch locationInView:self.view]) ||
            (CGRectContainsPoint(topImageView.frame, [touch locationInView:self.view])) ||
            (CGRectContainsPoint(futureWeatherView.frame, [touch locationInView:self.view])) )
        {
            //do nothing
        }
        else
        {
            [self unexpandGridViewWithAnimate:YES];
            [self hiderFutureWeather];
        }
    }
    return NO;
}

#pragma mark PhoneHotChannelGridViewDataSource methods
- (NSInteger)gridViewCurrentIndex
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    return [manager.visibleHotChannels indexOfObject:currentHotChannel];
}

#pragma mark PhoneHotChannelGridViewDelegate methods
//隐藏gridview
- (BOOL)unexpandGridViewWithAnimate:(BOOL)animate
{
    if (!gridView) {
        return NO;
    }
    
    // 刷新数据
    [hotScrollView setCurrentHotChannel:currentHotChannel];
    
    //还原其他控件的触摸操作
//    titleView.userInteractionEnabled = YES;
    hotScrollView.userInteractionEnabled = YES;
    headerScrollView.userInteractionEnabled = YES;
    if ([self.view.gestureRecognizers count] > 0) {
        [self.view removeGestureRecognizer:self.view.gestureRecognizers[0]];
    }

    
    if (!animate) {
        [topImageView removeFromSuperview];
        [unexpandButton removeFromSuperview];
        [allChannelsLabel removeFromSuperview];
        [clickChannelLabel removeFromSuperview];
        [gridView removeFromSuperview];
        topImageView = nil;
        unexpandButton = nil;
        allChannelsLabel = nil;
        clickChannelLabel = nil;
        gridView = nil;
        return YES;
    }

    [UIView animateWithDuration:0.2f animations:^{
        allChannelsLabel.frame = CGRectMake(-180.0f, self.StateBarHeight + 7.0f, 60.0f, 25.0f);
        clickChannelLabel.frame = CGRectMake(-100.0f, self.StateBarHeight + 7.0f, 100.0f, 25.0f);
    } completion:^(BOOL finished) {
        [allChannelsLabel removeFromSuperview];
        [clickChannelLabel removeFromSuperview];
        allChannelsLabel = nil;
        clickChannelLabel = nil;
    }];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         topImageView.alpha = 0.0f;
                         unexpandButton.alpha = 0.0f;
                         gridView.frame = CGRectMake(0.0f, -(gridView.heightOfView -[self StateBarHeight]- HotChannelItemHeight), kContentWidth, gridView.heightOfView);
                     }
                     completion:^(BOOL finished) {
                         [topImageView removeFromSuperview];
                         [unexpandButton removeFromSuperview];
                         [gridView removeFromSuperview];
                         topImageView = nil;
                         unexpandButton = nil;
                         gridView = nil;
                         
                         HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                         [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
                         NSUInteger index = [manager.visibleHotChannels indexOfObject:currentHotChannel];
                         [headerScrollView scrollToTheLocationWhenClickGridView:index];
                         [headerScrollView setSelectedImageWithTag:index];
                     }];
    return YES;
}

// hotchannel Grid 点击事件
- (void)gridViewItemClicked:(HotChannel *)channel
{
    // 标记新闻频道已经看过
    [[SurfFlagsManager sharedInstance] markNewsChnannelAsRead:channel];
    [self newsIsUpate];
    
    //还原其他控件的触摸操作
//    titleView.userInteractionEnabled = YES;
    hotScrollView.userInteractionEnabled = YES;
    headerScrollView.userInteractionEnabled = YES;
    [self.view removeGestureRecognizer:self.view.gestureRecognizers[0]];
    
    [UIView animateWithDuration:0.2f animations:^{
        allChannelsLabel.frame = CGRectMake(-180.0f, self.StateBarHeight + 5.0f, 60.0f, 25.0f);
        clickChannelLabel.frame = CGRectMake(-100.0f, self.StateBarHeight + 5.0f, 100.0f, 25.0f);
    } completion:^(BOOL finished) {
        [allChannelsLabel removeFromSuperview];
        [clickChannelLabel removeFromSuperview];
        allChannelsLabel = nil;
        clickChannelLabel = nil;
    }];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         topImageView.alpha = 0.0f;
                         unexpandButton.alpha = 0.0f;
                         gridView.frame = CGRectMake(0.0f, -(gridView.heightOfView -[self StateBarHeight]- HotChannelItemHeight), kContentWidth, gridView.heightOfView);
                     }
                     completion:^(BOOL finished) {
                         [topImageView removeFromSuperview];
                         [unexpandButton removeFromSuperview];
                         [gridView removeFromSuperview];
                         topImageView = nil;
                         unexpandButton = nil;
                         gridView = nil;
                         
                         HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                         [headerScrollView reloadViewWithArray:manager.visibleHotChannels controller:self];
                         NSUInteger index = [manager.visibleHotChannels indexOfObject:channel];
                         [headerScrollView scrollToTheLocationWhenClickGridView:index];
                         [headerScrollView setSelectedImageWithTag:index];
                         currentHotChannel = channel;
                         // 设置滚屏中需要显示的页面
                         [hotScrollView setCurrentHotChannel:channel];
                     }];

}

#pragma mark HotchannelScrollDelegate methods
- (void)hotchannelScrollChanged:(HotChannel*)hotchannel
{
    //滑到某个频道 就算已经看过了 也要标记为已读
    [[SurfFlagsManager sharedInstance] markNewsChnannelAsRead:hotchannel];
    [self newsIsUpate];
    
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSUInteger index = [manager.visibleHotChannels indexOfObject:hotchannel];
    manager.selectChannelIndex = (int)index;
    if (hotchannel == currentHotChannel) {//再次选择当前频道,不做操作
        return;
    }
    [headerScrollView setSelectedImageWithTag:index];
    currentHotChannel = hotchannel;
    [hotScrollView setCurrentHotChannel:hotchannel];
    
    
     // 定位到的本地频道和用户选择的本地频道不一致提示框
    if ([hotchannel isLocalChannel] &&
        ![AppSettings boolForKey:BOOLKey_LocalNewsNotMarch]) {
        
        // 检查本地频道和定位到的频道是否一致
        NSString *userSelectCity = [AppSettings stringForKey:StringKey_LocalCity];
        NSString *locationCity = [SurfLocationHelper sharedInstance].cityName;
        if(userSelectCity &&
           locationCity &&
           ![userSelectCity isEqualToString:locationCity]) {
            [AppSettings setBool:YES forKey:BOOLKey_LocalNewsNotMarch];
        
            // 显示提示框
            [self showCityNotMatchView:locationCity];
        }
        
    }
}
- (void)disapperPresentController
{
    _disappearPurpose = PhoneHotRootDisapperPurposeOpenThread;
}

- (void)headerViewScrollPercent:(CGFloat)percent
{
    [headerScrollView setSelectedViewMoveLocation:percent];
    
}

//增加财经频道顶部cell的webUrl跳转
-(void)addStockWebUrlWithTag:(stockTag)tag
{
    ThreadSummary* ts = [ThreadSummary new];
    ts.webView = 1; // 网页方式打开
    
    switch (tag) {
        case stockTagShangHai:
            ts.newsUrl = kStockShangHai;
            NSLog(@"stockTagShangHai");
            break;
        case stockTagShenZhen:
            ts.newsUrl = kStockShenZhen;
            NSLog(@"stockTagShenZhen");
            break;
        case stockTagStartup:
            ts.newsUrl = kStockStartUp;
            NSLog(@"stockTagStartup");
            break;
            
        default:
            break;
    }
    
    SNThreadViewerController * sn = [[SNThreadViewerController alloc] initWithThread:ts];
    [self presentController:sn animated:PresentAnimatedStateFromRight];
}

// 按钮旋转动画
-(void)refreshBtnRotationStart
{
    [self addRefreshBtnRotation];
}

-(void)refreshBtnRotationFinish
{
    [self removeRefreshBtnRotation];
}

// 天气控件点击事件
- (void)weatherViewClick:(id)sender
{
    // 5.0.0 and later
    ShowWeatherViewController *vc =
    [ShowWeatherViewController new];
    [self presentController:vc
                   animated:PresentAnimatedStateFromRight];
    
}

// 进入选择本地新闻城市
-(void)enterSelectLocalNewsCities
{
    _disappearPurpose = PhoneHotRootDisapperPurposeSelectLocalCityNew;
    SelectLocalCityNewsController *slcnc = [SelectLocalCityNewsController new];
    [self presentController:slcnc animated:PresentAnimatedStateFromRight];
}



-(void)hiderFutureWeather
{
    if (futureWeatherView) {
        [UIView animateWithDuration:0.08f animations:^{
            CGAffineTransform transform = futureWeatherView.transform;
            transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
            futureWeatherView.transform = transform;

        } completion:^(BOOL finished) {
            futureWeatherView.hidden = YES;
            [futureWeatherView removeFromSuperview];
            futureWeatherView = nil;
            //还原其他控件的触摸操作
//            titleView.userInteractionEnabled = YES;
            hotScrollView.userInteractionEnabled = YES;
            headerScrollView.userInteractionEnabled = YES;
            if ([self.view.gestureRecognizers count] > 0) {
                [self.view removeGestureRecognizer:self.view.gestureRecognizers[0]];
            }
            
        }];
        
    }
}

// 离线下载点击事件
-(void)offlineDownloadClick:(id)sender
{
    //TODO 离线下载
    [self unexpandGridViewWithAnimate:NO];
    
    NetworkStatusType type = [NetworkStatusDetector currentStatus];
    if (type == NSTNoWifiOrCellular || type == NSTUnknown)
    {
        [PhoneNotification autoHideWithText:@"当前没有网络连接!"];
    }
    else if(type == NST2G || type == NST3G || type == NST4G || type == NSTLTE)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"您尚未连接WiFi,选择继续将消耗您的流量,确定继续?" cancelButtonItem:
                              [RIButtonItem itemWithLabel:@"取消" action:
                               ^{
                                   
                               }] otherButtonItems:
                              [RIButtonItem itemWithLabel:@"确定" action:
                               ^{
                                   [self addTaskItem];
                               }], nil];
        [alert show];
    }
    else if(type == NSTWifi)
    {
        [self addTaskItem];
    }
}

- (void)showFlowIndicatorViewCrl
{
    [self unexpandGridViewWithAnimate:NO];
    
    [_popMenu removeFromSuperview];
    [popBgView removeFromSuperview];
    
    _popMenu = nil;
    popBgView = nil;
    
    //流量
    FlowIndicatorViewController *flowIndicatorViewCrl = [[FlowIndicatorViewController alloc] init];
    [self presentController:flowIndicatorViewCrl
                   animated:PresentAnimatedStateFromRight];
}

- (void)addTaskItem
{
    NSMutableArray *arr0 = [HotChannelsManager sharedInstance].visibleHotChannels;
    
    if (arr0 && arr0.count > 0)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if (currentHotChannel.type != 4) {
            [arr addObject:currentHotChannel];
        }
        
        for (HotChannel *hotChannel in arr0)
        {
            if (hotChannel.channelId != currentHotChannel.channelId){
                if (hotChannel.type != 4) {//视频频道不在离线下载范围内
                    [arr addObject:hotChannel];
                }
                else{
                    DJLog(@"hotChannel.type ===4");
                }
            }
        }
        
        for (HotChannel *hotChannel in arr)
        {
            HotChannelOfflineDownloadTask *hotTask = [[HotChannelOfflineDownloadTask alloc] init];
            [hotTask setHotChannel:hotChannel];
            [[OfflineDownloader sharedInstance] addDownloadTask:hotTask];
        }
    }
}

- (BOOL)isHaveHotChannelDownloadingOrPending
{
    BOOL isHave = NO;
    
    NSMutableArray *arr0 = [HotChannelsManager sharedInstance].visibleHotChannels;
    for (HotChannel *hotChannel in arr0)
    {
        if ([[OfflineDownloader sharedInstance] isHotChannelDownloadingOrPending:hotChannel])
        {
            isHave = YES;
            break;
        }
    }
    return isHave;
}

#pragma mark NightModeChangedDelegate
-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    
    if (night) {
        expandButtonBg.image = [UIImage imageNamed:@"expand_hot_gridview_shadow_night"];
       
    } else {
        expandButtonBg.image = [UIImage imageNamed:@"expand_hot_gridview_shadow"];
    }
    [headerScrollView applyTheme:night];
    [hotScrollView viewNightModeChanged:night];
    [weatherView viewNightModeChanged:night];
}

#pragma mark CityIdChangeDelegate
// 天气发生改变
- (void)NotifyCityIdChanged:(NSString*)newCityId
{
    NSString *localCityN = [AppSettings stringForKey:StringKey_LocalCity];
    // 逻辑：本地城市频道用户没有选择，就是用天气的城市来确定本地频道。
    if (!localCityN || [localCityN isEmptyOrBlank]) {
        _isLocalNewsCityChanged = YES;
        [self requestHotChannelsList];
    }
}

// 刷新按钮点击
-(void)refreshButtonClick
{
    HotChannelsView *curHotView =
    [hotScrollView curHotChannelsView];
    if ([curHotView isLoading]) {
        [PhoneNotification autoHideWithText:@"已经在努力了，请稍等"];
        return;
    }
    
    // 添加按钮旋转动画（动画会在请求结束后，自动停止）
    [self addRefreshBtnRotation];
    
    
    // 刷新当前的新闻频道
    [hotScrollView refreshCurrentChannel:nil];
}

-(void)addRefreshBtnRotation
{
    CABasicAnimation * rotationAnimation =
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 1.f;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    [refreshBtn.layer addAnimation:rotationAnimation
                            forKey:@"kRotationAnimationKey"];
}

-(void)removeRefreshBtnRotation
{
    [refreshBtn.layer removeAllAnimations];
}



#pragma mark-定位到的本地频道和用户选择的本地频道不一致提示框

/**
 *  显示本地新闻和定位新闻不一致
 */
-(void)showCityNotMatchView:(NSString*)cityName
{
    if (_localNewsNotMatch) {
        return;
    }
    
    CGRect bgR = [[UIScreen mainScreen] bounds];
    UIControl *bgCtl = [[UIControl alloc] initWithFrame:bgR];
    _localNewsNotMatch = bgCtl;
    [bgCtl addTarget:self action:@selector(removeCityView:) forControlEvents:UIControlEventTouchUpInside];
    [bgCtl setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.35]];
    [theApp.window addSubview:bgCtl];
    
    
    // subView
    NSString *title = [NSString stringWithFormat:@"您正在%@，是否阅读%@新闻?",cityName, cityName];
    
    
    CGFloat width = CGRectGetWidth(bgR);
    CGFloat height = CGRectGetHeight(bgR);
    CGFloat vW = 221.f;
    UIView *fView = [UIView new];
    fView.layer.cornerRadius = 5.f;
    fView.backgroundColor = [UIColor whiteColor];
    [bgCtl addSubview:fView];
    
    // 一个标题， 2个按钮
    CGFloat tY = 15.f;
    UILabel *titleL = [UILabel new];
    [titleL setText:title];
    titleL.backgroundColor = [UIColor clearColor];
    titleL.font = [UIFont systemFontOfSize:15.f];
    titleL.textColor = [UIColor colorWithHexValue:0xFF333333];
    titleL.numberOfLines = 0;
    CGSize tSize = [titleL sizeThatFits:CGSizeMake(vW - 30.f, 0)];
    CGFloat tX = (vW- tSize.width)/2;
    [titleL setFrame:CGRectMake(tX, tY, tSize.width, tSize.height)];
    [fView addSubview:titleL];
    
    UIColor *norColor = [UIColor colorWithHexValue:0xff999999];
    UIColor *hlColor = [UIColor colorWithHexValue:0xffd71919];
    UIFont *btnFont = [UIFont systemFontOfSize:14.f];
    // ”是“按钮
    UIButton *yesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    yesBtn.titleLabel.font = btnFont;
    [yesBtn setTitle:@"是" forState:UIControlStateNormal];
    [yesBtn setTitleColor:hlColor forState:UIControlStateNormal];
    CGSize btnSize = [yesBtn sizeThatFits:CGSizeZero];
    CGFloat btnX = vW- 15 - btnSize.width;
    CGFloat btnY = tY + tSize.height + 10.;
    [yesBtn setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
    [yesBtn addTarget:self
               action:@selector(yesBtnClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [fView addSubview:yesBtn];
    
    // "否"按钮
    UIButton *noBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noBtn.titleLabel.font = btnFont;
    [noBtn setTitle:@"否" forState:UIControlStateNormal];
    [noBtn setTitleColor:norColor forState:UIControlStateNormal];
    btnSize = [noBtn sizeThatFits:CGSizeZero];
    btnX -= (15.f+btnSize.width);
    [noBtn setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
    [noBtn addTarget:self
              action:@selector(noBtnClick:)
    forControlEvents:UIControlEventTouchUpInside];
    [fView addSubview:noBtn];
    
    CGFloat vH = btnY+btnSize.height+3;
    CGFloat x = (width - vW )/2;
    CGFloat y = (height - vH)/2;
    [fView setFrame:CGRectMake(x,y,vW,vH)];
    
}

-(void)removeCityView:(UIControl*)ctl
{
    [_localNewsNotMatch removeFromSuperview];
    _localNewsNotMatch = nil;
}
-(void)yesBtnClick:(UIButton*)btn
{
    [self removeCityView:nil];
    
    
    SurfLocationHelper *helper = [SurfLocationHelper sharedInstance];
    WeatherInfo *info = helper.locationCityWeather;
    [AppSettings setString:info.cityName forKey:StringKey_LocalCity];
    [AppSettings setString:info.cityId forKey:StringKey_LocalCityID];
    
    // 刷新当前频道
    _isLocalNewsCityChanged = YES;
    [self requestHotChannelsList];
}
-(void)noBtnClick:(UIButton*)btn
{
    [self removeCityView:nil];
    
}
@end

