//
//  AppDelegate.m
//  SurfNewsHD
//
//  Created by apple on 12-11-14.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "GTMHTTPFetcher.h"
#import "GTMHTTPFetcherLogging.h"
#import "EzJsonParser.h"
#import "CheckUpgradeResponse.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "ImageDownloader.h"
#import "NSString+Extensions.h"
#import "LoadingController.h"
#import "HotChannelsManager.h"
#import "CheckUpgradeResponse.h"
#import "UpdateSplashResponse.h"
#import "SubsChannelsListResponse.h"
#import "GetMagazineSubsResponse.h"
#import "SurfUserInfo.h"
#import "AppSettings.h"
#import "ImageDownloader.h"
#import "UserManager.h"
#import "ThreadsManager.h"
#import "RuntimeUtil.h"
#import "MagazineManager.h"
#import "OfflineDownloader.h"
#import "UIAlertView+Blocks.h"
#import "UIDevice+Hardware.h"
#import "ClientFunctionManager.h"
#import "WeatherManager.h"
#import "NotificationManager.h"
#import "MagazineInfoController.h"
#import "PastPeriodicalController.h"
#import "DownLoadViewController.h"
#import "AdvertisementManager.h"
#import "DispatchUtil.h"
#import "SurfFlagsManager.h"
#import "PhoneNotification.h"
#import "UIImage+Extensions.h"
#import "UIFont+Surf.h"
#import "MobClick.h"

#ifdef ipad


#else 

#import "iTunesLookupUtil.h"
#endif

@implementation AppDelegate
@synthesize rootController;
@synthesize screenShotsList;
void customedExceptionHandler(NSException* exception){
    NSLog(@"CRASH: %@\n",exception);
    NSLog(@"StackTrace: %@\n",[exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DJLog(@"%@", [PathUtil documentsPath]);
    //异常崩溃后虽然可以看到异常信息，但往往很难找到到底是哪里的代码引发的异常
    //自定义异常处理后，我们打印出调用栈，就可以比较方便地找到出错代码的具体位置。
    NSSetUncaughtExceptionHandler(&customedExceptionHandler);
    self.screenShotsList = [NSMutableArray new];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [UIViewController new];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];    
    
    //清空推送目录
    [[NotificationManager sharedInstance] clearRootPathOfNotiFidir];

#ifdef ipad
    LoadingController *loadController = [[LoadingController alloc] init];
    self.window.rootViewController = loadController;

    rootController = [[SurfRootViewController alloc] init];
    rootController.showsMasterInPortrait = YES;
    rootController.splitWidth = kSplitDividerWidth;
    rootController.allowsDraggingDivider = YES;
    rootController.splitPosition = kSplitPositionMax;
    
#else
    //注册微信
    [WXApi registerApp:kWeixinAppId];
    
    // 替换UIImage中的imageNamed函数
    SEL oldMtd = @selector(imageNamed:);
    SEL newMtd = @selector(imageNamedNewImpl:);
    [RuntimeUtil swizzleClassMethod:oldMtd ofClass:[UIImage class] withNewMethod:newMtd];
    
    // 2015.4.28 add by xuxg 替换字体UIFont systemFontOfSize函数
    // 移动发邮件说对字体支持不好，我们又换回来
//    SEL oldFontFun = @selector(systemFontOfSize:);
//    SEL newFontFun = @selector(surfFont:);
//    [RuntimeUtil swizzleClassMethod:oldFontFun
//                            ofClass:[UIFont class]
//                      withNewMethod:newFontFun];
    
    // 初始化友盟统计库
    [self buildUMeng];
    
    // 注册推送通知
    [self registerForPUSHNotifications];
    
    //初始化程序，初始化完成后方能进入界面
    [self initAppEnv];
    
    //查看是否需要初始化程序数据
    [self ensureDataReadyForFirstRun:YES];
    
    //推送模块初始化值
    _isShowAlert=NO;
    shouldClearAllNotificationsOnEnterBackground=NO;
    [[NotificationManager sharedInstance] setShowSplashView:YES];
    notificationDic = launchOptions;
    notifiAppState = application.applicationState;
#endif
    return YES;
}

#ifndef ipad

//必须在ensureDataReadyForFirstRun成功后调用
-(void)gotoMainUI
{
    // 检测网页正文中是否开启相关推荐功能
    [[ClientFunctionManager sharedInstance] refreshClientFunction];
    
    //检测更新
#ifdef JAILBREAK
#else
    [self checkUpdateFromItunes];
#endif
    
    //刷新splash闪屏画面
    [self updateSplash];
    
    //订阅关系
    [self checkUpdateSubs];
    
    // 我晕，这个必须checkUpdateSubs之后才能获取到本地的期刊订阅关系，
    [[SurfFlagsManager sharedInstance] refreshFlags];
    
    

    if (!rootController) {
        rootController = [PhoneRootViewController new];
        rootController.selectedIndex = 0;
    }
    if (!_nightModeShadow) {
        _nightModeShadow = [[UIView alloc] initWithFrame:self.window.bounds];
        _nightModeShadow.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.18f];
        _nightModeShadow.userInteractionEnabled = NO;
    }

    _nightModeShadow.hidden = ![[ThemeMgr sharedInstance] isNightmode];
    self.window.rootViewController = rootController;
    [self.window addSubview:_nightModeShadow];
 
    if (0<[[OfflineDownloader sharedInstance] pendingTasksCount]) {
        [[DownLoadViewController sharedInstance] setHiddenView:NO];
    }
    
    //
    if (notificationDic) {
        shouldClearAllNotificationsOnEnterBackground = YES;
        if ([[NotificationManager sharedInstance] getTurnSwitch]){
            [[NotificationManager sharedInstance] setShowSplashView:YES];
            [[NotificationManager sharedInstance] explainFromUserInfo:[notificationDic objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] andState:notifiAppState];
        }
    }
    
//    [[NotificationManager sharedInstance] testOpenThread];
}

