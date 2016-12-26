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

@interface RankingListViewController (){
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
        [self registerNotification];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    self.title = @"能量日榜单";
    
    addBtn = NO;
    
    [self addActivityIndicator];
    
    [self refreshRankingInfo:DateType];
    
    [self initRankingListTableView]; //初始化新闻列表
    
    [self initSwitchRankingView];
    
    [self initShareCtl];    //初始化分享
    
    [self initDateCtl];  //初始化 榜单切换控件
    
    [self addBottomToolsBar];
    
    [self showActivityIndicator];
    
    [self addSwipeGesture];
}

- (void)addSwipeGesture{

    leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];

}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    NSInteger Index = segmentedControl.selectedSegmentIndex;
    //向左划
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {


        switch (Index) {
            case 0:
                //负能量
                break;
            case 1:
                //正能量
                [self addMyRankingList:[RankingManager sharedInstance].rankingList_negative];
                [rankingListTableView reloadData];
                segmentedControl.selectedSegmentIndex = 0;
                break;
                
            default:
                break;
        }

    }
    //向右划
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        switch (Index) {
            case 0:
                //正能量
                [self addMyRankingList:[RankingManager sharedInstance].rankingList_positive];
                [rankingListTableView reloadData];
                segmentedControl.selectedSegmentIndex = 1;
                break;
            case 1:
                //正能量
                break;
            default:
                break;
        }

    }
}

- (void)addActivityIndicator{
    //indicator
    
    UIActivityIndicatorView* indi = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    float w = (self.view.bounds.size.width - self.view.bounds.origin.x)/2 - 20;
    float h = (self.view.bounds.size.height -self.view.bounds.origin.y)/2 - 20;
    float aW = 30.0f;
    float aH = 30.0f;
    [indi setFrame:CGRectMake(w, h, aW, aH)];
    mActivityIndicator = indi;

    [self.view addSubview:mActivityIndicator];
    
}

- (void)initSwitchRankingView{
    SwitchRankingBgView = [[UIView alloc] initWithFrame:RANKINGBGVIEWFRMAE];
    [self.view addSubview:SwitchRankingBgView];
    
    [self addSegmentControl];
}

- (void)initRankingListTableView{

    //初始化
    if (rankingListTableView == nil && my_rankingList == nil)
    {
        //创建榜单列表
        rankingListTableView = [[UITableView alloc] initWithFrame:RANKINGTABLEVIEWFRMAE style:UITableViewStyleGrouped];
        [rankingListTableView setDelegate:self];
        [rankingListTableView setDataSource:self];
        [rankingListTableView setBackgroundColor:[UIColor clearColor]];
        rankingListTableView.backgroundView = nil;
        [rankingListTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        rankingListTableView.separatorColor = [UIColor hexChangeFloat:@"e3e2e2"];
        rankingListTableView.scrollEnabled = YES;
        
        //默认是负能量榜单
        [self addMyRankingList:[RankingManager sharedInstance].rankingList_negative];

        [self.view addSubview:rankingListTableView];
    }
    else if ([my_rankingList count] == 0){
        //返回数据为0
        if (rankingListTableView) {
            [rankingListTableView removeFromSuperview];
        }
    }
    else
    {
        [rankingListTableView reloadData];
    }

}

- (void)addMyRankingList:(NSMutableArray*)arr{
    
    if (!my_rankingList) {
        my_rankingList = [[NSMutableArray alloc] init];
    }
    else{
        [my_rankingList removeAllObjects];
    }

    for (int idx = 0; idx < [arr count]; idx++) {
        id obj = [arr objectAtIndex:idx];
        [my_rankingList addObject:obj];
    }
    [rankingListTableView reloadData];
}


- (void)initShareCtl{
    //分享按钮
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(275.0f, super.StateBarHeight - 45.0f, 30.0f, 30.0f);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_unselected.png"]
                          forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_selected.png"]
                        forState:UIControlStateHighlighted];
    [shareBtn addTarget:self
                   action:@selector(didshare)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
}

- (void)initDateCtl{
    
    if (!addBtn) {
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(265.0f, 470.0f, 45.0f, 45.0f);
        [addButton setBackgroundImage:[UIImage imageNamed:@"addBtn.png"]
                                forState:UIControlStateNormal];
        [addButton addTarget:self
                         action:@selector(didAdd)
               forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addButton];
    }

}

-(void)refreshRankingInfo:(RankingType)type{
    [[RankingManager sharedInstance] refreshRankingInfo:type];
}

-(void)showActivityIndicator
{
    [mActivityIndicator startAnimating];
}

-(void)hideActivityIndicator
{
    [mActivityIndicator stopAnimating];
}


//注册通知
- (void)registerNotification
{
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(rankingListInfoCallBack) name:@"rankingListInfoCallBack" object:nil];
    //消息：stockInfoCallBack
}

