//
//  PhoneRootViewController.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneRootViewController.h"
#import "PictureBox.h"
#import "PhoneMagazineController.h"
#import "MoreViewController.h"
#import "PhoneHotRootcontroller.h"
#import "AppDelegate.h"
#import "PhoneSplashView.h"
#import "UpdateSplashResponse.h"
#import "EzJsonParser.h"
#import "PathUtil.h"
#import "AppSettings.h"
#import "FileUtil.h"
#import "NotificationManager.h"
#import "PhoneClassifyViewController.h"
#import "FirstRunView.h"
#import "SurfFlagsManager.h"


#define kTabBarItem_ImageViewTag 100
#define kTabBarItem_LableTag 200

// 自定义TabBarItem 类型
typedef NS_ENUM(NSUInteger, CustomTabBarItemType) {
    CustomTabBarItemType_News = 1,              // 新闻
    CustomTabBarItemType_Classify = 1 << 1,     // 分类
    CustomTabBarItemType_Find = 1 << 2,         // 发现
    CustomTabBarItemType_UserCenter = 1 << 3    // 新闻中心
};




@interface PhoneRootViewController ()
<   NightModeChangedDelegate,
    GuideViewControllerDelegate> {
    
    __weak UIView *_customTabBar;           // 底部工具栏背景
    __weak CALayer *_customTabBarBg;
    CustomTabBarItemType _tabBarItemTypes;  // item类型
    
    NSMutableArray *_tabItemTypeOrder;      // itemType顺序
    NSMutableArray *_tabItemFlagViews;      // 标记View
        
    __strong SplashData* sd_;               // 启动画面数据
}

@end

@implementation PhoneRootViewController

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedViewController"];
//    [self removeObserver:self forKeyPath:@"selectedIndex"];
}


-(void)loadView
{
    [super loadView];
    
//    手动创建UITabBarController
//    　最常见的创建UITabBarController的地方就是在application delegate中的 applicationDidFinishLaunching:方法，因为UITabBarController通常是作为整个程序的rootViewController的，我们需要在程序的window显示之前就创建好它
    
    _tabItemFlagViews = [NSMutableArray arrayWithCapacity:4];
    _tabItemTypeOrder = [NSMutableArray arrayWithCapacity:4];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    
    // 支持的自定义TabBarItem
    _tabBarItemTypes =
    CustomTabBarItemType_News |
//    CustomTabBarItemType_Classify |
    CustomTabBarItemType_Find |
    CustomTabBarItemType_UserCenter;
    
    
    // 注：这里数据都是一一对应的，后面代码不做验证。
    NSInteger bit = 1;
    while (_tabBarItemTypes >= bit) {
        CustomTabBarItemType t = _tabBarItemTypes & bit;
        if (t) {
            [_tabItemTypeOrder addObject:@(t)];
        }
        bit <<= 1;
    }

    
    // 自定义TabBar
    UIView *tabBar = [self createCustomTabBarView];
    _customTabBar = tabBar;
    [self.tabBar addSubview:_customTabBar];
    
    
    // 初始化Controller
    NSMutableArray *vcArr = [NSMutableArray arrayWithCapacity:4];
    [_tabItemTypeOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger type = [obj integerValue];
        id vc = [self naviControllerWithTabBarType:type];
        if (vc)
            [vcArr addObject:vc];
    }];
    self.viewControllers = vcArr;
    
    
    // 初始化TabBarItem
    [_tabItemTypeOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger type = [obj integerValue];
        // tabarItem
        UIView *customTabBarItem =
        [self createCustomTabBarItemView:[self tabBarItemTitle:type]
                         normalImageName:[self tabBarItemImageName:type isSelect:NO]
                         tabBarItemIndex:idx];
        [_customTabBar addSubview:customTabBarItem];
    }];

    
    /** UItabBarItem 初始化**************************************/
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    [mgr registerNightmodeChangedNotification:self];// 注册夜间切换通知
    
    
    // 添加tabBar切换事件
    // 注意：点击系统的TabBarItem已经会改变selectedIndex来监听时间，没有想到，居然没有反应
    [self addObserver:self
           forKeyPath:@"selectedViewController"
              options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld
              context:nil];
    // 本来以为只有上面的监听就够了，在发现开机画面可以调转发现，