//保证首次运行的本地数据就绪
-(void)ensureDataReadyForFirstRun:(BOOL) silent
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    imageView.image = [UIImage fitLaunchImage];
    [self.window addSubview:imageView];
    
    //在window上放一个风火轮
    if(!silent)
        [PhoneNotification manuallyHideWithText:@"初始化中..." indicator:YES];
    
    HotChannelsManager* hcm = [HotChannelsManager sharedInstance];
    // 检查是否有频道列表，没有就刷新频道列表
    if(!hcm.visibleHotChannels || [hcm.visibleHotChannels count] < 2)
    {
        //// 无本地热推频道列表，则需要初始化程序数据
        // 请求热推频道列表
        [hcm refreshWithCompletionHandler:^(BOOL succeeded,BOOL noChange)
         {
             if(succeeded && [hcm.visibleHotChannels count] > 0) {
                 //成功，则继续请求第一个热推频道的20条帖子数据
                 [[ThreadsManager sharedInstance] refreshHotChannel:self
                                                         hotChannel:hcm.visibleHotChannels[0]
                                              withCompletionHandler:^(ThreadsFetchingResult *result)
                 {
                     //隐藏风火轮
                     if(!silent)
                         [PhoneNotification hideNotification];
                     
                     if(result.succeeded) {
                         [self gotoMainUI];//成功进入UI
                         
                         // 主界面已经创建好，在等待3秒钟进入
                         [DispatchUtil dispatch:^(void) {
                             [imageView removeFromSuperview];
                         } after:3.f];
                     }
                     else {
                         //显示重试按钮
                         [self showInitFailedAlert];
                     }

                 }];                 
             }
             else {
                 //隐藏风火轮
                 if(!silent)
                     [PhoneNotification hideNotification];
                 
                 //显示重试按钮
                 [self showInitFailedAlert];
             }
         }];
    }
    else {
//        HotChannel* channel0 = [hcm visibleHotChannels][0];
//        // 不管第一个频道数据有无，都刷新一下（防止主界面刷新卡顿显像）。
//        [[ThreadsManager sharedInstance] refreshHotChannel:self
//                                                hotChannel:channel0
//                                     withCompletionHandler:^(ThreadsFetchingResult *result) {
//            //隐藏风火轮
//            if(!silent)
//                [PhoneNotification hideNotification];
//                
//            if(result.succeeded) {
//                [self gotoMainUI]; //成功进入UI
////
//                // 主界面已经创建好，在等待3秒钟进入
//                [DispatchUtil dispatch:^(void) {
//                    [imageView removeFromSuperview];
//                } after:3.f];
//            }
//            else {
//                //显示重试按钮
//                [self showInitFailedAlert];
//            }
//        }];
        
        // ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
        // 2016-1-27 要求无网络的情况下也要启动app 进入 主界面  bywsg
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        [self gotoMainUI]; //成功进入UI
        
        // 主界面已经创建好，在等待3秒钟进入
        [DispatchUtil dispatch:^(void) {
            [imageView removeFromSuperview];
        } after:3.f];
    }

    [self showGrade];
}

// 显示评分
-(void)showGrade
{
    if ([AppSettings integerForKey:kGrade]>5) {
        return;
    }
    if (![AppSettings integerForKey:kGrade]) {
        [AppSettings setInteger:1 forKey:kGrade];
        return;
    }
    else if(5==[AppSettings integerForKey:kGrade]){
        UIAlertView*alt=[[UIAlertView alloc] initWithTitle:nil message:@"亲,给个评价吧~" delegate:self cancelButtonTitle:@"残忍的拒绝!" otherButtonTitles:@"去评分~", nil];
        alt.tag=EVALUATE_TAG;
        [alt show];
    }
    
    NSInteger j=[AppSettings integerForKey:kGrade]+1;
    [AppSettings setInteger:j forKey:kGrade];
}

