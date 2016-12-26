//
//  RankingListViewController.m
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#define RANKINGBGVIEWFRMAE CGRectMake(0, super.StateBarHeight, 320, super.StateBarHeight-10)

#define RANKINGTABLEVIEWFRMAE            CGRectMake(0, super.StateBarHeight+6, 320, super.view.bounds.size.height - super.StateBarHeight - self.tabBarController.tabBar.bounds.size.height)

#import "RankingListViewController.h"
#import "AppSettings.h"
#import "RankingManager.h"
#import "DispatchUtil.h"


@interface RankingListViewController ()<UIScrollViewDelegate>{
    
    UIScrollView *_scrollV;
    UITableView *_positiveTableView;
    UITableView *_negativeTableView;
    
    NSArray *_pList;
    NSArray *_nList;
    RankingListType _rankType;
    BOOL _isPoEnergyList;
    
    // 周日切换按钮
    UIButton *_dayAndWeekSwitchBtn;
    UIButton *_dayBtn;
    UIButton *_weekBtn;
    
    // 分享
    UIView *_shareView;
    UIView *_shareBgView;
}
@end

@implementation RankingListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = shareTitle = @"能量日榜单";
    
    _rankType = kDateType;
    _isPoEnergyList = NO;
    _pList = [RankingManager sharedInstance].pRankList_day;
    _nList = [RankingManager sharedInstance].nRankList_day;
    
    
    // 主界面
    float segmentH = 50.f;
    float w = CGRectGetWidth(self.view.bounds);
    float h = CGRectGetHeight(self.view.bounds);
    float scrollH = h-self.StateBarHeight-segmentH;
    CGRect sv = CGRectMake(0, self.StateBarHeight+ segmentH, w, scrollH);
    
    _scrollV = [[UIScrollView alloc] initWithFrame:sv];
    [_scrollV setBounces:YES];
    [_scrollV setDelegate:self];
    [_scrollV setPagingEnabled:YES];
    _scrollV.showsHorizontalScrollIndicator = NO;
    _scrollV.showsVerticalScrollIndicator = NO;
    [_scrollV setContentSize:CGSizeMake(w+w, scrollH)];
    [_scrollV setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_scrollV];
    {
        CGRect nRect = _scrollV.bounds;
        _negativeTableView = [[UITableView alloc] initWithFrame:nRect style:UITableViewStylePlain];
        [_negativeTableView setDelegate:self];
        [_negativeTableView setDataSource:self];
        [_negativeTableView setBackgroundColor:[UIColor clearColor]];
        [_negativeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_scrollV addSubview:_negativeTableView];
        
        CGRect pR =  CGRectOffset(nRect, w, 0);
        _positiveTableView = [[UITableView alloc] initWithFrame:pR style:UITableViewStylePlain];
        [_positiveTableView setDelegate:self];
        [_positiveTableView setDataSource:self];
        [_positiveTableView setBackgroundColor:[UIColor clearColor]];
       [_positiveTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _positiveTableView.separatorColor = [UIColor clearColor];
        [_scrollV addSubview:_positiveTableView];
        
        
        
        UIColor *nTabSepC = ([_nList count] > 0)?[UIColor colorWithHexValue:0xffe3e2e2]:[UIColor clearColor];
        UIColor *pTabSepC = ([_pList count] > 0)?[UIColor colorWithHexValue:0xffe3e2e2]:[UIColor clearColor];
        _negativeTableView.separatorColor = nTabSepC;
        _positiveTableView.separatorColor = pTabSepC;
    }
    
    [self initDayWeekButton];     //初始化 榜单切换控件
    
     // 关闭了分享按钮，需要时可以打开，在榜单标题的右侧
//    [self initShareButton];
    
    [self initSegmentControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    RankingManager *rm = [RankingManager sharedInstance];
    if ([rm calcRefreshDateInterval:YES] >1) {
        [self refreshRankingInfo:_rankType];
    }
    
    // 隐藏周和日按钮
    [self showDayBtnAndWeekBtn:NO];
}

- (void)addActivityIndicator{
    //indicator
    if (!mActivityIndicator) {
        UIActivityIndicatorViewStyle style = [[ThemeMgr sharedInstance] isNightmode] ? UIActivityIndicatorViewStyleWhite: UIActivityIndicatorViewStyleGray;
        mActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
        [mActivityIndicator setFrame:CGRectMake(0, 0, 30, 30)];
        [mActivityIndicator setCenter:self.view.center];
        [mActivityIndicator startAnimating];
        [self.view addSubview:mActivityIndicator];
    }
}
-(void)removeActivityIndicator
{
    if (mActivityIndicator) {
        [mActivityIndicator stopAnimating];
        [mActivityIndicator removeFromSuperview];
        mActivityIndicator = nil;
    }
}

//分享按钮
- (void)initShareButton
{
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(272.0f, super.StateBarHeight - 49.0f, 48.0f, 48.0f);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_unselected.png"]
                        forState:UIControlStateNormal];
    [shareBtn addTarget:self
                 action:@selector(didshare)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
}

- (void)initDayWeekButton
{
    if (!_dayAndWeekSwitchBtn) {
        _dayAndWeekSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dayAndWeekSwitchBtn.frame = CGRectMake(260.0f, self.view.frame.size.height-90.0f, 45.0f, 45.0f);
        UIImage *addImg = [[ThemeMgr sharedInstance] isNightmode]?[UIImage imageNamed:@"addBtn_night.png"]: [UIImage imageNamed:@"addBtn.png"];
        [_dayAndWeekSwitchBtn setBackgroundImage:addImg
                             forState:UIControlStateNormal];
        [_dayAndWeekSwitchBtn addTarget:self
                                 action:@selector(dayAndWeekSwitchBtnHandler:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dayAndWeekSwitchBtn];
    }
}

-(void)chickRefreshRankingInfo:(RankingListType)type
{
    BOOL isDayR = type == kDateType ? YES : NO;
    RankingManager *rm = [RankingManager sharedInstance];
    if ([rm calcRefreshDateInterval:isDayR] > (isDayR?1:12)) {
        [self refreshRankingInfo:type];
    }
    else{
        _nList = nil;
        _pList = nil;
        [_negativeTableView reloadData];
        [_positiveTableView reloadData];
        _negativeTableView.separatorColor = [UIColor clearColor];
        _positiveTableView.separatorColor = [UIColor clearColor];

        // 显示风火轮
        [self addActivityIndicator];
        
        [DispatchUtil dispatch:^{
            RankingManager *rm = [RankingManager sharedInstance];
            UIColor *separatorColor = [UIColor colorWithHexString:@"e3e2e2"];
            if (isDayR) {
                _nList = rm.nRankList_day;
                _pList = rm.pRankList_day;
            }
            else {
                _nList = rm.nRankList_week;
                _pList = rm.pRankList_week;
            }
            
            if ([_nList count] > 0) {
                [_negativeTableView reloadData];
                _negativeTableView.separatorColor = separatorColor;
            }
            if ([_pList count] > 0) {
                [_positiveTableView reloadData];
                _positiveTableView.separatorColor = separatorColor;
            }
            
            // 隐藏风火轮
            [self removeActivityIndicator];
        } after:2];
    }
}


-(void)refreshRankingInfo:(RankingListType)type
{
    _pList = _nList = nil;
    [_negativeTableView reloadData];
    [_positiveTableView reloadData];
    _negativeTableView.separatorColor = [UIColor clearColor];
    _positiveTableView.separatorColor = [UIColor clearColor];
    
    
    // 显示风火轮
    [self addActivityIndicator];
    RankingManager *rm = [RankingManager sharedInstance];
    [rm refreshRankingInfo:type withCompletionHandler:^(BOOL succeed, RankingInfoResponse *res) {
        if (succeed) {
            _pList = res.positiveNews;
            _nList = res.negativeNews;
            UIColor *separatorColor = [UIColor colorWithHexString:@"e3e2e2"];
            
            NSInteger subViewIdx = [self subViewIdxOfScrollView:_scrollV];
            if (subViewIdx == 0) {
                if ([_nList count] > 0) {
                    [_negativeTableView reloadData];
                    _negativeTableView.separatorColor = separatorColor;
                }
                
                [DispatchUtil dispatch:^{
                    if ([_pList count] > 0) {
                        [_positiveTableView reloadData];
                        _positiveTableView.separatorColor = separatorColor;
                    }
                } after:1];
            }
            else {
                if ([_pList count] > 0) {
                    [_positiveTableView reloadData];
                    _positiveTableView.separatorColor = separatorColor;
                }
                [DispatchUtil dispatch:^{
                    if ([_nList count] > 0) {
                        [_negativeTableView reloadData];
                        _negativeTableView.separatorColor = separatorColor;
                    }
                } after:1];
            }
        }
        else {
            [PhoneNotification autoHideWithText:@"更新失败，网络异常!"];
            
            
            // 显示一个刷新按钮
            //TODO:
        }
        
        // 隐藏风火轮
        [self removeActivityIndicator];
    }];
}


-(void)hideActivityIndicator
{
    [mActivityIndicator stopAnimating];
}


#pragma mark rankingListTableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _positiveTableView) {
        return [_pList count];
    }
    else{
        return [_nList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RankingListCell *cell = nil;
    NSString *cellid;
    RankingNews *rn = nil;
    NSInteger index = indexPath.row;
    if (tableView == _positiveTableView) {
        cellid = @"RankingCellPo";
        cell = (RankingListCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
        
        if (index < [_pList count]) {
            rn = [_pList objectAtIndex:index];
        }
    }
    else if(tableView == _negativeTableView) {
        cellid = @"RankingCellNe";
        cell = (RankingListCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
        
        if (index < [_nList count]) {
            rn = [_nList objectAtIndex:index];
        }
    }
    
    if (!cell)
    {
        cell = [[RankingListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
   
    if (rn) {
        [cell loadDataWithRankingNews:rn atIndex:index+1];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ThreadSummary *ts = nil;
    NSInteger idx = indexPath.row;
    RankingNews *positive = nil;
    if (_isPoEnergyList) {
        positive = [_pList objectAtIndex:idx];
    }
    else{
        positive = [_nList objectAtIndex:idx];
    }

    ts = [positive getThread];

    SNThreadViewerController* vv = [[SNThreadViewerController alloc] initWithThread:ts];
    [self presentController:vv animated:PresentAnimatedStateFromRight];
}

#pragma mark - UISegmentControl

- (void)initSegmentControl
{
    /*************分段控件UISegmentdControl*************/
    
    //初始化UISegmentedControl
    CGRect segmentR = CGRectMake(60.0, super.StateBarHeight+12.0, 200.0, 30.0);
    segmentedControl = [[UISegmentedControl alloc] initWithFrame:segmentR];
    [segmentedControl insertSegmentWithTitle:@"负能量" atIndex:0 animated:NO];
    [segmentedControl insertSegmentWithTitle:@"正能量" atIndex:1 animated:NO];
    
    //设置默认选择项索引
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}

//SegmentedControl触发的动作
-(void)controlPressed:(id)sender
{
    UISegmentedControl *sc = sender;
    NSInteger scIdx = sc.selectedSegmentIndex;
    NSInteger scrollIdx = [self subViewIdxOfScrollView:_scrollV];
    
    if (scIdx != scrollIdx) {
        float sw = CGRectGetWidth(_scrollV.bounds);
        [_scrollV setContentOffset:CGPointMake(scIdx * sw, 0)
                          animated:YES];
        
        BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
        UIColor *color = [UIColor colorWithHexString:isN?@"F8F8F8":@"352d29"];
        sc.tintColor = (scIdx == 1)?[UIColor colorWithHexString:@"ad2f2f"]:color;
        _isPoEnergyList = (scIdx == 1) ? YES : NO;
    }
}

#pragma mark - NightModeChangedDelegate
-(void)nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
    
    [[_positiveTableView visibleCells] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    [[_negativeTableView visibleCells] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    

    if (night) {
        [_dayAndWeekSwitchBtn setBackgroundImage:[UIImage imageNamed:@"addBtn_night.png"] forState:UIControlStateNormal];
    }
    else {
        [_dayAndWeekSwitchBtn setBackgroundImage:[UIImage imageNamed:@"addBtn.png"] forState:UIControlStateNormal];
    }
    
    NSInteger colorV = 0xffad2f2f;
    if (segmentedControl.selectedSegmentIndex == 0) {
        colorV = night?0xffF8F8F8:0xff352d29;
    }
    segmentedControl.tintColor = [UIColor colorWithHexValue:colorV];
}



#pragma mark - Btn Selected
//分享按钮
- (void)didshare{
    [self showShareView];
}

-(void)showShareView
{
    if (!_shareView) {
        
        _shareView = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_shareView];
        
        _shareBgView = [[UIView alloc]initWithFrame:self.view.bounds];
        [_shareBgView setBackgroundColor:[UIColor blackColor]];
        _shareBgView.alpha = 0.6f;
        [_shareView addSubview:_shareBgView];
        
        float shareW = 200.f;
        float shareH = 230.f;
        float w = CGRectGetWidth(self.view.bounds);
        float h = CGRectGetHeight(self.view.bounds);
        float shareX = (w-shareW)/2;
        float shareY = (h-shareH)/2;
        CGRect shareR = CGRectMake(shareX, shareY, shareW, shareH);
        ShareView_Ranking *rankShare = [[ShareView_Ranking alloc] initWithFrame:shareR];
        rankShare.delegate = self;
        [rankShare setBackgroundColor:[UIColor whiteColor]];
        [_shareView addSubview:rankShare];

    }
}
-(void)hidderShareView
{
    [_shareView removeFromSuperview];
    [[_shareView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    _shareView = nil;
}



- (void)dayAndWeekSwitchBtnHandler:(id)sender
{
    UIButton *btn = sender;
    [self showDayBtnAndWeekBtn:(btn.tag == 0)?YES:NO];
}

-(void)showDayBtnAndWeekBtn:(BOOL)isShow
{
    if (isShow) {
        _dayAndWeekSwitchBtn.tag = 1;
        UIImage *cancelImg = [[ThemeMgr sharedInstance] isNightmode]?[UIImage imageNamed:@"cancel_night.png"]:[UIImage imageNamed:@"cancel.png"];
        [_dayAndWeekSwitchBtn setBackgroundImage:cancelImg forState:UIControlStateNormal];
        
        if (!_dayBtn) {
            //日榜单
            _dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _dayBtn.frame = CGRectMake(0, 0, 40.0f, 40.0f);
            _dayBtn.center = _dayAndWeekSwitchBtn.center;
            _dayBtn.alpha = 0.2f;
            [_dayBtn addTarget:self
                        action:@selector(dayButtonClick:)
                 forControlEvents:UIControlEventTouchUpInside];
            [_dayBtn setTitle:@"日榜单" forState:UIControlStateNormal];
            _dayBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.view addSubview:_dayBtn];
        }
        
        
        if (!_weekBtn) {
            //周榜单
            _weekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _weekBtn.frame = CGRectMake(0, 0, 40.0f, 40.0f);
            _weekBtn.center = _dayAndWeekSwitchBtn.center;
            _weekBtn.alpha = 0.2f;
            [_weekBtn addTarget:self
                         action:@selector(weekButtonClick:)
                 forControlEvents:UIControlEventTouchUpInside];
            [_weekBtn setTitle:@"周榜单" forState:UIControlStateNormal];
            _weekBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.view addSubview:_weekBtn];
        }
        [self refreshDayBtnAndWeekBtnState]; // 刷新按钮状态
        
        // 显示动画
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float oldX = _dayAndWeekSwitchBtn.center.x;
            float oldY = _dayAndWeekSwitchBtn.center.y;
            _dayBtn.center = CGPointMake(oldX-45.f, oldY - 50.f);
            _weekBtn.center = CGPointMake(oldX-60, oldY);
            _dayBtn.alpha = 1.f;
            _weekBtn.alpha = 1.f;
        } completion:nil];
    }
    else{
        if (_dayBtn) {
            [_dayBtn removeFromSuperview];
            [_weekBtn removeFromSuperview];
            _dayBtn = _weekBtn = nil;
        }
        
        if (_dayAndWeekSwitchBtn.tag != 0){
            _dayAndWeekSwitchBtn.tag = 0;
            UIImage *addImg = [[ThemeMgr sharedInstance] isNightmode]?[UIImage imageNamed:@"addBtn_night.png"]: [UIImage imageNamed:@"addBtn.png"];
            [_dayAndWeekSwitchBtn setBackgroundImage:addImg forState:UIControlStateNormal];
        }
    }
}

-(void)refreshDayBtnAndWeekBtnState
{
    UIImage *sel = [[ThemeMgr sharedInstance] isNightmode]?[UIImage imageNamed:@"selected.png"]: [UIImage imageNamed:@"selected.png"];
    UIImage *unSel = [[ThemeMgr sharedInstance] isNightmode]?[UIImage imageNamed:@"unselected_night.png"]: [UIImage imageNamed:@"unselected.png"];
    UIColor *selC = [UIColor whiteColor];
    UIColor *unSelC = [UIColor colorWithHexValue:0xff3c3c3c];
    
    if (_rankType == kDateType) {
        [_dayBtn setTitleColor:selC
                      forState:UIControlStateNormal];
        [_dayBtn setBackgroundImage:sel
                           forState:UIControlStateNormal];
        
        [_weekBtn setBackgroundImage:unSel
                            forState:UIControlStateNormal];
        [_weekBtn setTitleColor:unSelC
                       forState:UIControlStateNormal];
    }
    else{
        [_dayBtn setTitleColor:unSelC
                      forState:UIControlStateNormal];
        [_dayBtn setBackgroundImage:unSel
                           forState:UIControlStateNormal];
        
        [_weekBtn setBackgroundImage:sel
                            forState:UIControlStateNormal];
        [_weekBtn setTitleColor:selC
                       forState:UIControlStateNormal];
    }
}

- (void)dayButtonClick:(id)sender
{
    self.title = @"能量日榜单";
    shareTitle = @"能量日榜单";
    if (_rankType != kDateType) {
        _rankType = kDateType;
        
        // 刷新安装状态
        [self refreshDayBtnAndWeekBtnState];
        // 检查是否刷新
        [self chickRefreshRankingInfo:_rankType];
    }
}

- (void)weekButtonClick:(id)sender
{
    self.title = @"能量周榜单";
    shareTitle = @"能量周榜单";
    if (_rankType != kWeekType) {
        _rankType = kWeekType;
        
        // 刷新安装状态
        [self refreshDayBtnAndWeekBtnState];
        
        // 检查是否刷新
        [self chickRefreshRankingInfo:_rankType];
    }
}

#pragma mark-- RankingShareCtlDelegate

- (void)shareMenuSelected:(ShareWeiboType)type;
{
    [self hidderShareView];
    [self shareWeibo:type];
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
    }
    else if (type == ChinaMobielOAuth) {
        NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

//跳转到授权界面
- (void)oauthWebViewController:(OAuthClientType)type
{
//    [theApp.oauthWebViewController setOAuthClientType:type];
//    theApp.oauthWebViewController.delegate = self;
//    UIViewController *vc = [theApp topMostVC];
//    [vc presentViewController:theApp.oauthWebViewController
//                     animated:YES completion:nil];
}

// 到这个函数，微博授权以及通过，进入微博编辑界面
- (void)entryWeiboEditeView:(ShareWeiboType)type{
    
    // 获取微博编辑界面需要的参数
    best = [[RankingManager sharedInstance] getBestPositive:_rankType];
    worst = [[RankingManager sharedInstance] getWorstNegative:_rankType];
    
    NSString *title = [NSString stringWithFormat:@"【%@】走进新闻背后的能量世界",shareTitle];
    NSString *desc = [NSString stringWithFormat:@" 最具正能量情怀新闻 %@ 最具负能量情怀新闻 %@",best.title, worst.title];
    
    NSString *text = [NSString stringWithFormat:@"【%@】走进新闻背后的能量世界 最具正能量情怀新闻 %@ 最具负能量情怀新闻 %@",shareTitle, best.title, worst.title];
    
    //分享的URL修改 modify by JSG
    NSString *shareUrl = @"http://go.10086.cn/lucky.do?method=energyRank&rankType=0&energyType=0&from=timeline&isappinstalled=1&sso_command=checkLogin&sso_cl_key=6GLRGHH0";
    
    UIImage *shareImg = nil;
    
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    switch (idx) {
        case 0:
            //shareImg = [UIImage imageNamed:@"negative_energy_News.png"];
            shareImg = [UIImage imageNamed:@"energy_logo.png"];
            break;
        case 1:
            //shareImg = [UIImage imageNamed:@"good_icon.png"];
            shareImg = [UIImage imageNamed:@"energy_logo.png"];
            break;
        default:
            break;
    }
    
    if (type == ItemWeixin) {
        [theApp sendWeixin:title description:desc
                   newsUrl:shareUrl
                shareImage:shareImg scene:WXSceneSession];
    }
    else if (type == ItemWeiXinFriendZone) {
        [theApp sendWeixin:title description:desc
                   newsUrl:shareUrl
                shareImage:shareImg scene:WXSceneTimeline];
    }
    else if (type == ItemSinaWeibo) {
        ContentShareController *csc = [ContentShareController new];
        [csc setTitle:@"分享到新浪微博"];
        
        ContentShareView* view = [csc curShareView];
        [view setShareWordText:text];
        [view remainlab:text];
        [view setShareMode:SinaWeibo];
        [view setShareAds:shareUrl];
        [view setShareNewsAds:shareUrl];
        [view setShareStr:text];
        
        [csc clearButtonOnToolsBar];
        
        PhoneSurfController *vc = (PhoneSurfController*)[theApp topMostVC];
        [vc presentController:csc animated:PresentAnimatedStateFromRight];
    }
}

// 分享微博(这里是从选择微博View接受到的通知)
- (void)shareWeibo:(ShareWeiboType)type
{
    // 微博授权判断
    if (type == ItemSinaWeibo) {
        if (![self isOAuthed:SinaOAuth]) {
            [self oauthWebViewController:SinaOAuth];
            return;
        }
    }
    else if (type == ItemSMS) {
        // 短信分享
        
        // 获取微博编辑界面需要的参数
        best = [[RankingManager sharedInstance] getBestPositive:_rankType];
        worst = [[RankingManager sharedInstance] getWorstNegative:_rankType];
        
        NSString *text = [NSString stringWithFormat:@"【%@】走进新闻背后的能量世界 最具正能量情怀新闻 %@ 最具负能量情怀新闻 %@",shareTitle, best.title, worst.title];
        
        if ([MFMessageComposeViewController canSendText]) {
            theApp.nightModeShadow.hidden = YES;
            MFMessageComposeViewController *messageCtrll = [MFMessageComposeViewController new];
            messageCtrll.body = [NSString stringWithFormat:@"%@ %@", text, best.newsUrl];
//            messageCtrll.messageComposeDelegate = self;
            [self presentViewController:messageCtrll
                               animated:YES completion:nil];
            
        }
        return;
    }
    
    // 进入微博编写窗口
    [self entryWeiboEditeView:type];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showDayBtnAndWeekBtn:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollV == scrollView) {
        NSInteger viewIdx = [self subViewIdxOfScrollView:scrollView];
        _isPoEnergyList = (viewIdx == 1) ? YES : NO;
        
        
        segmentedControl.selectedSegmentIndex = viewIdx;
        UIColor *segmentTintColor = nil;
        if (viewIdx == 1) {
            segmentTintColor = [UIColor colorWithHexValue:0xffad2f2f];
        }
        else {
            if ([[ThemeMgr sharedInstance] isNightmode]) {
                segmentTintColor = [UIColor colorWithHexValue:0xffF8F8F8];
            }
            else {
                segmentTintColor = [UIColor colorWithHexValue:0xff352d29];
            }
        }
        segmentedControl.tintColor = segmentTintColor;
    }
}

-(NSInteger)subViewIdxOfScrollView:(UIScrollView *)sV
{
    CGFloat w = CGRectGetWidth([sV bounds]);
    return floor((sV.contentOffset.x - w / 2) / w) + 1;
}

#pragma mark TouchShareView methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches]anyObject];
    if ([touch view] == _shareBgView) {
        CGPoint tp =  [touch locationInView:_shareBgView];
        CGRect rect = [_shareBgView bounds];
        if (CGRectContainsPoint(rect, tp)) {
            [self hidderShareView];
        }
    }
}
@end
