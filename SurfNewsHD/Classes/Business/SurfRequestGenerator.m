//
//  SurfRequestGenerator.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfRequestGenerator.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"
#import "CheckUpgradeRequest.h"
#import "UpdateWeatherRequest.h"
#import "CommitSubsRequest.h"
#import "GetSubsCateRequest.h"
#import "UpdateSplashRequest.h"
#import "GetThreadContentRequest.h"
#import "HotChannelsListRequest.h"
#import "HotChannelsThreadsRequest.h"
#import "SubsChannelsListRequest.h"
#import "SubsChannelsThreadsRequest.h"
#import "NewsTopRequest.h"
#import "PhoneNewsListRequest.h"
#import "SurfAccountRequest.h"
#import "GetMagaZineSubsRequest.h"
#import "GetMagazineListRequest.h"
#import "GetPeriodicalListRequest.h"
#import "GetPeriodicalContentIndexRequest.h"
#import "FeedbackViewController.h"
#import "FeedbackRequest.h"
#import "FindFlowRequest.h"
#import "PhotoCollectionRequest.h"
#import "RecommendSubsChannelRequest.h"
#import "PhotoCollectionData.h"
#import "NotificationManager.h"
#import "CheckRecommendRequest.h"
#import "GetSubsChannelByNameRequest.h"
#import "LongPullServletRequest.h"
#import "stockMarketInfoRequest.h"
#import "ShareCountStatisticsRequest.h"
#import "ClassifyUpdateFlagRequest.h"
#import "RankingInfoRequest.h"
#import "SNPNEView.h"
#import "UserManager.h"
#import "NewsCommentModel.h"
#import "MJExtension.h"
#import "DiscoverSearchNewsRequest.h"
#import "SNReportModel.h"
#import "MyFavMode.h"

#define kTimeoutInterval 30.f




@implementation NSMutableURLRequest (SurfNews)

/**
 *  冲浪快讯HTTP userAgent头
 *
 *  @return userAgent 值
 */
+(NSString*)surfNewsUserAgent
{
    static NSString *userAgent = nil;
    if (userAgent) {
        return userAgent;
    }
    
    
    // 设备名/版本号
    UIDevice* currentDevice = [UIDevice currentDevice];
    NSString *deviceName = [currentDevice model];
    NSString *systemVersion = [currentDevice systemVersion]; // 系统版本号
    
    // app名称，版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *app_build = [infoDictionary objectForKey:(NSString*)kCFBundleVersionKey];
    
    
    NSMutableString *uAgent = [NSMutableString new];
    [uAgent appendString:@"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B329 Safari/8536.25 "];
    
    // 设备信息/版本号
    [uAgent appendFormat:@"%@/%@ ",deviceName, systemVersion];
    
    // 冲浪快讯app信息
    // SurfnewsApp_:新闻正文中，不加载广告标签(服务器判断字段)。
    [uAgent appendFormat:@"%@(%@ SurfnewsApp_)",app_Name, app_build];
    return userAgent=uAgent;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if ([self valueForHTTPHeaderField:@"User-Agent"] == nil) {
            [self setValue:[[self class] surfNewsUserAgent] forHTTPHeaderField:@"User-Agent"];
        }
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    if (self) {
        
        if ([self valueForHTTPHeaderField:@"User-Agent"] == nil) {
            [self setValue:[[self class] surfNewsUserAgent] forHTTPHeaderField:@"User-Agent"];
        }
    }
    return self;
}
@end



@implementation SurfRequestGenerator

+(NSURLRequest*)getDefaultSubsChannelsListRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGetUserSubs]];
    id req = [DefaultSubsChannelsListRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:req];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//因为服务器端的修改,所以这里改成了GetMagazineSubsRequest,不再使用UserSubsChannelsListRequest