// 初始化失败Alert
- (void)showInitFailedAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"初始化失败"
                                                    message:@"请检查您的网络连接!"
                                           cancelButtonItem:
                          [RIButtonItem itemWithLabel:@"重试" action:
                           ^{
                               [self ensureDataReadyForFirstRun : NO];
                           }]
                                           otherButtonItems:nil, nil];

    [alert show];
}


#endif

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if (shouldClearAllNotificationsOnEnterBackground) {
        [self clearNotifi];
    }
    
    //复位
    shouldClearAllNotificationsOnEnterBackground = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    HotChannelsManager* hcm = [HotChannelsManager sharedInstance];
    if ([hcm.visibleHotChannels count] <= 0)
    {
        [self updateHotChannels:^(BOOL succeed) {
            if (succeed) {
                //立刻刷新第一个频道（通常名为【热推】）的帖子列表
                [[ThreadsManager sharedInstance] refreshHotChannel:self
                                                        hotChannel:hcm.visibleHotChannels[0]
                                             withCompletionHandler:^(ThreadsFetchingResult *result)
                {
                    if(result.succeeded)
                    {
#ifdef ipad
                        [rootController changedSelectController:[NSIndexPath indexPathForRow:1 inSection:0]];
                        [rootController changedSelectController:[NSIndexPath indexPathForRow:0 inSection:0]];
#else
                        
#endif
                    }
                    else
                    {
                        //获取【热推】频道最新帖子列表失败
                        //认为初始化失败
                        dispatch_async(dispatch_get_main_queue(), ^(void)
                                       {
                                       });
                    }

                }];
            }
        }];
    }
    
    //为什么只判断是否有栏目订阅？
    //是因为栏目有默认的订阅,而期刊没有,所有这里只判断是否有栏目订阅即可
    SubsChannelsManager* scm = [SubsChannelsManager sharedInstance];
    if ([[scm loadLocalSubsChannels] count] <=0) {    
        //更新用户订阅关系
        [self checkUpdateSubs];
    }
    
    // 更新标记点
    [[SurfFlagsManager sharedInstance] refreshFlags];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (!_oauthWebViewController) {
        _oauthWebViewController = [OauthWebViewController new];
    }
    [_oauthWebViewController applicationDidBecomeActive];
    
     application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    // 1.取消下载
    [mgr cancelAll];
    
    // 2.清除内存中的所有图片
    [mgr.imageCache clearMemory];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url absoluteString] hasPrefix:kSinaSSOCallbackScheme]) {
        if (!_oauthWebViewController) {
            _oauthWebViewController = [OauthWebViewController new];
        }
        [_oauthWebViewController handleOpenURL:[url copy]];
        
        _oauthWebViewController = [OauthWebViewController new];
    } else if ([[url absoluteString] hasPrefix:kWeixinAppId]) {
        return  [WXApi handleOpenURL:url delegate:self];
    }else if ([[url absoluteString] hasPrefix:kQQ]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url absoluteString] hasPrefix:kSinaSSOCallbackScheme]) {
        if (!_oauthWebViewController) {
            _oauthWebViewController = [OauthWebViewController new];
        }
        [_oauthWebViewController handleOpenURL:[url copy]];
        
        _oauthWebViewController = [OauthWebViewController new];
    }
    else if ([[url absoluteString] hasPrefix:kWeixinAppId]) {
        return  [WXApi handleOpenURL:url delegate:self];
    }else if ([[url absoluteString] hasPrefix:kQQ]) {
        
        [PhoneWeiboController handleOpenUrl:url];
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

-(void)initAppWithCompletionHandler:(void(^)(BOOL succeed))handler
{
    //??gtm不能在global_queue中使用（网络始终不回调），费解，所以这里暂时使用单线程进行初始化
    dispatch_queue_t queue = dispatch_get_main_queue();//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void)
                   {
                       //初始化gtm
                       [GTMHTTPFetcher setLoggingEnabled:YES];
                       [GTMHTTPFetcher setLoggingToFileEnabled:NO];
                       
                       //创建沙盒必要目录
                       [PathUtil ensureLocalDirsPresent];
                       
                       //初始化数据库引擎
                       SurfDbManager* db = [SurfDbManager sharedInstance];
                       [db initDbWithDelegate:nil];
                       
                       //检测更新
                       [self checkUpdateFromItunes];
                       
                       //刷新splash闪屏画面
                       [self updateSplash];
                       //订阅关系
                       [self checkUpdateSubs];
                       
                       //载入本地热门频道列表
                       //注意：HotChannelsManager-init里面会读取本地记录
                       [self updateHotChannels:handler];
                   });
}

