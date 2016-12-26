//
//  NotificationManager.m
//  SurfNewsHD
//
//  Created by yujiuyin on 13-11-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NotificationManager.h"
#import "GTMHTTPFetcher.h"
#import "ThreadSummary.h"
#import "UserManager.h"
#import "MagazineManager.h"
#import "SubsChannelsManager.h"
#import "AppDelegate.h"
#import "SurfHtmlGenerator.h"
#import "PhoneReadController.h"
#import "FavsManager.h"
#import "AppSettings.h"
#import "Encrypt.h"
#import "WebPeriodicalController.h"
#import "ThreadsManager.h"
#import "PathUtil.h"
#import "NetworkStatusDetector.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "PhoneMagazineController.h"
#import "SNThreadViewerController.h"
#import "NSString+Extensions.h"
#import "PhoneNotification.h"


#define SHOWSPLASH_KEY  @"ShowSplashView"
#define ISGETNOTIFICATION_KEY @"isGetNotification"


@implementation PushNotifiBase

-(id)init{
    self = [super init];
    if (self)
    {
        SurfJsonRequestBase *surfJsonRequestBase=[[SurfJsonRequestBase alloc] init];
        UserInfo *userInfo=[[UserManager sharedInstance] loginedUser];
        
        self.uid=userInfo.userID;
        self.did=surfJsonRequestBase.did;//@"F3CA6932-1C8E-4DE1-B9AD-B7296E20902";
        self.mobile=[Encrypt encryptUseDES:userInfo.phoneNum];
        self.token=[NotificationManager getDeviceToken];
    }
    
    return self;
}
@end

@implementation PushUserInfo

-(id)init{
    self = [super init];
    if (self)
    {
        SurfJsonRequestBase *surfJsonRequestBase=[[SurfJsonRequestBase alloc] init];
        MagazineManager *magazineManager=[MagazineManager sharedInstance];
        SubsChannelsManager *subsChannelManager=[SubsChannelsManager sharedInstance];
        
//        self.periodical=magazineManager.loadLocalMagazineSubs;
//        self.rss=subsChannelManager.loadLocalSubsChannels;

//        NSMutableArray *subMagezineArr=[NSMutableArray new];
        NSMutableString *subMagezineStr=[NSMutableString new];
        for (MagazineSubsInfo *magazineInfo in magazineManager.subsMagazines) {
            if (0==subMagezineStr.length) {
                [subMagezineStr appendString:[NSString stringWithFormat:@"%ld", magazineInfo.magazineId]];
            }
            else{
                [subMagezineStr appendString:[NSString stringWithFormat:@",%ld", magazineInfo.magazineId]];
            }
        }
        
//        NSMutableArray *subChannelArr=[NSMutableArray new];
        NSMutableString *subChannelStr=[NSMutableString new];
        for (SubsChannel *subChannel in subsChannelManager.loadLocalSubsChannels) {
            if (0==subChannelStr.length) {
                [subChannelStr appendString:[NSString stringWithFormat:@"%ld", subChannel.channelId]];
            }
            else{
                [subChannelStr appendString:[NSString stringWithFormat:@",%ld", subChannel.channelId]];
            }
//            [subChannelArr addObject:[NSString stringWithFormat:@"%ld",subChannel.channelId]];
        }
        
        self.periodical=subMagezineStr;
        self.rss=subChannelStr;
        self.city=surfJsonRequestBase.cityId;
    }
    
    return self;
}

@end


@implementation SurfNotifiData
-(id)init{
    self = [super init];
    if (self)
    {
        SurfJsonRequestBase *surfJsonRequestBase=[[SurfJsonRequestBase alloc] init];
        PushUserInfo *pushUserInfo=[[PushUserInfo alloc] init];
        
        self.os=surfJsonRequestBase.os;
        NSInteger width=kContentWidth*1;
        NSInteger height=[[UIScreen mainScreen] applicationFrame].size.height*1;
        self.dm=[NSString stringWithFormat:@"%@*%@",@(width),@(height)];
//        self.dm=[NSString stringWithFormat:@"%f*%f",kContentWidth,[[UIScreen mainScreen] applicationFrame].size.height];
        self.pm=surfJsonRequestBase.pm;
        self.vername=surfJsonRequestBase.vername;
        self.vercode=surfJsonRequestBase.vercode;
        self.userinfo=pushUserInfo;
        self.cid=surfJsonRequestBase.cid;
#ifdef ENTERPRISE
        self.version = @"enterprise";
#endif
        
    }
    
    return self;
}