//    [self addObserver:self
//           forKeyPath:@"selectedIndex"
//              options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld
//              context:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    // 创建主界面的新手引导 , 400 对应版本是4.0.0
//     NSInteger versionValue = [AppSettings integerForKey:IntKey_MainUIUserGuide];
//    if (versionValue < kVersion_key)
//    {
//        [AppSettings setInteger:kVersion_key forKey:IntKey_MainUIUserGuide];
//            MainViewGuide *guide = [[MainViewGuide alloc] initWithFrame:self.view.bounds andWithType:MainApp_Type];
//                [guide setBackgroundColor:[UIColor clearColor]];
//                [self.view addSubview:guide];
//    }
    
    
    if ([[NotificationManager sharedInstance] getShowSplashView]) {
        NSString* splashDataFilePath = [PathUtil pathOfSplashDataFile];
        sd_ = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:splashDataFilePath encoding:NSUTF8StringEncoding error:nil] AsType:[SplashData class]];
        if(sd_)
        {
            NSString* splashNewsImagePath = [PathUtil pathOfSplashNewsImage];
            
            NSDate* now = [NSDate date];
            NSDate* exp = [NSDate dateWithTimeIntervalSince1970:[sd_.newsend longLongValue] / 1000];
            NSDate* valid = [NSDate dateWithTimeIntervalSince1970:[sd_.newsstart longLongValue] / 1000];
            if ([valid compare:now] == NSOrderedAscending
                && [now compare:exp] == NSOrderedAscending
                && [FileUtil fileExists:splashNewsImagePath])
            {
                //开机图未过期且下载成功
                PhoneSplashView *phoneSplashView = [[PhoneSplashView alloc] initWithSplashData:sd_];
                UINavigationController *parentCtl = self.viewControllers[0];
                phoneSplashView.newsController =
                (PhoneHotRootController*)parentCtl.visibleViewController;
                phoneSplashView.tag = 962464;
                [self.view addSubview:phoneSplashView];
               
            }
        }
        else{
            PhoneSplashView *phoneSplashView = [[PhoneSplashView alloc] initWithSplashData:sd_];
              UINavigationController *parentCtl = self.viewControllers[0];
            phoneSplashView.newsController =
            (PhoneHotRootController*)parentCtl.visibleViewController;
            [self.view addSubview:phoneSplashView];
        }
    }
    
    
    //    BOOL showMoreCtrlMark = [[UserManager sharedInstance] readFileArraySelectedMoreVC];
    //    if (showMoreCtrlMark) {
    //        [self showAllMark:YES];
    //    }
    
    
    [self updateTabBar:0 oldTabBarIndex:0];
    [self nightModeChanged:[[ThemeMgr sharedInstance] isNightmode] ];
    
}

- (void)guangGaoAction
{
//    [[self.view viewWithTag:962464] removeFromSuperview];
    
     [(PhoneSplashView *)[self.view viewWithTag:962464] splashAnimate:4];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 显示新手引导
    [self showGuideView];
    if ([self.view viewWithTag:962464])
    {
        [self performSelector:@selector(guangGaoAction) withObject:nil afterDelay:3.1];
    }
}

/**
 *  创建需要的Controller
 *
 *  @param type TabBar类型
 *
 *  @return Controller
 */
-(UINavigationController *)naviControllerWithTabBarType:(CustomTabBarItemType) type
{
    if (type == CustomTabBarItemType_News) {
        // 初始化UIViewController
        UIViewController *newsVC = [PhoneHotRootController new];
        return [[UINavigationController alloc] initWithRootViewController:newsVC];
    }
    else if(type == CustomTabBarItemType_Classify) {
        UIViewController* classify = [PhoneClassifyViewController new];
        return [[UINavigationController alloc] initWithRootViewController:classify];
    }
    else if(type == CustomTabBarItemType_Find) {
        DiscoverViewControlloer *discoverVC = [DiscoverViewControlloer new];
        return [[UINavigationController alloc] initWithRootViewController:discoverVC];
    }
    else if (type == CustomTabBarItemType_UserCenter){
        MoreViewController *moreVC = [[MoreViewController alloc] init];
        return [[UINavigationController alloc] initWithRootViewController:moreVC];
    }
    return nil;
    
//订阅Tab
//    SurfSubscribeViewController *subsController = [[SurfSubscribeViewController alloc] init];
//    UINavigationController *subsNav = [[UINavigationController alloc] initWithRootViewController:subsController];
//    [arr addObject:subsNav];

//图集Tab
//    SurfNewsViewController *photoController = [[SurfNewsViewController alloc] init];
//    photoController.title = @"冲浪图集";
//       PhotoGalleryViewController *photoController = [[PhotoGalleryViewController alloc] init];

//    //期刊Tab
//    PhoneMagazineController *magazineController = [[PhoneMagazineController alloc] init];
//    UINavigationController *magazineNav = [[UINavigationController alloc] initWithRootViewController:magazineController];
//    [arr addObject:magazineNav];
    
  
}



/**
 *  创建自定义tabBar
 *
 *  @return UIView
 */