- (void)rankingListInfoCallBack{
    if ([RankingManager sharedInstance].rankingListInfoCallBack) {
        
        [self hideActivityIndicator];
        NSInteger rankingStyle = segmentedControl.selectedSegmentIndex;
        if (rankingStyle == 0) {
            //负能量
            
            [self addMyRankingList:[RankingManager sharedInstance].rankingList_negative];
            [rankingListTableView reloadData];
        }
        else if (rankingStyle == 1){
            //正能量
            [self addMyRankingList:[RankingManager sharedInstance].rankingList_positive];
            [rankingListTableView reloadData];
        }
        
        if (dateButton.selected) {
            self.title = @"能量日榜单";
        }
        if (weekButton.selected) {
            self.title = @"能量周榜单";
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark rankingListTableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [my_rankingList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * cellid = [NSString stringWithFormat:@"cell%d%d", indexPath.section, indexPath.row];
    
    RankingListCell * cell = (RankingListCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (!cell)
    {
        cell = [[RankingListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell.textLabel setTextColor:[UIColor colorWithHexValue:0xFFAD2F2F]];
    }
    
    if ([my_rankingList count] > 0) {
        NSInteger index = indexPath.row;
        positiveNews *positive = [my_rankingList objectAtIndex:index];
        [cell.indexLabel setText:positive.seqId];
        [cell.titleLabel setText:positive.title];
        [cell.soureLabel setText:positive.source];
        
        //热点图片
        UIImage *iconImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:positive.iconPath]]];
        
        [cell.typeImgView setImage:iconImage];

        if ([positive.seqUpdate intValue] > 0) {
            [cell.statusImgView setImage:[UIImage imageNamed:@"up_arrow.png"]];
        }
        else if([positive.seqUpdate intValue] == 0){
            [cell.statusImgView setImage:[UIImage imageNamed:@"equal_arrow.png"]];
        }
        else if([positive.seqUpdate intValue] < 0){
            [cell.statusImgView setImage:[UIImage imageNamed:@"down_arrow.png"]];
        }

        [cell.countLabel setText:positive.positive_count];
        [cell.energyLabel setText:positive.positive_energy];
    }
    
    [self isNightView:cell];
    
    
    [cell.textLabel setFrame:CGRectMake(30.0f, 0.0f, 300.0f, 51.0f)];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger idx = indexPath.row;
    positiveNews *positive = [my_rankingList objectAtIndex:idx];
    
    ThreadSummary* ts = [ThreadSummary new];
    ts.newsUrl = positive.newsUrl;
    ts.open_type = 1;
    ts.type = 1;
    SNThreadViewerController* sn = [[SNThreadViewerController alloc] initWithThread:ts];
    [self presentController:sn animated:PresentAnimatedStateFromRight];
}

#pragma mark - UISegmentControl

- (void)addSegmentControl{
    
    /*************分段控件UISegmentdControl*************/
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"负能量",@"正能量",nil];
    
    //初始化UISegmentedControl
    
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    
    segmentedControl.frame = CGRectMake(60.0, super.StateBarHeight+12.0, 200.0, 30.0);
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    //设置默认选择项索引
    segmentedControl.selectedSegmentIndex = 0;
    
    segmentedControl.tintColor = [UIColor hexChangeFloat:@"ad2f2f"];
    [self.view addSubview:segmentedControl];

    
    [segmentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
}

//SegmentedControl触发的动作
-(void)controlPressed:(id)sender{
    
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSInteger Index = control.selectedSegmentIndex;
    switch (Index) {
        case 0:
            //负能量
            [self addMyRankingList:[RankingManager sharedInstance].rankingList_negative];
            [rankingListTableView reloadData];
            break;
        case 1:
            //正能量
            [self addMyRankingList:[RankingManager sharedInstance].rankingList_positive];
            [rankingListTableView reloadData];
            break;
            
        default:
            break;
    }
    
}



- (void)isNightView:(UITableViewCell *)cell
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    
    if (isNight)
    {
        [SwitchRankingBgView setBackgroundColor:[UIColor hexChangeFloat:@"2D2E2F"]];
        [rankingListTableView setBackgroundColor:[UIColor hexChangeFloat:@"2D2E2F"]];
        [cell setBackgroundColor:[UIColor colorWithRed:27/255.0f green:27/255.0f blue:28/255.0f alpha:1]];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor hexChangeColor:kTableCellSelectedColor_N]];
        [cell.textLabel setTextColor:[UIColor hexChangeFloat:@"ad2f2f"]];
        
        [addButton setBackgroundImage:[UIImage imageNamed:@"addBtn_night.png"]
                             forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_night.png"] forState:UIControlStateNormal];
        mActivityIndicator.activityIndicatorViewStyle  = isNight ? UIActivityIndicatorViewStyleWhite:UIActivityIndicatorViewStyleGray;
    }
    else
    {
        [SwitchRankingBgView setBackgroundColor:[UIColor hexChangeFloat:@"F8F8F8"]];
        [rankingListTableView setBackgroundColor:[UIColor hexChangeFloat:@"F8F8F8"]];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectedBackgroundView.backgroundColor = [UIColor hexChangeColor:kTableCellSelectedColor];
        [cell.textLabel setTextColor:[UIColor hexChangeFloat:@"ad2f2f"]];
        
        [addButton setBackgroundImage:[UIImage imageNamed:@"addBtn.png"]
                             forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];

    }
}