+(NSURLRequest*)getUserSubsChannelsListRequestByUserId:(long)userId
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGetUserSubs]];
    id req = [[GetMagazineSubsRequest alloc]initWithUserId:[NSString stringWithFormat:@"%ld",userId]];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:req];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+(NSURLRequest*) checkUpgradeRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSoftUpdate]];
    id check = [CheckUpgradeRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:check];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+(NSURLRequest*) checkUpgradeEnterpriseRequest:(BOOL)autoUpdate
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kENTERPRISE_Update_Url]];
    CheckUpgradeRequest* check = [CheckUpgradeRequest new];
    check.reqType = autoUpdate ? 0 : 1;
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:check];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 通过城市ID，更新天气信息
+(NSURLRequest*) updateWeatherRequestByCityID:(NSString*)cityID
                                   serverTime:(NSString*)serverTime
{
    NSURL *url = [NSURL URLWithString:kWeatherServer];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];    
    id weather = [[UpdateWeatherRequestByCityId alloc] initWithCityID:cityID
                                                           serverTime:serverTime];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:weather];   
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 通过GPS，更新天气信息
+(NSURLRequest*) updateWeatherRequestByGPS:(double)lng
                                  latitude:(double)lat
                                serverTime:(NSString*)serverTime
{
    NSURL *url = [NSURL URLWithString:kWeatherServer];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id weather = [[UpdateWeatherRequestByGPS alloc] initWithGPS:lng
                                                       latitude:lat
                                                     serverTime:serverTime];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:weather];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = 15.f;
    return request;
}

+ (NSURLRequest*)commitSubsRequestWithUserId:(long)userId
                                       coids:(NSString*)coids
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kUpdateSSRela4IOS]];
    CommitSubsRequest *commit = [[CommitSubsRequest alloc] initWithUserId:userId coids:coids];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:commit];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 获取频道分类列表
+ (NSURLRequest*)getSubsCateRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kFindSSCate]];
    id getSubsCate = [GetSubsCateRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getSubsCate];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 更新splash画面
+(NSURLRequest*) updateSplashRequest
{
    NSURL* url = [NSURL URLWithString:kStartScreen];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];    
    id splash = [UpdateSplashRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:splash];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)getThreadContentRequest:(ThreadSummary*)thread
                               isCollect:(BOOL)isCollect
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:!isCollect?kGetContentService:kGetCollectContent]];
    id getThreadContent = [[GetThreadContentRequest alloc] initWithThread:thread];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getThreadContent];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

/**
 * 请求新闻频道列表
 *
 *  @return 请求数据
 */
+ (NSURLRequest*)getHotChannelsListRequest
{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kFindInfoCate]];
    id hotChannelsList = [HotChannelsListRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:hotChannelsList];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)getHotChannelsThreadsRequestWithChannelId:(long)channelId
                                            newsCount:(NSInteger)newsCount
                                                 page:(NSInteger)page
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kFindInfoNByCoid]];
    id getHotChannelsThreads = [[HotChannelsThreadsRequest alloc] initWithChannelId:channelId newsCount:newsCount page:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getHotChannelsThreads];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 根据分类id获取频道列表 
