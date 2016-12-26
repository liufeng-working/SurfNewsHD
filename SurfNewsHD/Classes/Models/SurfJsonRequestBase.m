
//
//  SurfJsonRequestBase.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//
#import <dlfcn.h>
#import "SurfJsonRequestBase.h"
#import "UIDevice+Hardware.h"
#import "NSString+Extensions.h"
#import "UserManager.h"
#import "WeatherManager.h"
#import "DeviceIdentifier.h"

static NSString* PM = nil;
static int VERCODE = 0;

@implementation SurfJsonRequestBase

-(id)init
{
    if(self = [super init])
    {
        self.sdkv = [[UIDevice currentDevice] systemVersion];
        self.did = [DeviceIdentifier getDeviceId];
        
        if(!PM)
        {
            //platformString函数比较耗时，必须缓存起来
            PM = [[UIDevice currentDevice] platformString];
        }
        
        self.pm = PM;    //手机型号
#ifdef ipad 
        // ipad
        self.os = @"ipad";
        self.cid = @"3000"; // 要你命3000 渠道id
#else   
        // iphone
        self.os = @"iphone";
        
        // 渠道号
    #ifdef JAILBREAK
        self.cid = JB_CHANNEL_ID;
    #elif ENTERPRISE
        self.cid = @"4sMwssoC";
    #else//JAILBREAK
        self.cid = @"4sBPssPr"; // iphone渠道id
    #endif  //JAILBREAK
        
#endif  //ipad
        
        //self.vercode = CFBundleGetVersionNumber(CFBundleGetMainBundle()); //designed for Android
        
        //形如1.1.2
        self.vername = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        
        if(VERCODE == 0)
        {
            //x.y.z展开为如下规则的vercode
            //x*1000000+y*1000+z
            NSArray* comp = [self.vername componentsSeparatedByString:@"."];
            
            int x = [[comp objectAtIndex:0] intValue];
            int y = [[comp objectAtIndex:1] intValue];
            int z = 0;
            if([comp count] > 2) {
                //x.y，为x.y.0的简写
                z = [[comp objectAtIndex:2] intValue];
            }
            
            VERCODE = x * 1000000 + y * 1000 + z;
        }
        //注：ipad 1.0.0-->1.1.2的vercode固定为111
        //    iphone从1.0.0起都满足当前展开规则
        self.vercode = VERCODE;
        
        
        //cityid 用来定位本地新闻频道
        self.cityId = [AppSettings stringForKey:StringKey_LocalCityID];
        if(!self.cityId || [self.cityId isEmptyOrBlank]) {
            WeatherInfo *curWeather = [[WeatherManager sharedInstance] weatherInfo];
            if (curWeather && ![curWeather.cityId isEmptyOrBlank]) {
                self.cityId = curWeather.cityId;
            }
            else {
                self.cityId = @"";
            }
        }

        
        if ([UserManager sharedInstance].loginedUser) {
            self.uid = [UserManager sharedInstance].loginedUser.userID;
        }
        else{
            self.uid = @"-1";
        }
        
        
//        if (DEBUG) {
//            self.os = @"Android";
//            self.vercode = 91;
//        }
 
    }
    return self;
}


@end