#pragma mark - NightModeChangedDelegate
-(void)nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
}

#pragma mark - Btn Selected
- (void)didshare{
    RankingShare = [[RankingShareCtl alloc] init];
    RankingShare.delegate = self;
    [self presentController:RankingShare animated:PresentAnimatedStateNone];
}


- (void)didAdd
{
    [addButton removeFromSuperview];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(265.0f, 470.0f, 45.0f, 45.0f);
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel.png"]
                           forState:UIControlStateNormal];
    [cancelButton addTarget:self
                    action:@selector(didCancel)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    //日榜单
    dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.frame = CGRectMake(240.0f, 430.0f, 40.0f, 40.0f);
    [dateButton setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                          forState:UIControlStateNormal];
    [dateButton addTarget:self
                   action:@selector(didDate)
         forControlEvents:UIControlEventTouchUpInside];
    [dateButton setTitle:@"日榜单" forState:UIControlStateNormal];
     dateButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [dateButton setTitleColor:[UIColor hexChangeFloat:@"ffffff"]
                     forState:UIControlStateNormal];
    [self.view addSubview:dateButton];
    
    //周榜单
    weekButton = [UIButton buttonWithType:UIButtonTypeCustom];
    weekButton.frame = CGRectMake(220.0f, 470.0f, 40.0f, 40.0f);
    [weekButton setBackgroundImage:[UIImage imageNamed:@"unselected.png"]
                           forState:UIControlStateNormal];
    [weekButton addTarget:self
                    action:@selector(didWeek)
          forControlEvents:UIControlEventTouchUpInside];
    [weekButton setTitle:@"周榜单" forState:UIControlStateNormal];
    weekButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [weekButton setTitleColor:[UIColor hexChangeFloat:@"3c3c3c"]
                     forState:UIControlStateNormal];
    [self.view addSubview:weekButton];
    
}