-(void)initAppEnv
{
    // 5.0.0 版本，频道列表参数发生改变，需要删除所有原来本地数据
    NSInteger versionValue = [AppSettings integerForKey:IntKey_5VersionFirstRunFlag];
    if (versionValue == 0) {
        [AppSettings setInteger:1 forKey:IntKey_5VersionFirstRunFlag];
    
        // 清除本地数据(Documents 目录)
        [FileUtil deleteContentsOfDir:[PathUtil documentsPath]];
        
        // 这个版本不支持夜间模式
        [[ThemeMgr sharedInstance] changeNightmode:NO];
    }

    
    presentedVCs = [NSMutableArray new];
    
    //初始化gtm
    [GTMHTTPFetcher setLoggingEnabled:NO];
    [GTMHTTPFetcher setLoggingToFileEnabled:NO];
    
    //创建沙盒必要目录
    [PathUtil ensureLocalDirsPresent];
    
    //初始化数据库引擎
    SurfDbManager* db = [SurfDbManager sharedInstance];
    [db initDbWithDelegate:nil];
    
    //初始化离线下载管理器
    //如果有未完成的解压任务，在初始化过程中将得以完成
    [OfflineDownloader sharedInstance];
    
    // 广告信息
    [[AdvertisementManager sharedInstance] updateAdvertisement];
    
    //用户信息更新
    if ([[UserManager sharedInstance] loginedUser]) {
        [[UserManager sharedInstance] findUserInfowithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
            if (succeeded) {
                [[UserManager sharedInstance] findTasksWithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
                    
                }];
            }
        }];
    }
}

-(void)clearNotifi{
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];//清空通知栏的消息内容
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];//设置应用右上角的数字图标
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
#pragma mark - Update
//这个方法在iPhone版本发布之前只有栏目订阅逻辑
//现在其基础上加入期刊订阅逻辑
//这个代码太乱了
//可是我也不想这样的
//SYZ  2013-06-04
-(void)checkUpdateSubs
{
    //更新用户订阅关系
    SubsChannelsManager* scm = [SubsChannelsManager sharedInstance];
    if ([[scm loadLocalSubsChannels] count] > 0) {
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        if (userInfo) {
            [scm refreshSubsChannelListWithUser:userInfo
                                        handler:nil];
        } else {
            [scm currentUserLoginChanged];
        }
    }
    else
    {
#ifdef ipad
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest: [SurfRequestGenerator getDefaultSubsChannelsListRequest]];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
         {
             if (!error)
             {
                 //将服务器返回的订阅关系存在本地
                 
                 NSString* channelsListBody = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                 SubsChannelsListResponse* channelsList = [EzJsonParser deserializeFromJson:channelsListBody AsType:[SubsChannelsListResponse class]];
                 if (!channelsList.item || [channelsList.item count] == 0)
                 {
                     //无效数据
                     return;
                 }
                 [scm overwriteLocal:channelsList];
             }
             else
             {
                 //获取订阅列表失败
             }
         }];
        
        [[MagazineManager sharedInstance] overwriteLocalMagazines:nil];  //没有默认的期刊订阅
#else
        
      //iPhone1.1.0版本之后加入了订阅栏目推荐功能,不再给用户6个默认订阅
        // 2015.10.13 5.0.1 modify by xuxg 期刊已经关闭，不在维护，
//        [AppSettings setBool:YES forKey:BoolKeyShowSubsPrompt];
//        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
//        if (userInfo) {
//            [[MagazineManager sharedInstance] refreshMagazineListWithUser:userInfo
//                                                                  handler:^(BOOL succeeded) {}
//            ];
//        } else {
//            [[MagazineManager sharedInstance] currentUserLoginChanged];
//        }
#endif
    }
}

