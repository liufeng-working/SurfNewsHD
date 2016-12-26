//
//  SurfHtmlGenerator.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNewsData.h"
#import "SNNewsContentInfoResponse.h"

//单例
//用于生成正文html
#define IMAGE_URL_ARRAY @"surf://imagearray:"                        //图片数组
#define IMAGE_URL_CLICK_PREFIX @"surf://imageurlclick:"              //点击图片url

#define IMAGE_CLICK_PREFIX @"imageclick://"                         //点击图片，后面紧跟图片的各种参数
#define SOURCE_URL_CLICK_PREFIX @"surf://srcurlclick"               //点击"查看原文"
#define SOURCE_URL_CLICK_ENERGY @"surf://energyclick"               //点击"能量块"
#define RELOAD_CONTENT_CLICK_PREFIX @"surf://reloadcontentclick"    //点击"重新加载正文"
#define Recommend_Click_PREFIX @"surf://recommendClick"             //点击相关推荐
#define Ad_Click_PREFIX @"surf://adClick"                           // 正文广告位
#define Activity_Share_PREFIX @"surfnews-iphone://activity-share"   // 活动分享
#define OPEN_URL_WITH_SAFARI @"safari://"  //调用safari打开链接，后面紧跟url
#define RSS_Subscribe_PREFIX @"surf://rssSubscribe"                 // rss订阅
#define RSS_Click_PREFIX @"surf://clickSubscribe"                   // rss点击
#define Dissertation_PREFIX @"surfnews://" // 专题


#define NightTitleColor @"#aeaeae"          // 夜间模式标题颜色
#define NightBackgroundColor @"#1e1e1e"     // 夜间模式的背景颜色
#define DayTitleColor @"#2f2f2f"            // 白天模式标题颜色
#define DayBackgroundColor @"#fefefe"       // 白天模式的背景颜色
#define SoureFontColor @"#969696"           // 来源字体颜色
#define BodyFontColor @"#474747"            // 内容字体颜色#676767
#define ButtonBackgroundColor @"#b3b3b3"    // 按钮背景颜色
#define recommendHrBorderColor_day @"#EDEDED" // 相关推荐分割线#EDEDED
#define recommendHrBorderColor_night @"#2B2B2B"


//正文Img允许的最大宽度
#ifdef ipad
#define ImgTagMaxWidth 600.0
#else
#define ImgTagMaxWidth 280.0
#endif

@interface SurfHtmlGenerator : NSObject

//生成正文尚未就绪时的html
+ (NSString*)generateWithThread:(ThreadSummary*)thread;

//生成带正文的html
+ (NSString*)generateWithThread:(ThreadSummary*)thread andResolvedContent:(NSString*)content recommendContent:(NSString*)recommends;
+ (NSString*)generateWithNewsData:(PhoneNewsData*)thread andResolvedContent:(NSString*)content;
//+ (NSString*)generateWithThread:(ThreadSummary*)thread andResolvedContentFilePath:(NSString*)path;
+ (NSString *)phoneNewsStyle:(NSString *)content;
@end