- (void)didCancel{
    
    [cancelButton removeFromSuperview];
    [dateButton removeFromSuperview];
    [weekButton removeFromSuperview];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(265.0f, 470.0f, 45.0f, 45.0f);
    [addButton setBackgroundImage:[UIImage imageNamed:@"addBtn.png"]
                         forState:UIControlStateNormal];
    [addButton addTarget:self
                  action:@selector(didAdd)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    

}

- (void)didDate{
    [dateButton setTitleColor:[UIColor hexChangeFloat:@"ffffff"]
                     forState:UIControlStateNormal];
    [weekButton setTitleColor:[UIColor hexChangeFloat:@"3c3c3c"]
                     forState:UIControlStateNormal];
    [dateButton setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                          forState:UIControlStateNormal];
    [weekButton setBackgroundImage:[UIImage imageNamed:@"unselected.png"]
                          forState:UIControlStateNormal];
    
    [[RankingManager sharedInstance] refreshRankingInfo:DateType];
}

- (void)didWeek{
    [dateButton setTitleColor:[UIColor hexChangeFloat:@"3c3c3c"]
                     forState:UIControlStateNormal];
    [weekButton setTitleColor:[UIColor hexChangeFloat:@"ffffff"]
                     forState:UIControlStateNormal];
    
    [dateButton setBackgroundImage:[UIImage imageNamed:@"unselected.png"]
                          forState:UIControlStateNormal];
    [weekButton setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                          forState:UIControlStateNormal];
    
    [[RankingManager sharedInstance] refreshRankingInfo:WeekType];
}

#pragma mark-- RankingShareCtlDelegate

- (void)dissmissViewCtl{
    [self dismissBackController];
}

- (void)shareMenuSelected:(ShareWeiboType)type;
{
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
    else if (type == TencentOAuth) {
        NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
        if ([tencentDict valueForKey:@"access_token"]) {
            return YES;
        } else {
            return NO;
        }
    }
    else if (type == RenRenOAuth) {
        NSDictionary *renrenDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
        if ([renrenDict valueForKey:@"access_token"]) {
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
    [theApp.oauthWebViewController setOAuthClientType:type];
    theApp.oauthWebViewController.delegate = self;
    UIViewController *vc = [theApp topMostVC];
    [vc presentModalViewController:theApp.oauthWebViewController animated:YES];
}

// 到这个函数，微博授权以及通过，进入微博编辑界面
- (void)entryWeiboEditeView:(ShareWeiboType)type{
    // 获取微博编辑界面需要的参数
    
    positiveNews *best = [[RankingManager sharedInstance] getBestPositive];
    negativeNews *worst = [[RankingManager sharedInstance] getWorsNegative];
    
    NSString *text = [NSString stringWithFormat:@"【%@】观看最具情怀的新闻 最具正能量情怀新闻 %@ 最具负能量情怀新闻 %@",self.title, best.title, worst.title];
    
    //分享的URL修改 modify by JSG
    //NSString *shareUrl = [self subsShareUrl:best.newsUrl];
    NSString *shareUrl = best.newsUrl;
    
    if (type == ItemWeixin) {
        UIImage *shareImg = [UIImage imageNamed:@"addBtn.png"];
        [theApp sendWeixin:self.title description:text
                   newsUrl:shareUrl
                shareImage:shareImg scene:WXSceneSession];
    }
    else if (type == WeiXinFriendZone) {
        UIImage *shareImg = [UIImage imageNamed:@"addBtn.png"];
        [theApp sendWeixin:self.title description:text
                   newsUrl:shareUrl
                shareImage:shareImg scene:WXSceneFriendZone];
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
        
        //提取正文图片
//        [view setNumOfPhotos:[self getContentWebViewImg]];
        [[csc curShareView] reloadPhotosOnline];
        [csc clearButtonOnToolsBar];
        
        PhoneSurfController *vc = (PhoneSurfController*)[theApp topMostVC];
        [vc presentController:csc animated:PresentAnimatedStateFromRight];
    }
    else if (type == ItemTencentWeibo) {
        ContentShareController *csc = [ContentShareController new];
        [csc setTitle:@"分享到腾讯微博"];
        
        ContentShareView* view = [csc curShareView];
        [view setShareWordText:text];
        [view remainlab:text];
        [view setShareMode:TencentWeibo];
        [view setShareAds:shareUrl];
        [view setShareNewsAds:shareUrl];
        [view setShareStr:text];
        
        //提取正文图片
//        [view setNumOfPhotos:[self getContentWebViewImg]];
        [[csc curShareView] reloadPhotosOnline];
        [csc clearButtonOnToolsBar];
        
        PhoneSurfController *vc = (PhoneSurfController*)[theApp topMostVC];
        [vc presentController:csc animated:PresentAnimatedStateFromRight];
    }
    //    else if (type == ItemRenren) {
    // 代码没有测试，直接是复制过来，如何那天需要用到，需要从新调试
    //        ContentShareController *csc = [ContentShareController new];
    //        [csc.m_contentShareView.m_shareWord setText:weiboContent];
    //        csc.m_contentShareView.m_shareStr = _thread.desc;
    //        [self presentController:csc animated:PresentAnimatedStateFromBottom];
    //    }
    else if (type == ItemChinaMobileWeibo) {
        ContentShareController *csc = [ContentShareController new];
        [csc setTitle:@"分享到中国移动微博"];
        ContentShareView* view = [csc curShareView];
        [view setShareWordText:text];
        [view remainlab:text];
        [view setShareMode:ChinaMobileWeibo];
        [view setShareAds:shareUrl];
        [view setShareNewsAds:shareUrl];
        [view setShareStr:text];
        [csc clearButtonOnToolsBar];
        
        PhoneSurfController *vc = (PhoneSurfController*)[theApp topMostVC];
        [vc presentController:csc animated:PresentAnimatedStateFromRight];
    }
}

//- (NSString*)subsShareUrl:(NSString*)str{
//    //NSString *shareUrl = "http://go.10086.cn/infoTouch.do?method=content&id="+currentNews.getNewsId()+"&cid="+currentNews.getChannelId()+"&coc=6GP3GGjt";
//    
//    NSString *url = nil;
//    
//    positiveNews *best = [[RankingManager sharedInstance] getBestPositive];
//    
//    NSNumber *longNumber = [NSNumber numberWithLong:[best.coid longLongValue]];
//    NSString *coid = [longNumber stringValue];
//    
//    //判断是否是本地频道
//    if ([coid isEqualToString:@"0"]) {
//        //本地频道
//        if (str) {
//            url = str;
//        }else{
//            [PhoneNotification autoHideWithText:@"获取新闻地址失败"];
//        }
//    }
//    else{
//        NSNumber *longNumber1 = [NSNumber numberWithLong:ts.threadId];
//        NSString *threadId = [longNumber1 stringValue];
//        
//        NSNumber *longNumber2 = [NSNumber numberWithLong:ts.channelId];
//        NSString *channelId = [longNumber2 stringValue];
//        
//        NSString *str1 = [NSString stringWithFormat:@"http://go.10086.cn/infoTouch.do?method=content&id=%@",threadId];
//        
//        NSString *str2 = [NSString stringWithFormat:@"&cid=%@&coc=6GP3GGjt",channelId];
//        
//        NSString *shareURL = [str1 stringByAppendingString:str2];
//        url = shareURL;
//    }
//    
//    return url;
//}

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
    else if (type == ItemTencentWeibo) {
        if (![self isOAuthed:TencentOAuth]) {
            [self oauthWebViewController:TencentOAuth];
            return;
        }
    }
    //        else if (type == ItemRenren) {
    //            if (![self isOAuthed:RenRenOAuth]) {
    //                [self oauthWebViewController:RenRenOAuth];
    //                return;
    //            }
    //        }
    else if (type == ItemChinaMobileWeibo) {
        if (![self isOAuthed:ChinaMobielOAuth]) {
            [self oauthWebViewController:ChinaMobielOAuth];
            return;
        }
        
    }
    else if (type == ItemSMS) {
        // 短信分享
        positiveNews *best = [[RankingManager sharedInstance] getBestPositive];
        negativeNews *worst = [[RankingManager sharedInstance] getWorsNegative];
        
        NSString *text = [NSString stringWithFormat:@"【%@】观看最具情怀的新闻 最具正能量情怀新闻 %@ 最具负能量情怀新闻 %@",self.title, best.title, worst.title];
        
//        NSString *shareUrl = [self subsShareUrl:best.newsUrl];
        
        if ([MFMessageComposeViewController canSendText]) {
            theApp.nightModeShadow.hidden = YES;
            MFMessageComposeViewController *messageCtrll = [MFMessageComposeViewController new];
            messageCtrll.body = [NSString stringWithFormat:@"%@ %@", text, best.newsUrl];
            messageCtrll.messageComposeDelegate = self;
            UIViewController *vc = [theApp topMostVC];
            if(IOS7){
                [vc presentModalViewController:messageCtrll animated:YES];
            }
            else {
                [vc presentViewController:messageCtrll animated:YES completion:nil];
            }
        }
        return;
    }
    
    // 进入微博编写窗口
    [self entryWeiboEditeView:type];
}
#pragma mark OauthWebViewControllerDelegate methods 微信授权控件协议实现
//授权成功
- (void)oauthResult:(OauthWebViewController *)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissModalViewControllerAnimated:NO];
    
    if (type == SinaOAuth) {
        [self shareWeibo:ItemSinaWeibo];
    } else if (type == TencentOAuth) {
        [self shareWeibo:ItemTencentWeibo];
    } else if (type == RenRenOAuth) {
        //        [self shareWeibo:ItemRenren];
    } else if (type == ChinaMobielOAuth) {
        [self shareWeibo:ItemChinaMobileWeibo];
    }
}

//授权失败
- (void)oauthFailed:(OauthWebViewController *)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissModalViewControllerAnimated:YES];
    
    if (type == SinaOAuth)
        [PhoneNotification autoHideWithText:@"绑定新浪微博失败,请重试"];
    else if (type == TencentOAuth)
        [PhoneNotification autoHideWithText:@"绑定腾讯微博失败,请重试"];
    else if (type == RenRenOAuth)
        [PhoneNotification autoHideWithText:@"绑定人人网失败,请重试"];
    else if (type == ChinaMobielOAuth)
        [PhoneNotification autoHideWithText:@"绑定中国移动微博失败,请重试"];
}
#pragma mark MFMessageComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
//    shareInfo = nil;
    
    if (result == MessageComposeResultSent) {
        [PhoneNotification autoHideWithText:@"短信分享成功"];
    } else if (result == MessageComposeResultFailed) {
        [PhoneNotification autoHideWithText:@"短信分享失败"];
    }
    theApp.nightModeShadow.hidden = ![[ThemeMgr sharedInstance] isNightmode];
    if([[[UIDevice currentDevice] systemVersion] isVersionLowerThan:@"6.0"]) {
        [controller dismissModalViewControllerAnimated:YES];
    } else {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