@end


@implementation SurfNotifiMidData

-(id)init{
    self = [super init];
    if (self)
    {

    }
    
    return self;
}

@end

@implementation SurfChangeData

-(id)initWithEnable:(BOOL)isEnable{
    self = [super init];
    if (self)
    {
        self.enable=isEnable?1:0;
    }
    
    return self;
}

@end


@implementation NotificationManager


static NSString *sDeviceToken = nil;


+ (NotificationManager *)sharedInstance
{
    static NotificationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NotificationManager alloc] init];
    });

    return sharedInstance;
}


-(void)setShowSplashView:(BOOL)isShow{
    showSplash = isShow;
}

-(BOOL)getShowSplashView{
    return showSplash;
}

-(void)sendNotifiWithDeviceInfo{
    NSString *tokenStr = [NotificationManager getDeviceToken];
    if (tokenStr && tokenStr.length > 0) {
        [self httpNotifiRequest:^(BOOL succeeded) {
            if (succeeded) {
                NSLog(@"send DeviceInfo Success");
            }
        }];
    }
    
}

//发送设备信息
-(void)httpNotifiRequest:(void(^)(BOOL succeeded))handler
{
    NSURLRequest *request=[SurfRequestGenerator getNotifiRequest];
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        BOOL succeeded = NO;
        if (!error){
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[_httpFecther response] textEncodingName] convertToStringEncoding]];
            
            SurfJsonResponseBase *resp = [EzJsonParser deserializeFromJson:body AsType:[SurfJsonResponseBase class]];
            if ([resp.res.reCode isEqualToString:@"0"]) {
                succeeded = YES;
            }
        }
        handler(succeeded);
    }];
}

//根据mid获取信息//IOSGetPushMsg
-(void)httpNotifiRequestWith:(long)mid andType:(long)type and:(void(^)(BOOL, NSData*))handler{
    NSURLRequest *request=[SurfRequestGenerator getNotifiRequestWithMid:mid andType:type];
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if (!error){
//            NSLog(@"data: %@",[data description]);
            handler(YES,data);
        }
        else
            handler(NO,Nil);
    }];
}

//要闻推送请求
-(void)httpChangeTurnRequest:(BOOL)inEnable :(void(^)(BOOL succeeded))handler{
    NSURLRequest *request=[SurfRequestGenerator getNotifiTurnRequest:inEnable];
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if (!error){
            
        }
        handler(!error);
    }];
}