+ (NSURLRequest*)getSubsChannelsRequest:(long)cateId page:(NSInteger)page
{
    NSURL* url = [NSURL URLWithString:kFindSSChByCoid];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id categoryId = [[SubsChannelsListRequest alloc] initWithCateId:cateId page:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:categoryId];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 获取该推荐订阅频道列表
+(NSURLRequest*) getRecommendSubsChannelsRequest
{
    NSURL* url = [NSURL URLWithString:kFindSSRecommend];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id recommend = [RecommendSubsChannelRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:recommend];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 获取搜索订阅列表
+(NSURLRequest*) getSearchSubsChannelRequestName:(NSString *)name
                                            with:(NSInteger)page
{
    NSURL* url = [NSURL URLWithString:kFindSSChByName];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id channels = [[GetSubsChannelByNameRequest alloc] initWithName:name page:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:channels];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedGbkString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 获取订阅频道的新闻列表
+ (NSURLRequest*)getSubsChannelThreadsRequest:(long)channelId
                                    newsCount:(NSInteger)newsCount
                                         page:(NSInteger)page
{
    NSURL* url = [NSURL URLWithString:kFindSSNByCoid];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    id channels = [[SubsChannelsThreadsRequest alloc] initWithChannelId:channelId
                                                         newsCount:newsCount
                                                              page:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:channels];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}


// 获取最新订阅列表
+(NSURLRequest*) getSubsChannelNewsRequestScids:(NSString *)scids
                                           with:(NSInteger)page
{
    NSURL *url = [NSURL URLWithString:kFindSSLastNews];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id newsTop = [[NewsTopRequest alloc] initWithScids:scids with:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:newsTop];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:kTimeoutInterval];
    return request;
}

// 获取手机报列表
+ (NSURLRequest*)getPhoneNewsList:(NSString *)userId page:(NSUInteger)pageIdx{
    NSURL *url = [NSURL URLWithString:kPhoneNewList];
    PhoneNewsListRequest *newsList = [[PhoneNewsListRequest alloc] initWithUid:userId page:pageIdx];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:newsList];    
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 手机报取消收藏
+ (NSURLRequest*)getPhoneNEwsCancleFavs:(NSString*)userId hashCode:(NSString*)hash{
    NSURL *url = [NSURL URLWithString:kPhoneNewCancleFav];
    PhoneNewsCancelFavsRequest *cancelReq = [[PhoneNewsCancelFavsRequest alloc] initWithUid:userId hashcode:hash];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:cancelReq];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;    
}
// 获取手机报ZIP包
+ (NSURLRequest*)getPhoneNewsZIP:(NSString*)urlString{
    if (urlString.length <= 0) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 20.0f;
    return  request;
}

//用户登录
+(NSURLRequest*)userLoginRequestWithPhoneNum:(NSString*)number password:(NSString*)pwd
{
    NSURL *url = [NSURL URLWithString:kUserLogin];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id login = [[SurfLoginRequest alloc] initWithPhoneNum:number password:pwd];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:login];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}
//获取验证码
+(NSURLRequest*)getVerifyCodeWithPhoneNum:(NSString*)number capType:(NSString*)type
{
    NSURL *url = [NSURL URLWithString:kGeVerifyCode];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id getVerifyCode = [[SurfGetVerifyCodeRequest alloc] initWithPhoneNum:number capType:type];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getVerifyCode];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//用户注册
+(NSURLRequest*)userRegisterWithPhoneNum:(NSString*)number password:(NSString*)pwd verify:(NSString*)code
{
    NSURL *url = [NSURL URLWithString:kRegisterUser];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id registerUser = [[SurfRegisterUserRequest alloc] initWithPhoneNum:number
                                                               password:pwd
                                                                 verify:code];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:registerUser];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//重置密码
+(NSURLRequest*)resetPasswordWithPhoneNum:(NSString*)number password:(NSString*)pwd verify:(NSString*)code
{
    NSURL *url = [NSURL URLWithString:kResetPassword];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id resetPwd = [[SurfResetPwdRequest alloc] initWithPhoneNum:number
                                                       password:pwd
                                                         verify:code];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:resetPwd];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

#pragma mark - 赞、踩、分享 http
// 段子频道 赞、踩、分享 请求
+ (NSURLRequest *)getJokeChannelUpDownRequestWithNewsId:(NSInteger)newsId type:(NSInteger)type {
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kUpDownShareNews]];
    NSString* json = [NSString stringWithFormat:@"{\"newsId\":\"%ld\",\"type\":\"%ld\"}", (long)newsId, (long)type];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 段子频道提交 赞、踩、分享