//更新闪屏画面
-(void)updateSplash
{
    id req = [SurfRequestGenerator updateSplashRequest];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    fetcher.servicePriority = 1; // 这个不是很紧急，设置一个低得优先级
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         if(!error)
         {
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             UpdateSplashResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[UpdateSplashResponse class]];

             NSString* splashNewsImagePath = [PathUtil pathOfSplashNewsImage];
             NSString* splashDataFilePath = [PathUtil pathOfSplashDataFile];
             
             NSFileManager* fm = [NSFileManager defaultManager];
             if(!resp.startscreen)
             {
                 ////移除所有的闪屏数据
                 [FileUtil deleteDirAndContents:[[PathUtil rootPathOfOthers] stringByAppendingPathComponent:@"newsthread"]];
                 [fm removeItemAtPath:splashNewsImagePath error:nil];
                 [fm removeItemAtPath:splashDataFilePath error:nil];
             }
             else
             {
                 SplashData* remote = resp.startscreen;
                
                 SplashData* local = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:splashDataFilePath encoding:NSUTF8StringEncoding error:nil] AsType:[SplashData class]];
                 
                 BOOL needToDownloadSplashNewsImage = NO; //是否需要下载新闻开机图
                 BOOL needToSaveThreadInfo = NO;    //是否需要将新闻帖子信息覆盖到本地
                 
                 if(!local)
                 {
                     //无本地协议数据
                     //直接将remote端的存至本地
                     [[EzJsonParser serializeObjectWithUtf8Encoding:remote] writeToFile:splashDataFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                     
                     NSDate* now = [NSDate date];
                     NSDate* expiredTo = [NSDate dateWithTimeIntervalSince1970:[remote.newsend longLongValue] / 1000];
                     if ([now compare:expiredTo] == NSOrderedAscending) //尚未过期
                     {
                         //处理开机图
                         if(remote.newsImage && ![remote.newsImage isEmptyOrBlank])
                             needToDownloadSplashNewsImage = YES;
                         
                         if(remote.openType == 0 && remote.infoNews)
                             needToSaveThreadInfo = YES;
                     }
                 }
                 else   //有本地协议数据
                 {
                     //发生更改，则更新本地协议数据文件
                     if(![remote isEqualToSplashData:local])
                     {
                         [[EzJsonParser serializeObjectWithUtf8Encoding:remote] writeToFile:splashDataFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                     }
                     
                     NSDate* now = [NSDate date];
                     NSDate* expiredTo = [NSDate dateWithTimeIntervalSince1970:[remote.newsend longLongValue] / 1000];
                     if ([now compare:expiredTo] == NSOrderedAscending) //尚未过期
                     {
                         //处理开机图
                         if(remote.newsImage && ![remote.newsImage isEmptyOrBlank] && (![remote.newsImage isEqualToString:local.newsImage] || ![FileUtil fileExists:splashNewsImagePath]))
                             needToDownloadSplashNewsImage = YES;
                         
                         if(remote.openType == 0 && remote.infoNews && ![FileUtil fileExists:[PathUtil pathOfThreadInfo:remote.infoNews]])
                             needToSaveThreadInfo = YES;
                     }
                 }
                 
                 if(needToDownloadSplashNewsImage)
                 {
                     [fm removeItemAtPath:splashNewsImagePath error:nil];
                     ImageDownloadingTask* task = [ImageDownloadingTask new];
                     task.imageUrl = [remote.newsImage completeUrl];
                     task.targetFilePath = splashNewsImagePath;
                     task.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* t)
                     {
                     };
                     [[ImageDownloader sharedInstance] download:task];
                 }
                 
                 if(needToSaveThreadInfo)
                 {
                     if(remote.openType == 0 && remote.infoNews)
                     {
                         //**重要**
//                         remote.infoNews.isFromHotChannel = YES;
                         remote.infoNews.threadM = HotChannelThread;
                         
                         //保存文件
                         [[NSFileManager defaultManager] createDirectoryAtPath:[PathUtil pathOfThread:remote.infoNews] withIntermediateDirectories:YES attributes:nil error:nil];
                         [[EzJsonParser serializeObjectWithUtf8Encoding:remote.infoNews] writeToFile:[PathUtil pathOfThreadInfo:remote.infoNews] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                     }
                 }
             }
         }
     }];
}
-(void)updateHotChannels:(void(^)(BOOL succeed))handler
{
    //如果本地热门频道列表为空（通常情况下为第一次安装运行）
    //则需要立刻刷新一遍数据
 
    HotChannelsManager* hcm = [HotChannelsManager sharedInstance];
    if(!hcm.visibleHotChannels.count)
    {
        [hcm refreshWithCompletionHandler:^(BOOL succeeded,BOOL noChanges)
         {
             if(!succeeded)
             {
                 //获取热门频道列表不成功，认为初始化失败，可能为网络问题或者服务器嗝儿屁
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                                    if(handler)
                                        handler(NO);
                                });
                 
                 dispatch_async(dispatch_get_main_queue(), ^(void){
                     
                 });
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                                    if(handler)
                                        handler(YES);
                                });
             }
         }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if(handler)
                               handler(YES);
                       });
    }
}

#pragma mark - 截图
#ifdef ipad
#else

-(void)screenAddCapture
{
    UIImage *capture = [self capture];
    if (capture)
        [self.screenShotsList addObject:capture];
}
-(void)screenDeleteCapture
{
    if ([self.screenShotsList count]>1) {
        [self.screenShotsList removeLastObject];
    }
}
- (UIImage *)capture
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    _nightModeShadow.hidden = YES;
    CGSize size = self.rootController.view.bounds.size;
    float scale = [UIScreen mainScreen].scale;
    float heightStatusBar = 0.f;
    if (!IOS7) {
      heightStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGRect contentRectToCrop = CGRectMake(0, scale * heightStatusBar,
    size.width * scale,
    size.height * scale - heightStatusBar * scale);
    //CGImageCreateWithImageInRect will retain the original image
    CGImageRef imageRef = CGImageCreateWithImageInRect(img.CGImage, contentRectToCrop);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    if ([mgr isNightmode]) {
        _nightModeShadow.hidden = NO;
    }
    return croppedImage;
}