+ (void)initDeviceToken:(NSData*)deviceTokenData {
    NSString *tokenStr = [[[[deviceTokenData description]
                            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![tokenStr isEmptyOrBlank]) {
        sDeviceToken = [tokenStr copy];
    }
    else {
        sDeviceToken = @"";
    }
    
    NSLog(@"sDeviceToken:%@", sDeviceToken);
}

+ (NSString*)getDeviceToken {    
    if ([sDeviceToken isEmptyOrBlank]) {
        return @"";
    }
    return sDeviceToken;
}


-(BOOL)getTurnSwitch{
    return [AppSettings boolForKey:ENABLE_STATE];
}
-(void)changeTurnSwitch:(BOOL)isEnable{

    if (isEnable)
        [AppSettings setBool:YES forKey:ENABLE_STATE];
    else
        [AppSettings setBool:NO forKey:ENABLE_STATE];
}

-(void)explainFromUserInfo:(NSDictionary*)userInfo andState:(UIApplicationState)applicationState{
    NSInteger mid = [[userInfo objectForKey:@"mid"] intValue];
    NSInteger mtype = [[userInfo objectForKey:@"type"] intValue];
    /*
     0：新闻正文推送
     1：url推送
     2：图集推送 （暂时不开放）
     3：杂志推送  （与期刊推送共用jumpID，此时只存杂志ID,如：“323553”）
     4: 期刊推送  （与杂志推送共用jumpID，此时存杂志和期刊ID，如：“356345，788565445”）
     5：订阅推送
     */
    [PhoneNotification manuallyHideWithText:nil indicator:YES];
    [[NotificationManager sharedInstance] httpNotifiRequestWith:mid andType:mtype and:^(BOOL success, NSData *dataInfo) {
        [PhoneNotification hideNotification];
        if (success) {
            NSString*st = [[NSString alloc] initWithData:dataInfo encoding:NSUTF8StringEncoding];//NSUTF8StringEncoding NSASCIIStringEncoding kCFStringEncodingGB_2312_80
            if (!st) {
                [PhoneNotification autoHideWithText:@"服务器错误"];
                return;
            }
            NSDictionary*dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            if (-1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                [PhoneNotification autoHideWithText:@"网络错误!"];
                return;
            }
            else{
                if (![dic objectForKey:@"msg"]) {
                    [PhoneNotification autoHideWithText:@"无法获取消息内容!"];
                    return;
                }
                NSInteger msgType = [[dic objectForKey:@"mtype"] intValue];
                if (![[NotificationManager sharedInstance] getShowSplashView] && applicationState ==UIApplicationStateActive) {
                    UIAlertView *alt = nil;
                    if (NEWS_TYPE == msgType) {
                        ThreadSummary *t = [self getThreadFromUserInfo:dic];
                        threadS = t;
                        alt = [[UIAlertView alloc] initWithTitle:t.title message:t.desc delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
                        alt.tag = msgType;
                        [alt show];
                        
                        theApp.isShowAlert = YES;
                    }
                    if (URL_TYPE == msgType) {
                        openNotifi_url = [[dic objectForKey:@"msg"] objectForKey:@"url"];
                        alt = [[UIAlertView alloc] initWithTitle:@"打开链接?" message:openNotifi_url delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
                        alt.tag = msgType;
                        [alt show];
                        theApp.isShowAlert = YES;
                    }
                    else if (PROGRAMA_TYPE == msgType){
                        MagazineInfo *ma = [self getMagazineFromUserInfo:dic];
                        magazine = ma;
                        alt = [[UIAlertView alloc] initWithTitle:nil message:ma.magazineName delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
                        alt.tag = msgType;
                        [alt show];
                        theApp.isShowAlert = YES;
                    }
                    else if (MAGAZINE_TYPE == msgType){
                        PeriodicalInfo *per = [self getPeriodicalInfoFromUserInfo:dic];
                        periodical = per;
                        alt = [[UIAlertView alloc] initWithTitle:nil message:per.periodicalName delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
                        alt.tag = msgType;
                        [alt show];
                        theApp.isShowAlert = YES;
                    }
                    else if (SUB_TYPE == msgType){
                        [PhoneNotification autoHideWithText:@"暂时无法打开 订阅内容"];
                    }
                    else if (IMAGE_TYPE == msgType){
                        [PhoneNotification autoHideWithText:@"暂时无法打开 内容"];
                    }
                    else{
                        [PhoneNotification autoHideWithText:@"暂时无法识别新闻内容"];
                        
                    }
                }
                else{
                    if (NEWS_TYPE == msgType) {
                        [self showNotifiViewCrl:[self getThreadFromUserInfo:dic]];
                    }
                    else if (URL_TYPE == msgType){
                        openNotifi_url = [[dic objectForKey:@"msg"] objectForKey:@"url"];
                        [self showNotifiViewCrl:openNotifi_url];
                    }
                    else if (PROGRAMA_TYPE == msgType){
                        MagazineInfo *ma = [self getMagazineFromUserInfo:dic];
                        magazine = ma;
                        [self showNotifiViewCrl:magazine];
                    }
                    else if (MAGAZINE_TYPE == msgType){
                        periodical = [self getPeriodicalInfoFromUserInfo:dic];
                        [self showNotifiViewCrl:periodical];
                    }
                    else if (SUB_TYPE == msgType){
                        [PhoneNotification autoHideWithText:@"暂时无法打开 订阅内容"];
                    }
                    else if (IMAGE_TYPE == msgType){
                        [PhoneNotification autoHideWithText:@"暂时无法打开 内容"];
                    }
                    else{
                        [PhoneNotification autoHideWithText:@"暂时无法识别新闻内容"];

                    }
                }
            }
        }
        else{
            [PhoneNotification autoHideWithText:@"无法打开此条消息!"];
        }
    } ];

}

//测试打开帖子
-(void)testOpenThread
{
    /*
    //模拟延时弹出对话框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        
        ThreadSummary *t = [[ThreadSummary alloc] init];
        
        t.coid = 4061;
        t.channelType = 0;
        //    t.threadId=[[msg objectForKey:@"id"] longLongValue];
        t.title = @"【假装收到推送】网曝大连轻轨脱轨 事故原因正在调查";
        t.imgUrl = @"http://go.10086.cn/surfnews/images/4061/20140701/513225/m/513225.jpg";
        t.threadId = 513225;
        t.time = 123456789;
        t.newsUrl = @"http://news.163.com/14/0701/13/A02S0DF000014AEE.html";//@"sourceUrl"
        t.source = @"网易";
        t.threadM = HotChannelThread;
        
        [t ensureFileDirExist];
        
        
        threadS = t;
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:t.title message:t.desc delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
        alt.tag = NEWS_TYPE;
        [alt show];
        
        theApp.isShowAlert = YES;
        
        
    });
     */
    
    NSInteger mid = 1462739;
    NSInteger msgType = 0;
    
    [PhoneNotification manuallyHideWithText:nil indicator:YES];
    [[NotificationManager sharedInstance] httpNotifiRequestWith:mid andType:msgType and:^(BOOL success, NSData *dataInfo) {
        [PhoneNotification hideNotification];
        if (success) {
            NSString*st = [[NSString alloc] initWithData:dataInfo encoding:NSUTF8StringEncoding];//NSUTF8StringEncoding NSASCIIStringEncoding kCFStringEncodingGB_2312_80
            if (!st) {
                [PhoneNotification autoHideWithText:@"服务器错误"];
                return;
            }
            NSDictionary*dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            if (-1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                [PhoneNotification autoHideWithText:@"网络错误!"];
                return;
            }
            else{
                if (![dic objectForKey:@"msg"]) {
                    [PhoneNotification autoHideWithText:@"无法获取消息内容!"];
                    return;
                }
                {
                    if (NEWS_TYPE == msgType) {
                        [self showNotifiViewCrl:[self getThreadFromUserInfo:dic]];
                    }
                    else if (URL_TYPE == msgType){
                        openNotifi_url = [[dic objectForKey:@"msg"] objectForKey:@"url"];
                        [self showNotifiViewCrl:openNotifi_url];
                    }
                    else if (PROGRAMA_TYPE == msgType){
                        MagazineInfo *ma = [self getMagazineFromUserInfo:dic];
                        magazine = ma;
                        [self showNotifiViewCrl:magazine];
                    }
                    else if (MAGAZINE_TYPE == msgType){
                        periodical = [self getPeriodicalInfoFromUserInfo:dic];
                        [self showNotifiViewCrl:periodical];
                    }
                    else if (SUB_TYPE == msgType){
                        [PhoneNotification autoHideWithText:@"暂时无法打开 订阅内容"];
                    }
                    else if (IMAGE_TYPE == msgType){
                        [PhoneNotification autoHideWithText:@"暂时无法打开 内容"];
                    }
                    else{
                        [PhoneNotification autoHideWithText:@"暂时无法识别新闻内容"];
                        
                    }
                }
            }
        }
        else{
            [PhoneNotification autoHideWithText:@"无法打开此条消息!"];
        }
    } ];

}

- (void)testOpenUrl{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        openNotifi_url = @"http://baidu.com/";
        
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"打开链接?" message:openNotifi_url delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
        alt.tag = URL_TYPE;
        [alt show];
        
        theApp.isShowAlert = YES;
    });
}

- (void)testOpenPrograma{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        MagazineInfo *maSub = [MagazineInfo new];
        maSub.magazineName = @"每日See";
        maSub.magazineId = 59260253;
        maSub.orderedCount = 7704984;
        maSub.iconUrl = @"http://go.10086.cn/hotpic/201312/19/20131219181712.png";
        maSub.imageUrl = @"http://go.10086.cn/storage/iconf/201407/01/59260253/152300941/1gwBwt5e_3.jpg";
        maSub.publishTime = -1886353792;
        
        magazine = maSub;
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:nil message:maSub.magazineName delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
        alt.tag = PROGRAMA_TYPE;
        [alt show];
        
        theApp.isShowAlert = YES;
    });
}

- (void)testOpenPeriodicalInfo{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        PeriodicalInfo *periodicalInfo = [PeriodicalInfo new];
        periodicalInfo.magazineId = 59260253;
        periodicalInfo.magazineName = nil;
        periodicalInfo.periodicalId = 152300941;
        periodicalInfo.periodicalName = @"每日See7月1日";
        periodicalInfo.publishTime = -255735792;
        periodicalInfo.imageUrl = @"http://go.10086.cn/storage/iconf/201407/01/59260253/152300941/1gwBwt5e_1.jpg";
        
        periodical = periodicalInfo;
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:nil message:periodical.periodicalName delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"显示", nil];
        alt.tag = MAGAZINE_TYPE;
        [alt show];
        
        theApp.isShowAlert = YES;
    });
}