+ (void)commitUpDownShareWithNewsId:(NSInteger)newsId type:(NSInteger)type withCompletionHandler:(SurfRequestResultHandler)handler {
    id req = [SurfRequestGenerator getJokeChannelUpDownRequestWithNewsId:newsId type:type];
    
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        if(!error) {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            
            // json to model
            SurfJsonResponseBase *resp =
            resp = [SurfJsonResponseBase objectWithKeyValues:body];
            if ([resp.res.reCode isEqualToString:@"1"]) {
                handler(YES);   // 正确提交成功
            } else {
                handler(NO);    // 提交出现错误
            }
            
        } else {
            handler(NO);        // 服务器请求出错
        }
    }];
}

//-------------------------------------期刊--------------------------------------
//获取用户期刊订阅关系
+ (NSURLRequest*)getMagazineSubsWithUserId:(NSString*)userId
{
    NSURL *url = [NSURL URLWithString:kGetUserSubs];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id getMagazineSubs = [[GetMagazineSubsRequest alloc] initWithUserId:userId];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getMagazineSubs];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//获取期刊列表
+ (NSURLRequest*)getMagazineListWithPage:(NSInteger)page
{
    NSURL *url = [NSURL URLWithString:kGetMagazineList];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id getMagazineList = [[GetMagazineListRequest alloc] initWithPage:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getMagazineList];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//获取一种期刊的期刊列表
+ (NSURLRequest*)getPeriodicalListWithMagazineId:(long)magazineId
                                      serverTime:(long long)serverTime
{
    NSURL *url = [NSURL URLWithString:kGetPeriodicalList];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id getPeriodicalList = [[GetPeriodicalListRequest alloc] initWithMagazineId:magazineId
                                                                     serverTime:serverTime];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getPeriodicalList];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//获取期刊的更新期刊列表
+ (NSURLRequest*)getUpdatePeriodicalList:(NSArray *)magazineIdArray
{
    NSURL *url = [NSURL URLWithString:kGetUpdatePeriodicalList];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id getPeriodicalList = [[GetUpdatePeriodicalListRequest alloc] initWithMagazineIdArray:magazineIdArray];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getPeriodicalList];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//获取期刊索引页
+ (NSURLRequest*)getPeriodicalIndexWithMagazineId:(long)magazineId
                                      periodicalId:(long)periodicalId
{
    
    
    NSURL *url = [NSURL URLWithString:kGetPeriodicalContentIndex];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

    id getPeriodicalList = [[GetPeriodicalContentIndexRequest alloc] initWithPeriodicalIndexWithMagazineId:magazineId
                                                                     periodicalId:periodicalId];
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getPeriodicalList];
    NSString* post = [@"jsonRequest=" stringByAppendingString:json];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;

}
+(NSURLRequest *)getPeriodicalContentWithURL:(NSString *)link
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+(NSURLRequest*) checkFeedBackRequestWithUserId:(NSString *)userId andCont:(NSString *)cont andPhoneNum:(NSString *)phoneNum
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDeskViewsAdd]];
    id check = [[FeedbackRequest alloc] initWithUserId:userId andCont:cont andPhoneNum:phoneNum];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:check];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedGbkString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+(NSURLRequest*) checkFindFlowRequestWithUserId:(NSString *)userId andIsAuto:(NSString *)isAutoStr
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kFindflow]];
    id check = [[FindFlowRequest alloc] initWithUserId:userId andISauto:isAutoStr];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:check];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 图集频道列表
+ (NSURLRequest*)photoCollectionChannelList{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kPhotoCollectionChannelList]];
    id listData = [PhotoCollectionChannelListRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:listData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}
// 图集列表
+ (NSURLRequest*)photoCollectionList:(PhotoCollectionChannel*)pcc{
    return [self getMorephotoCollectionList:pcc page:1];   
}
// 获取更多图集列表
+ (NSURLRequest*)getMorephotoCollectionList:(PhotoCollectionChannel*)pcc page:(NSUInteger)page
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kPhotoCollectionList]];
    PhotoCollectionListRequest *listData = [[PhotoCollectionListRequest alloc] initWithCoid:pcc.cid];
    listData.page = page;    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:listData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}