- (UIView *)createCustomTabBarView
{
    CGRect tR = self.tabBar.bounds;
    UIView* customTabBar = [[UIView alloc] initWithFrame:tR];
    customTabBar.userInteractionEnabled = NO;

    
    // 创建背景
    CALayer *bgL = [CALayer layer];
    _customTabBarBg = bgL;
    bgL.frame = tR;
    bgL.contentsScale = [[UIScreen mainScreen] scale];
    [customTabBar.layer addSublayer:bgL];
    return customTabBar;
}

/**
 *  创建自定义tabBarItemView
 */
- (UIView*)createCustomTabBarItemView:(NSString *)itemTitle
                      normalImageName:(NSString *)imgName
                      tabBarItemIndex:(NSUInteger)itemIdex
{
    NSInteger constIdex = 600;
    NSInteger count = self.tabBar.items.count;
    CGFloat vW = CGRectGetWidth(self.tabBar.bounds) / count;
    CGFloat vH = CGRectGetHeight(self.tabBar.bounds);
    CGFloat vX = itemIdex * vW, vY = .0f;
    CGRect vR = CGRectMake(vX, vY, vW, vH);
    UIView *customTabBarItem = [[UIView alloc] initWithFrame:vR];
    customTabBarItem.backgroundColor = [UIColor clearColor];
    customTabBarItem.userInteractionEnabled = NO;
    customTabBarItem.tag = constIdex + itemIdex;
    
    // itemTitle
    CGFloat lH = 10.f, lW = vW, lX = .0f;
    CGFloat lY = vH - lH - 5.f;
    CGRect lR = CGRectMake(lX, lY, lW, lH);
    UILabel *label = [[UILabel alloc] initWithFrame:lR];
    label.text = itemTitle;
    label.textColor = [UIColor colorWithHexValue:0xff999292];
    label.font = [UIFont systemFontOfSize:10.0f];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.userInteractionEnabled = NO;
    label.tag = kTabBarItem_LableTag;
    [customTabBarItem addSubview:label];
    
    // 图片
    UIImage *img = [UIImage imageNamed:imgName];
    CGFloat imgW = img.size.width;
    CGFloat imgH = img.size.height;
    CGFloat imgX = (vW-imgW )/2.f;
    CGFloat imgY = (lY-imgH)/2;
    CGRect imgR = CGRectMake(imgX, imgY, imgW, imgH);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgR];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = img;
    imageView.userInteractionEnabled = NO;
    imageView.tag = kTabBarItem_ImageViewTag;
    [imageView setBackgroundColor:[UIColor clearColor]];
    [customTabBarItem addSubview:imageView];
    
    return customTabBarItem;
}

// 获取自定义TabBarItem
-(UIView*)customTabBarItemView:(NSUInteger)idex
{
    NSInteger constIdex = 600;
    return [_customTabBar viewWithTag:constIdex+idex];
}

/**
 *  获取TabBarItem图片名称
 *
 *  @param type       item类型
 *  @param isSelected 选择图片
 *
 *  @return 图片名称
 */
- (NSString*)tabBarItemImageName:(CustomTabBarItemType)type
                    isSelect:(BOOL)isSelected
{
    if(type == CustomTabBarItemType_News)
        return isSelected ? @"kx_click":@"kx_unclick";
    else if (type == CustomTabBarItemType_Classify)
        return isSelected ? @"tab_item_5":@"tab_item_1";
    else if (type == CustomTabBarItemType_Find)
        return isSelected ? @"find_click":@"find_unclick";
    else if (type == CustomTabBarItemType_UserCenter)
        return isSelected ? @"me_click":@"me_unclick";
    return @"";
}

-(NSString *)tabBarItemTitle:(CustomTabBarItemType)type
{
    if(type == CustomTabBarItemType_News)
        return @"快讯";
    else if (type == CustomTabBarItemType_Classify)
        return @"分类";
    else if (type == CustomTabBarItemType_Find)
        return @"发现";
    else if (type == CustomTabBarItemType_UserCenter)
        return @"我";
    return @"";
}

-(NSUInteger)tabItemFlagViewTag:(CustomTabBarItemType)type
{
    if(type == CustomTabBarItemType_News)
        return 500;
    else if (type == CustomTabBarItemType_Classify)
        return 501;
    else if (type == CustomTabBarItemType_Find)
        return 502;
    else if (type == CustomTabBarItemType_UserCenter)
        return 503;
    return NSNotFound;
}

-(UIView*)customTabBarItemViewWithTag:(CustomTabBarItemType)type
{
    if (type < _tabBarItemTypes) {
        NSInteger itemTag = [_tabItemTypeOrder indexOfObject:@(type)];
        if (itemTag != NSNotFound) {
            return [self customTabBarItemView:itemTag];
        }
    }
    return nil;
}

/**
 *  显示TabBarItem标记
 *
 *  @param isShow 是否显示
 */