-(ThreadSummary*)getThreadFromUserInfo:(NSDictionary*)dic
{
    ThreadSummary *t = [[ThreadSummary alloc] init];
    NSDictionary*msg = [dic objectForKey:@"msg"];
    
    t.channelId = [[msg objectForKey:@"channelId"] integerValue];
    t.channelType = [[msg objectForKey:@"channelType"] integerValue];
    //    t.threadId=[[msg objectForKey:@"id"] longLongValue];
    t.title = [msg objectForKey:@"title"];
    t.imgUrl = [msg objectForKey:@"imgUrl"];
    t.threadId = [[msg objectForKey:@"newsId"] integerValue];
    t.time = [[msg objectForKey:@"time"] doubleValue];
    t.newsUrl = [msg objectForKey:@"sourceUrl"];
    t.source = [msg objectForKey:@"source"];
    t.threadM = HotChannelThread;

    [t ensureFileDirExist];
    
    return t;
}

-(MagazineInfo*)getMagazineFromUserInfo:(NSDictionary*)dic
{
    MagazineInfo *maSub = [MagazineInfo new];
    NSDictionary*msg = [dic objectForKey:@"msg"];
    maSub.magazineName = [msg objectForKey:@"magazineName"];
    maSub.magazineId = [[msg objectForKey:@"magazineId"] integerValue];
    maSub.orderedCount = [[msg objectForKey:@"subscribeNum"] integerValue];
    maSub.iconUrl = [msg objectForKey:@"subscribeIcon"];
    maSub.publishTime = [[msg objectForKey:@"publishTime"] doubleValue];

    return maSub;
    
    /*
    MagazineSubsInfo *maSub = [MagazineSubsInfo new];
    NSDictionary*msg = [dic objectForKey:@"msg"];
    maSub.desc = [msg objectForKey:@"desc"];
    maSub.name = [msg objectForKey:@"magazineName"];
    maSub.magazineId = [[msg objectForKey:@"magazineId"] longLongValue];
    return maSub;*/
}