// 图集内容
+ (NSURLRequest*)photoCollectionContent:(PhotoCollection*)pc
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kPhotoCollectionContent]];
    PhotoCollectionContentRequest *listData = [[PhotoCollectionContentRequest alloc] initWithPhotoCollection:pc];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:listData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)getPhotoCollectionListThreadsRequestWithChannelId:(long)channelId
                                                         newsCount:(NSInteger)newsCount
                                                              page:(NSInteger)page{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kPhotoCollectionList]];
    id getHotChannelsThreads = [[PhotoCollectionListRequest alloc] initWithChannelId:channelId newsCount:newsCount page:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:getHotChannelsThreads];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//发送推送设备相关数据
+ (NSURLRequest*)getNotifiRequest{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@IOSMsgPush", PUSHURL]]];
    id notifiData = [[SurfNotifiData alloc] init];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:notifiData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}
//根据mid获取信息//IOSGetPushMsg
+ (NSURLRequest*)getNotifiRequestWithMid:(NSInteger)mid andType:(NSInteger)type{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@IOSGetPushMsg", PUSHURL]]];
    SurfNotifiMidData* notifiData = [[SurfNotifiMidData alloc] init];
    notifiData.mid=mid;
    notifiData.type=type;
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:notifiData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//发送要闻推送
+ (NSURLRequest*)getNotifiTurnRequest:(BOOL)enable{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@IOSPushEnable", PUSHURL]]];//kNotifiTurnInfo
    id notifiData = [[SurfChangeData alloc] initWithEnable:enable];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:notifiData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 正文相关推荐是否开启
+ (NSURLRequest*)webContentRecommendIsOpen
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kCheckRecommendIsOpen]];
    id recommend = [CheckRecommendRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:recommend];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//财经频道股市行情信息接口
+ (NSURLRequest*)stockMarketInfoRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kStockMarketInfo]];
    id recommend = [stockMarketInfoRequest new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:recommend];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//榜单信息接口
+ (NSURLRequest*)rankingListRequestWithRankType:(NSInteger)type{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kRankingList]];
    id recommend = [[RankingInfoRequest alloc] initWithRankType:type];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:recommend];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}


+ (NSURLRequest*)quickRegisterRequestWithIdentifier:(NSString *)identifier
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLongPullServlet]];
    id servlet = [[LongPullServletRequest alloc] initWithIdentifier:identifier];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:servlet];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = 180;   //长链接，这里设定为3分钟
    return request;
}

// 广告信息请求
+ (NSURLRequest*)adInfoRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAdInfoUrl]];
    id obj = [SurfJsonRequestBase new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:obj];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (NSURLRequest*)shareCountStatisticsRequestWithActiveId:(NSString *)activeId shareType:(NSInteger)type
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kShareCountStatisticsUrl]];
    id obj = [[ShareCountStatisticsRequest alloc] initWithActiveId:activeId shareType:type];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:obj];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

// 分类更新标记
+(NSURLRequest*)classifyUpdateFlag:(NSArray*)magazineIds
                       subcribeIds:(NSArray*)subsIds
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kClassifyFlag]];
    id obj = [ClassifyUpdateFlagRequest new];
    if ([magazineIds count] > 0) {
        [obj setMids:[magazineIds componentsJoinedByString:@","]];
    }
    if ([subsIds count] > 0) {
        [obj setCoids:[subsIds componentsJoinedByString:@","]];
    }
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:obj];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+(NSURLRequest*)getEnergyRequestWith:(ThreadSummary *)thread andEnergyScore:(long)energyScore{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kEnergy_Url]];
    id notifiData = [[EnergyDataRequest alloc] initWithThreadSummary:thread andEnergyScore:energyScore];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:notifiData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
    
}

