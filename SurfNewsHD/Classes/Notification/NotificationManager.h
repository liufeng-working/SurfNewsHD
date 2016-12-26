//
//  NotificationManager.h
//  SurfNewsHD
//
//  Created by yujiuyin on 13-11-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"
#import "PhoneSurfController.h"
#import "PictureBox.h"
#import "PhoneShareView.h"
#import "PastPeriodicalCell.h"
#import "GetMagazineListResponse.h"


typedef enum
{
    NEWS_TYPE=0,    //新闻正文推送
    URL_TYPE,       //url推送
    IMAGE_TYPE,     //图集推送 （暂时不开放）
    PROGRAMA_TYPE,  //杂志推送  （与期刊推送共用jumpID，此时只存杂志ID,如：“323553”）,期刊第一层路径,带"添加订阅"按钮的页面(本来不带的,后来又要改).
    MAGAZINE_TYPE,  //期刊推送  （与杂志推送共用jumpID，此时存杂志和期刊ID，如：“356345，788565445”）,期刊详细路径
    SUB_TYPE        //订阅推送
}OPENNOTIFI_TYPE;

@class GTMHTTPFetcher;
@class UserInfo;
@class ThreadSummary;

@interface PushNotifiBase : NSObject
@property NSString*uid;
@property NSString*did;
@property NSString*mobile;
@property NSString*token;

@end

@interface PushUserInfo:NSObject
//@property NSArray*periodical;
//@property NSArray*rss;
@property NSString*periodical;
@property NSString*rss;

@property NSString*city;
@end

@interface SurfNotifiData : PushNotifiBase        //SurfJsonRequestBase
@property NSString*os;
@property NSString*dm;
@property NSString*pm;
@property NSString*vername;
@property NSInteger vercode;
@property NSString*cid;

#ifdef ENTERPRISE
@property NSString *version;
#endif

@property(nonatomic,strong)PushUserInfo*userinfo;

/*
{
    "uid":"isotest",
    "os":"iphone",
    "dm":"480*854",
    "pm":"iphone4s",
    "did":"iosdid",
    "vername":"3.0.1",
    "vercode":42,
    "cid":"11",
    "mobile":"des3加密信息",
    "token":"token信息",
    "userinfo":{
        "periodical":"",
        "rss":"59235127,59229540,59204305,59232681,59205856,59144194,",
        "city":"101010100,"
    }
}*/

@end

@interface SurfNotifiMidData : NSObject
@property NSInteger mid;
@property NSInteger type;
@end


@interface SurfChangeData : PushNotifiBase
@property NSInteger enable;
-(id)initWithEnable:(BOOL)isEnable;
@end

@interface NotificationManager : NSObject{
    BOOL showSplash;
    
    ThreadSummary *threadS;
    MagazineInfo  *magazine;
//    MagazineSubsInfo *magazineSub;
    PeriodicalInfo  *periodical;
    NSString* openNotifi_url;
}

@property(nonatomic,strong)GTMHTTPFetcher *httpFecther;

+ (NotificationManager *)sharedInstance;
-(void)setShowSplashView:(BOOL)isShow;
-(BOOL)getShowSplashView;

-(void)sendNotifiWithDeviceInfo;
-(void)httpNotifiRequest:(void(^)(BOOL succeeded))handler;
-(void)httpChangeTurnRequest:(BOOL)inEnable :(void(^)(BOOL succeeded))handler;
-(void)httpNotifiRequestWith:(long)mid andType:(long)type and:(void(^)(BOOL, NSData*))handler;

-(BOOL)getTurnSwitch;
-(void)changeTurnSwitch:(BOOL)isEnable;

+(NSString*)getDeviceToken;
+(void)initDeviceToken:(NSData*)deviceTokenData;

-(void)explainFromUserInfo:(NSDictionary*)userInfo andState:(UIApplicationState)applicationState;
- (void)clearRootPathOfNotiFidir;

- (void)pushViewVrl:(UIViewController *)viewCrl;

//测试打开推送
- (void)testOpenThread;
- (void)testOpenUrl;
- (void)testOpenPrograma;
- (void)testOpenPeriodicalInfo;



@end