-(PeriodicalInfo*)getPeriodicalInfoFromUserInfo:(NSDictionary*)dic{
    NSDictionary*msg = [dic objectForKey:@"msg"];
    PeriodicalInfo *periodicalInfo = [PeriodicalInfo new];
    periodicalInfo.magazineId = [[msg objectForKey:@"magazineId"] integerValue];
    periodicalInfo.magazineName = [msg objectForKey:@"magazineName"];
    periodicalInfo.periodicalId = [[msg objectForKey:@"periodicalId"] integerValue];
    periodicalInfo.periodicalName = [msg objectForKey:@"periodicalName"];
    periodicalInfo.publishTime = [[msg objectForKey:@"publishTime"] longLongValue];
    periodicalInfo.imageUrl = [msg objectForKey:@"imgUrl"];
    return periodicalInfo;
}

-(void)showNotifiViewCrl:(id)notifiData{
    id viewController=nil;
    if ([notifiData isKindOfClass:[ThreadSummary class]]) {
        threadS = (ThreadSummary*)notifiData;
        
        [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:threadS andWithType:kRTS_PushNotify_TextNews and:^(BOOL succeeded) {
            
        }];
        
        SNThreadViewerController* controller = [[SNThreadViewerController alloc] initWithThread:threadS];
        viewController = controller;
    }
    else if ([notifiData isKindOfClass:[NSString class]]){
        
        
        PhoneReadController *controller = [PhoneReadController new];
        controller.webUrl = (NSString*)notifiData;
        viewController = controller;
    }
    else if ([notifiData isKindOfClass:[MagazineSubsInfo class]]){//期刊不带订阅的浏览页
        MagazineSubsInfo *magazineData = (MagazineSubsInfo*)notifiData;
        PastPeriodicalController *controller = [[PastPeriodicalController alloc] init];
        controller.magazine = magazineData;
        viewController = controller;
    }
    else if ([notifiData isKindOfClass:[PeriodicalInfo class]]){//期刊详情
        PeriodicalInfo *periodcalData = (PeriodicalInfo*)notifiData;
        
        [[RealTimeStatisticsManager sharedInstance] sendRealTimeUserActionStatistics:threadS andWithType:kRTS_PushNotify_PeriodicalDetail and:^(BOOL succeeded) {
            
        }];
        
        WebPeriodicalController *controller = [[WebPeriodicalController alloc] init];
        controller.periodicalInfo = periodcalData;
        viewController = controller;
    }
    else if ([notifiData isKindOfClass:[MagazineInfo class]]){//期刊带订阅的浏览页
        MagazineInfo *magaData = (MagazineInfo*)notifiData;
        MagazineInfoController *controller = [[MagazineInfoController alloc] init];
        controller.magazine = magaData;
        viewController = controller;
    }
    
    if (viewController) {
        [self pushViewVrl:viewController];
    }
    
}