//发送用户行为统计数据到服务端
+ (NSURLRequest*)getRealTimeUserActionStatisticsRequest:(id)obj andWithType:(RealTimeStatisticType)type{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kRealTimeUserActionStatistics_Url]];
    id notifiData = [[RealTimeStatisticsData alloc] initWhitThreadSummary:obj rtsType:type];
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:notifiData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//美女行为统计数据到服务端
+ (NSURLRequest*)getRealTimeBelleActionStatisticsRequest:(id)obj andWithType:(RealTimeBelle_Type)type{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kRealTimeBelleGirlUserActionStatistics_Url]];
    id notifiData = [[RealTimeBelleGirlData alloc] initWhitThreadSummary:obj andWithType:type];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:notifiData];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)getFindUserInfoRequest:(NSString *)userId{
    NSURL *url = [NSURL URLWithString:kUserInfo];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id login = [[SurfGetUserInfoRequest alloc] initWithUserId:userId];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:login];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}


+ (NSURLRequest*)modifyUserInfoRequestNickName:(NSString *)nickName andSex:(NSString *)Sex{
    NSURL *url = [NSURL URLWithString:kModifyUserInfo];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id login = [[SurfModifyUserInfoRequest alloc] initWithNickName:nickName andSex:Sex];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:login];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedGbkString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest *)UpdateImageRequest:(UIImage *)imageData_PNG{
    NSData *data = UIImagePNGRepresentation(imageData_PNG);

    NSString *urlStr = [NSString stringWithFormat:@"http://go.10086.cn/surfnews/suferDeskInteFace/uploadHeadPicService"];
    
    //112.4.128.215:18022
    //192.168.10.125:8080
    //go.10086.cn
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];

    
    NSMutableData *body = [[NSMutableData alloc] init];
    
    NSString *boundary = @"---------------------------7da2137580612";

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    //uid
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:
     [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: text/plain\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"content-transfer-encoding: quoted-printable\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", [[UserManager sharedInstance] loginedUser].userID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //image
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *temp = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"useravatar.png\"\r\n"];
    [body appendData:[[NSString stringWithString:temp] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
//    NSString *result = [[NSString alloc] initWithData:body  encoding:NSASCIIStringEncoding];
//    NSLog(@"result: %@", result);
    
    [request setHTTPBody:body];

    
    
    request.timeoutInterval = kTimeoutInterval;
    return request;

}

+ (NSURLRequest*)findTasksRequest{
    NSURL *url = [NSURL URLWithString:kFindTasks];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id login = [[SurfFindTasksRequest alloc] init];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:login];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)postUserScoreRequest{
    NSURL *url = [NSURL URLWithString:kPostUserScore];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    id login = [[SurfPostUserScoreRequest alloc] init];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:login];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 获取新闻评论c2s