- (void)showTabBarItemFlag:(CustomTabBarItemType)tabItemType
                    isShow:(BOOL)isShow
{
    NSUInteger viewTag = [self tabItemFlagViewTag:tabItemType];
    UIView *flagView = [_customTabBar viewWithTag:viewTag];
    if (!isShow) {
        if (flagView) {
            [flagView removeFromSuperview];
        }
    }
    else {
        if (!flagView) {
            UIImage *flgImg = [SurfFlagsManager flagImage];
            flagView = [[UIImageView alloc] initWithImage:flgImg];
            [flagView setTag:viewTag];
            
            
            // 获取自定义TabBarItemView
            NSInteger itemTag = [_tabItemTypeOrder indexOfObject:@(tabItemType)];
            
            UIView *itemV = [self customTabBarItemView:itemTag];
            if (itemV) {
                CGFloat fX = CGRectGetWidth(itemV.bounds)/2 + 15;
                CGFloat fY = CGRectGetHeight(itemV.bounds)/2 - 15;
                flagView.center = CGPointMake(fX, fY);
                [itemV addSubview:flagView];
            }
        }
    }
}


/**
 *  显示新手引导
 */
- (void)showGuideView
{
    NSString* curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *preVersion = [AppSettings stringForKey:StringLastRunVersion];
    
    // 显示新手引导页面
    if (![preVersion isVersionEqualsTo:curVersion]) {
        [AppSettings setString:curVersion forKey:StringLastRunVersion];
        GuideView *guide = [[GuideView alloc] initWithFrame:self.view.frame];
        [guide setAnimating:NO];
        [guide setBackgroundColor:[UIColor clearColor]];
        guide.guideDelegate = self;
        [self.view addSubview:guide];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedViewController"])
    {
        // 1、selectedIndex属性
        // 通过该属性可以获得当前选中的viewController，设置该属性，可以显示viewControllers中对应的index的viewController。如果当前选中的是MoreViewController的话，该属性获取出来的值是NSNotFound，而且通过该属性也不能设置选中MoreViewController。
        id oldV = [change objectForKey:NSKeyValueChangeOldKey];
        id newV = [change objectForKey:NSKeyValueChangeNewKey];
        NSArray *controllers = [self viewControllers];
        NSUInteger oldNum = [controllers indexOfObject:oldV];
        NSUInteger newNum = [controllers indexOfObject:newV];
        if (oldNum < [controllers count] && newNum < [controllers count]) {
            [self updateTabBar:newNum oldTabBarIndex:oldNum];
        }
    }
}

/**
 *  更新自定义tabBar
 *
 *  @param tableIndex tabBar下标
 */
-(void)updateTabBar:(NSUInteger)newTabBarIndex
     oldTabBarIndex:(NSUInteger)oldIndex
{
    if (oldIndex != newTabBarIndex) {
        UIView *oldTabBar = [self customTabBarItemView:oldIndex];
        [self updateTabBarItem:oldTabBar taBarIndex:oldIndex
                    isSelected:NO];
    }
   
    
    // 更新新的TabBarItem
    UIView *tabBar = [self customTabBarItemView:newTabBarIndex];
    [self updateTabBarItem:tabBar taBarIndex:newTabBarIndex
                isSelected:YES];
    
    
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    theApp.nightModeShadow.hidden = !isNight;
}

-(void)updateTabBarItem:(UIView *)tabarItem
             taBarIndex:(NSUInteger)taBarIdex
             isSelected:(BOOL)selected
{
    UILabel *titleL =
    (UILabel*)[tabarItem viewWithTag:kTabBarItem_LableTag];
    UIImageView *imageV =
    (UIImageView*)[tabarItem viewWithTag:kTabBarItem_ImageViewTag];
    CustomTabBarItemType itmeType =
    [[_tabItemTypeOrder objectAtIndex:taBarIdex] integerValue];
    NSString *imgN = [self tabBarItemImageName:itmeType isSelect:selected];
    [imageV setImage:[UIImage imageNamed:imgN]];
    titleL.textColor = [UIColor colorWithHexValue:selected?0xFFCE0000:0xFF999292];
    
    // 删除标记点
    if(selected)
        [self showTabBarItemFlag:itmeType isShow:NO];

}

#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    if (night) {
        UIImage *bg = [UIImage imageNamed:@"tab_bar_night"];
        [_customTabBarBg setContents:(id)bg.CGImage];
    }
    else {
        UIImage *bg = [UIImage imageNamed:@"tab_bar_white"];
        [_customTabBarBg setContents:(id)bg.CGImage];
    }
}
#pragma mark - GuideViewControllerDelegate
- (void)finishLoadGuideView
{
//    [guideViewCrl.view removeFromSuperview];
//    guideViewCrl= nil;
}


@end
