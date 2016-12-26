//
//  AppSettings.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h> 


typedef NS_ENUM(NSInteger, ReaderPicMode)
{
    ReaderPicOn = 0,        //自动加载
    ReaderPicOff = 1,       //无图模式
    ReaderPicManually = 2   //手动加载
};


// 添加同类型的key ,如何有默认值，请来Get函数中添加默认值
#define DoubleKey @"key0001"
#define DoubleKey_Ad_UpdateTime @"key0002"    // 正文广告更新本地时间间隔(1970)


#define IntKey @"key0200"
#define IntKey_ReaderPicMode @"key0201"         //正文图片模式
#define IntKey_MainUIUserGuide     @"key0202"      // 主界面用户引导
#define IntKey_MainUIBodyGuide     @"key0203"      // 正文用户引导
#define IntKey_EnergyUIBodyGuide   @"key0204"      // 能量模块cell引导
#define IntKey_5VersionFirstRunFlag @"key0205"      // 5.0.0版本第一次运行标记


#define BoolKey @"key0300"
#define BOOLKEY_NightMode @"key0301"
#define BoolKeyShowSubsPrompt @"key0302"            // 是否显示订阅推荐页面。from 1.1.0+
#define BooLKeyOpenRecommend @"key0303"             // 是否打开相关推荐
#define BOOLKey_AutoRotatePictureEnable @"key0304"  // PictureBox自动旋转开关
#define BOOLKey_ShowQuickRegister   @"key0305"      // 显示一键注册界面
// 本地GPS定位的新闻频道和用户选择的新闻频道不一致的提示框
#define BOOLKey_LocalNewsNotMarch  @"key0306"

#define StringKey @"Key0400"
#define StringKey_UserSelectCityId @"Key0401"       // 用户自己选择的城市ID（天气），默认为nil
#define StringKey_DefaultCityId @"Key0402"          // 默认天气城市ID(北京城市ID)
#define STRINGKEY_SubsChannelsIdsFirstGot @"Key0403"
#define StringKey_UserSelectCityName @"Key0404"     // 用户自己选择的城市天气名称， 默认nil
#define StringKey_DefalutCityName @"Key0405"        // 默认天气城市名称(北京)
#define StringLastRunVersion @"key0406"             // 上一次启动版本
#define StringLastSubsSlideGuideVersion @"key0407"  // 上一次订阅页展示版本
#define StringLastOfflineGuideVersion @"key0408"    // 上一次离线展示版本
#define StringLoginedUser @"key0409"                // 已登录用户
#define StringIMSIPhone @"key0410"                  // IMSI反查手机号
#define StringSMSSendCountIPhone @"key0411"         // 一键注册发送短信次数限制
//added by yuleiming 2014年05月04日
//设备号的本意是为了追踪同一台设备，既然现在获取设备号的机制已经不可靠
//那至少应该保证一次安装周期内是可靠的，所以应该存在配置文件中
#define STRINGKEY_DEVICE_ID @"key0412"              //设备号
#define StringIsShowMarkLogo @"key0413"             //登录过后注销 只显示一次小红点标志
#define StringKey_LocalCity @"key0414"      // 本地城市名
#define StringKey_LocalCityID @"key0415"    // 本地城市ID


#define FloatKey @"key0500"
#define FLOATKEY_ReaderBodyFontSize @"key0501"


#define UrlKey @"key0600"


#define DateKey @"key0700"
#define DateKey_NewestNews @"key0701"       // 最新新闻最后更新时间
#define DateLastRunDate @"key0702"          // 上一次运行时间
#define DateEnergyList_Day @"key0703"       // 日能量榜单刷新时间
#define DateEnergyList_Week @"key0704"      // 周能量榜单刷新时间



#define ENABLE_STATE        @"isEnable"             //要闻推送状态
#define EVALUATE_TAG    8685123                     //评论弹出框tag

@interface AppSettings : NSObject


// 新增加的方法
+ (void)setInteger:(NSInteger)value forKey:(NSString *)keyName;
+ (void)setFloat:(float)value forKey:(NSString *)keyName;
+ (void)setDouble:(double)value forKey:(NSString *)keyName;
+ (void)setBool:(BOOL)value forKey:(NSString *)keyName;
+ (void)setString:(NSString *)value forKey:(NSString *)keyName;
+ (void)setURL:(NSURL *)value forKey:(NSString *)keyName;
+ (void)setDate:(NSDate*)value forkey:(NSString *)keyName;


+ (NSInteger)integerForKey:(NSString *)keyName;
+ (NSString *)stringForKey:(NSString *)keyName;
+ (float)floatForKey:(NSString *)keyName;
+ (double)doubleForKey:(NSString *)keyName;
+ (BOOL)boolForKey:(NSString *)keyName;
+ (NSURL *)urlForKey:(NSString *)keyName;
+ (NSDate*)dateForKey:(NSString *)keyName;

@end