- (void)checkUpdateFromItunes
{
    [iTunesLookupUtil sharedInstance].isMT = NO;
    [[iTunesLookupUtil sharedInstance] checkUpdate];
}
#endif

- (void)sendThreadToWeinxin:(ThreadSummary *)_thread shareImage:(UIImage *)image
{
    if (_thread) {
        [self sendWeixin:_thread.title description:_thread.desc newsUrl:_thread.newsUrl shareImage:image scene:WXSceneSession];
    }
}

- (void)sendThreadToWeinxinTimeline:(ThreadSummary *)_thread shareImage:(UIImage *)image
{
    if (_thread) {
        [self sendWeixin:_thread.title description:_thread.desc newsUrl:_thread.newsUrl shareImage:image scene:WXSceneTimeline];
    }
}
- (void)sendWeixin:(NSString *)title
       description:(NSString *)desc
           newsUrl:(NSString *)newsUrl
        shareImage:(UIImage *)image
             scene:(NSInteger)scene
{
    if (![WXApi isWXAppInstalled]) {
        [PhoneNotification autoHideWithText:@"您还没有安装微信应用"];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title == nil ? @"" : title;
    
    // 微博对发送内容长度是有限制的120个字符
    if (desc.length > 120) {
        desc = [desc substringToIndex:120];
    }
    message.description = desc == nil ? @"" : desc;
    
    
    if (image) {
        [message setThumbImage:[ImageUtil imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(80.0f, 80.0f) backgroundColor:[UIColor clearColor]]];
    } else {
        [message setThumbImage:[UIImage imageNamed:@"Icon"]];
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = newsUrl == nil ? @"" : newsUrl;
    message.mediaObject = ext;
    
    NSRange range = [title rangeOfString:@"#冲浪快讯# 【美女】"];
    if (range.length >0)
    {
        WXImageObject *iob = [WXImageObject object];
        iob.imageData = UIImagePNGRepresentation(image);
        message.mediaObject = iob;
    }

    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (void)sendImageToWeixin:(NSString *)title
              description:(NSString *)desc
               shareImage:(UIImage *)image
                    scene:(NSInteger)scene
{
    if (![WXApi isWXAppInstalled]) {
        [PhoneNotification autoHideWithText:@"您还没有安装微信应用"];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = !title ? @"" : title;
    
    // 微博对发送内容长度是有限制的120个字符
    if (desc.length > 120) {
        desc = [desc substringToIndex:120];
    }
    message.description = !desc ? @"" : desc;
    
    // 设置缩略图
    if (image) {
        [message setThumbImage:[ImageUtil imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(80.0f, 80.0f) backgroundColor:[UIColor clearColor]]];
    } else {
        [message setThumbImage:[UIImage imageNamed:@"Icon"]];
    }

    // 图片
    WXImageObject *wxImgObj = [WXImageObject object];
    wxImgObj.imageData = UIImagePNGRepresentation(image);
    message.mediaObject = wxImgObj;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = scene;
    [WXApi sendReq:req];
}

//分享给QQ好友
-(void)sendThreadToQQFriend:(ThreadSummary *)thread shareImage:(UIImage *)image
{
    if (thread) {
        [self sendQQ:thread.title description:thread.desc newsUrl:thread.newsUrl shareImage:image type:LFShareToQQfriend];
    }
}
//分享到QQ空间
-(void)sendThreadToQZone:(ThreadSummary *)thread shareImage:(UIImage *)image
{
    if (thread) {
        [self sendQQ:thread.title description:thread.desc newsUrl:thread.newsUrl shareImage:image type:LFShareToQZone];
    }
}
//分享链接
-(void)sendQQ:(NSString *)title
  description:(NSString *)desc
      newsUrl:(NSString *)newsUrl
   shareImage:(UIImage *)image
         type:(LFShareToQQ)type
{
    //判断用户手机上是否安装了QQ
    if (![TencentOAuth iphoneQQInstalled]) {
        [PhoneNotification autoHideWithText:@"您还没有安装QQ应用"];
        return;
    }
    
//    //判断用户是否安装了QZone
//    if (![TencentOAuth iphoneQZoneInstalled]) {
//        NSLog(@"没有安装QQ空间客户端");
//    }
    TencentOAuth * tencentOAuth = [[TencentOAuth alloc]initWithAppId:kQQAppId andDelegate:nil];
    NSLog(@"QQ-appID %@",tencentOAuth.appId);
    NSLog(@"SDK版本号-%@",[TencentOAuth sdkVersion]);
    //确保url存在
    newsUrl = newsUrl == nil ? @"" : newsUrl;
    NSURL * url = [NSURL URLWithString:newsUrl];
    //确保标题存在
    title = title == nil ? @"" : title;
    //确保描述信息存在且正常显示
    if (desc.length > 120) {
        desc = [desc substringToIndex:120];
    }
    desc = desc == nil ? @"" : desc;
    //确保image存在
    NSData * imgData = [NSData data];
    if (image) {
        imgData = UIImagePNGRepresentation([ImageUtil imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(80.0f, 80.0f) backgroundColor:[UIColor clearColor]]);
    } else {
        imgData = UIImagePNGRepresentation([UIImage imageNamed:@"Icon"]);
    }
    //创建准备分享的新闻对象
    QQApiNewsObject * newsObj = [QQApiNewsObject objectWithURL:url title:title description:desc previewImageData:imgData];
    //创建分享请求
    SendMessageToQQReq * request = [SendMessageToQQReq reqWithContent:newsObj];
    //分享到QQ好友
    if (type == LFShareToQQfriend) {
        [QQApiInterface sendReq:request];
    }
    //分享到QQ空间
    else{
        [QQApiInterface SendReqToQZone:request];
    }
}
//分享图片
-(void)sendImageToQQ:(NSString *)title
         description:(NSString *)desc
          shareImage:(UIImage *)image
                type:(LFShareToQQ)type
{
    //判断用户手机上是否安装了QQ
    if (![TencentOAuth iphoneQQInstalled]) {
        [PhoneNotification autoHideWithText:@"您还没有安装QQ应用"];
        return;
    }
    TencentOAuth * tencentOAuth = [[TencentOAuth alloc]initWithAppId:kQQAppId andDelegate:nil];
    NSLog(@"QQ-appID %@",tencentOAuth.appId);
    //确保标题存在
    title = title == nil ? @"" : title;
    //确保描述信息存在且正常显示
    if (desc.length > 120) {
        desc = [desc substringToIndex:120];
    }
    desc = desc == nil ? @"" : desc;
    //图片数据
    NSData * data = UIImagePNGRepresentation(image);
    //用于预览，缩略图
    NSData * imgData = UIImagePNGRepresentation([ImageUtil imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(80.0f, 80.0f) backgroundColor:[UIColor clearColor]]);
    
    //分享到QQ好友
    if (type == LFShareToQQfriend) {
        //创建准备分享的图片对象
        QQApiImageObject * imageObj =
        [QQApiImageObject objectWithData:data
                        previewImageData:imgData
                                   title:title
                             description:desc];
        //创建分享请求
        SendMessageToQQReq * request = [SendMessageToQQReq reqWithContent:imageObj];
        [QQApiInterface sendReq:request];
    }
    //分享到QQ空间
    else{
        NSMutableArray * phoneArr = [NSMutableArray arrayWithObjects:data, nil];
        QQApiImageArrayForQZoneObject * obj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:phoneArr title:title];
        SendMessageToQQReq * request = [SendMessageToQQReq reqWithContent:obj];
        
        [QQApiInterface sendReq:request];
    }
}

#pragma mark WXApiDelegate methods
-(void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode == WXSuccess) {
            [self commitShareOperation];    // 提交分享
            
        } else if (resp.errCode == WXErrCodeCommon) {
            [PhoneNotification autoHideWithText:@"分享出错"];
        } else if (resp.errCode == WXErrCodeUserCancel) {
            [PhoneNotification autoHideWithText:@"已取消"];
        } else if (resp.errCode == WXErrCodeSentFail) {
            [PhoneNotification autoHideWithText:@"分享失败"];
        } else if (resp.errCode == WXErrCodeAuthDeny) {
            [PhoneNotification autoHideWithText:@"授权失败"];
        } else if (resp.errCode == WXErrCodeUnsupport) {
            [PhoneNotification autoHideWithText:@"不支持该分享"];
        }
    }
}

-(void)screenshot{
    UIGraphicsBeginImageContextWithOptions(rootController.view.bounds.size, YES, 2.0);
    [rootController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *iv=[[UIImageView alloc] initWithFrame:theApp.window.frame];
    [iv setImage:uiImage];
    UIView *v=[[UIView alloc] initWithFrame:self.window.frame];
    [v setBackgroundColor:[UIColor clearColor]];
    [v addSubview:iv];
    
    [self.window addSubview:v];
}
#pragma mark Push Notification
- (void)application:(UIApplication*)application  didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //注册成功，将deviceToken保存到应用服务器数据库中
    NSLog(@"[NotificationManager initDeviceToken:deviceToken];");
    [NotificationManager initDeviceToken:deviceToken];
    
    [[NotificationManager sharedInstance] sendNotifiWithDeviceInfo];
    

    // 测试获取token的弹出窗口
//    NSString *token = [NSString stringWithFormat:@"tokenA : %@ ",
//                       [NotificationManager getDeviceToken]];
//    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:token delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//    [alter show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    shouldClearAllNotificationsOnEnterBackground = YES;
    application.applicationIconBadgeNumber = 0;
    NSLog(@"userinfo:%@", userInfo);
    if ([[NotificationManager sharedInstance] getTurnSwitch]) {
        if (userInfo) {
            if (_isShowAlert) {
                return;
            }
            [[NotificationManager sharedInstance] setShowSplashView:NO];
            [[NotificationManager sharedInstance] explainFromUserInfo:userInfo andState:application.applicationState];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DJLog(@"注册远程通知失败 %@", error);
    
    // Code=3010 "模拟器不支持远程通知
    if (error.code != 3010) {
        [self startTimer];
    }
    
    // 测试获取token的弹出窗口
//    NSString *errStr = [NSString stringWithFormat:@"token 获取失败，%@" , error];
//    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:errStr
//                                                   delegate:nil
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:@"取消", nil];
//    [alter show];
}


- (void)startTimer
{
    if(timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
}

- (void)timerFired:(NSTimer *)_timer
{
    NSString *tokenStr = [NotificationManager getDeviceToken];
    if (tokenStr && tokenStr.length > 0){
        [self stopTimer];
    }
    else{
        if ([self hasNotificationsEnabled]) {
            [self registerForPUSHNotifications];
        }
    }

}

- (void)stopTimer
{
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (EVALUATE_TAG == alertView.tag){
        //https://itunes.apple.com/cn/app/chong-lang-kuai-xun-xin-wen/id665795477?mt=8
        if (1 == buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/chong-lang-kuai-xun-xin-wen/id665795477?mt=8"]];

        }
    }
}

- (UIViewController*)topMostVC
{
    id last = [presentedVCs lastObject];
    if(last)
        return last;
    
    //获取rootTab所属的rootVC
    if([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"5.0"]) {
        return rootController.presentedViewController;
    } else {
        return rootController.selectedViewController;
    }
}
- (void)pushTopMostVC:(UIViewController*)vc
{
    [presentedVCs addObject:vc];
}
- (void)popTopMostVC
{
    [presentedVCs removeLastObject];
}

- (UIViewController*)getRootViewControllerFromAppdelegate{
    if (!rootController) {
        rootController = [PhoneRootViewController new];
    }
    self.window.rootViewController = rootController;

    return self.window.rootViewController;
}


-(BOOL)hasNotificationsEnabled
{
    if (IOS8) {
        NSLog(@"%@", [[UIApplication sharedApplication]  currentUserNotificationSettings]);
        //The output of this log shows that the app is registered for PUSH so should receive them
        
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
            return YES;
        }
    }
    else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types != UIRemoteNotificationTypeNone){
            return YES;
        }
    }
    return NO;
}