- (void)pushViewVrl:(UIViewController *)viewCrl{
    PhoneSurfController* topMostVc = nil;
    topMostVc = (PhoneSurfController*)[theApp topMostVC];
    if (!topMostVc) {
        topMostVc = [self getRootPhoneSurfController];
        if (!topMostVc) {
            [theApp getRootViewControllerFromAppdelegate];
            topMostVc = [self getRootPhoneSurfController];
        }
    }
    if (!topMostVc) {
        [PhoneNotification autoHideWithText:@"暂时无法打开 消息内容"];

    }
    else
        [topMostVc presentController:viewCrl animated:PresentAnimatedStateFromRight];
}

-(PhoneSurfController*)getRootPhoneSurfController{
    UINavigationController* viewCrl1 = [[(PhoneRootViewController*)(theApp.window.rootViewController) viewControllers] firstObject];
    PhoneSurfController* topMostVc = (PhoneSurfController*)(viewCrl1.visibleViewController);
    if (!topMostVc) {
        [self getRootPhoneSurfController];
    }
    return topMostVc;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    theApp.isShowAlert=NO;
    if (1 == buttonIndex) {
        if (NEWS_TYPE == alertView.tag) {
            [self showNotifiViewCrl:threadS];
        }
        else if (URL_TYPE == alertView.tag) {
            [self showNotifiViewCrl:openNotifi_url];
        }
        else if (IMAGE_TYPE == alertView.tag) {
            
        }
        else if (PROGRAMA_TYPE == alertView.tag) {
            [self showNotifiViewCrl:magazine];
            
        }
        else if (MAGAZINE_TYPE == alertView.tag) {
            [self showNotifiViewCrl:periodical];
            
        }
        else if (SUB_TYPE == alertView.tag) {
            
        }
    }
}

- (void)clearRootPathOfNotiFidir{
    [FileUtil deleteContentsOfDir:[PathUtil rootPathOfNotiFidir]];
}

@end