+ (NSURLRequest*)getNewsCommentRequest:(ThreadSummary*)ts
                               pageNum:(NSInteger)page
{
    NSURL *url = [NSURL URLWithString:kGetNewsCommentsUI_Url];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NewsCommentRequest *comment = [[NewsCommentRequest alloc] initWithThreadSummary:ts pageNum:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:comment];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

/**
 *  获取更多热门新闻评论
 *
 *  @param ts 帖子信息
 *
 *  @return HTTP请求
 */
+ (NSURLRequest*)moreHotNewsCommentRequest:(ThreadSummary*)ts
                                pageNum:(NSInteger)page
{
    NSURL *url = [NSURL URLWithString:kMoreNewsComments_Url];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NewsCommentRequest *comment = [[NewsCommentRequest alloc] initWithThreadSummary:ts pageNum:page];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:comment];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 提交新闻评论态度
+ (NSURLRequest*)commitCommentAittitude:(CommentBase*)comment
{
    NSURL *url = [NSURL URLWithString:kComments_Attitude_Url];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NewsCommentAttitudeRequest *att = [NewsCommentAttitudeRequest new];
    att.newsId = comment.newsid;
    att.commentId = comment.commentId;
    att.coid = comment.coid;
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:att];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

/**
 *  提交新闻评论
 *
 *  @param comment 新闻帖子信息
 *
 *  @return URLRequest
 */
+ (NSURLRequest*)commitNewsComment:(ThreadSummary*)thread
                    commentContent:(NSString*)contnet
{
    NSURL *url = [NSURL URLWithString:kCommitNewsComment];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    CommitNewsCommentRequest *commitComment = [CommitNewsCommentRequest new];
    commitComment.newsId = thread.threadId;
    commitComment.coid = thread.channelId;
    commitComment.content = contnet;
    NSString* json =
    [EzJsonParser serializeObjectWithUtf8Encoding:commitComment];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedGbkString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}


// 发现-》搜索新闻
+ (NSURLRequest*)disSearchNews:(NSString*)keyword
                          page:(NSUInteger)page
{
    NSURL *url = [NSURL URLWithString:kDis_SearchNews];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    DiscoverSearchNewsRequest *search = [DiscoverSearchNewsRequest new];
    search.keyword = keyword;
    search.page = page;
    NSString* json =
    [EzJsonParser serializeObjectWithUtf8Encoding:search];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedGbkString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

// 正文-》获取举报内容
+ (NSURLRequest*)newsReport
{
    SurfJsonRequestBase *report = [SurfJsonRequestBase new];
    NSString* json =
    [EzJsonParser serializeObjectWithUtf8Encoding:report];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    
    NSMutableString *urlStr =
    [NSMutableString stringWithString:kNewsReport];
    [urlStr appendFormat:@"&%@",post];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = kTimeoutInterval;
    urlStr = nil;
    return request;
}


// 正文-》提交举报
+ (NSURLRequest*)newsReportSubmit:(ThreadSummary*)ts
                    reportContent:(NSString*)content
{
    SNReportSubmitRequest *report = [SNReportSubmitRequest new];
    report.channelId = ts.channelId;
    report.newsId = ts.threadId;
    report.newsTitle = ts.title;
    report.content = content;

    
    
    NSURL *url = [NSURL URLWithString:kNewsReportSubmit];
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:url];
    
    
    NSString* json =
    [EzJsonParser serializeObjectWithUtf8Encoding:report];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedGbkString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}
//add duanqi
//收藏新闻
+ (NSURLRequest*)addCollect:(ThreadSummary*)ts
{

    NSURL *url = [NSURL URLWithString:kNewsAddCollect];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
   
    MyFavMode *report = [MyFavMode new];
    report.coid = ts.channelId;
    report.newsId = ts.threadId;
    
    if (ts.threadM == SubChannelThread) {
        report.type = 1;
    }
    else
    {
        report.type = ts.ctype;
    }

    
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:report];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)unSubscribeCollect:(ThreadSummary*)ts
{
    
    NSURL *url = [NSURL URLWithString:kNewsUnSubscribeCollect];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    MyFavMode *report = [MyFavMode new];
    report.coid = ts.channelId;
    report.newsId = ts.threadId;
    if (ts.threadM == SubChannelThread) {
        report.type = 1;
    }
    else
    {
        report.type = ts.ctype;
    }
    
    
    
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:report];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

+ (NSURLRequest*)getCollectedList:(int)currentPage
{
    
    NSURL *url = [NSURL URLWithString:kNewsGetCollectedList];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    getCollectedModel *report = [getCollectedModel new];
    report.page = currentPage;
    report.count = 10;
    
    
    
    
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:report];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

//提交投票结果
+ (NSURLRequest*)submitVote:(VoteMode*)vote
{
    NSURL *url = [NSURL URLWithString:kNewsVote];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:vote];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}
@end