//注册推送  区分ios8版本
-(void)registerForPUSHNotifications
{
    // 如果是模拟器就不需要注册推送通知
#if !TARGET_IPHONE_SIMULATOR
    if (IOS8) {
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
         UIUserNotificationTypeBadge |
         UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    #endif
}

#pragma mark- 友盟第三方统计初始化
-(void)buildUMeng
{
#if !DEBUG
    // http://dev.umeng.com/analytics/ios-doc/integration
    // reportPolicy :设置发送策略  BATCH（启动时发送）和SEND_INTERVAL（按间隔发送）两种
    // channelId:@"Web" 中的Web 替换为您应用的推广渠道。channelId为nil或@""时，默认会被当作@"App Store"渠道。
    
    
    NSString *umengChannelId = @"";
#if ENTERPRISE
    umengChannelId = @"umeng_enterprise";
#elif JAILBREAK
    umengChannelId = @"umeng_jailbreak";
#endif
    [MobClick startWithAppkey:@"565ec1f4e0f55af2a0000949"
                 reportPolicy:BATCH
                    channelId:umengChannelId];
    // 设置版本号
    NSString *version =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [MobClick setAppVersion:version];
    
    
    /*
    // 友盟集成测试，获取测试机号码
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        StartSuppressPerformSelectorLeakWarning
        deviceID = [cls performSelector:deviceIDSelector];
        EndSuppressPerformSelectorLeakWarning
    }
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
                        options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    DJLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
     
     */
#endif

}

#pragma mark - 分享调用(判断段子频道)
- (void)commitShareOperation {
    if (_jokeThread.isBeauty == 5) {    // 是段子频道
        // 提交点赞
        [SurfRequestGenerator commitUpDownShareWithNewsId:_jokeThread.newsId type:3 withCompletionHandler:^(BOOL successed) {
            if (successed) {
                _jokeThread.shareCount ++;      // 分享次数加一
                [PhoneNotification autoHideWithText:@"分享成功"];
            } else {
                [PhoneNotification autoHideWithText:@"网络异常"];
            }
        }];
    } else {                            // 不是段子频道
        [PhoneNotification autoHideWithText:@"分享成功"];
    }
    
}

@end
