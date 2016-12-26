//
//  SurfRequestGenerator.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadSummary.h"
#import "RealTimeStatisticsRequest.h"
#import "getCollectedModel.h"
#import "VoteMode.h"

@class PhotoCollection;
@class PhotoCollectionChannel;
@class CommentBase;

// 请求扩展
@interface NSMutableURLRequest (SurfNews)
/**
 *  冲浪快讯HTTP userAgent头
 *
 *  @return userAgent 值
 */
+(NSString*)surfNewsUserAgent;


@end


@interface SurfRequestGenerator : NSObject

//获取默认订阅频道列表（供游客使用）
+(NSURLRequest*)getDefaultSubsChannelsListRequest;

//根据用户id获取订阅列表
+(NSURLRequest*)getUserSubsChannelsListRequestByUserId:(long)userId;

+(NSURLRequest*)checkUpgradeRequest;            // 检查更新请求

+(NSURLRequest*)checkUpgradeEnterpriseRequest:(BOOL)autoUpdate;  // 企业版本检查更新请求

// 通过城市ID 更新天气
+(NSURLRequest*) updateWeatherRequestByCityID:(NSString*)cityID serverTime:(NSString*)serverTime;

// 通过GPS经纬度来更新天气
+(NSURLRequest*) updateWeatherRequestByGPS:(double)lng latitude:(double)lat serverTime:(NSString*)serverTime;

//提交用户订阅关系
+ (NSURLRequest*)commitSubsRequestWithUserId:(long)userId
                                       coids:(NSString*)coids;

+ (NSURLRequest*)getSubsCateRequest;

// 更新splash画面
+(NSURLRequest*) updateSplashRequest;

+ (NSURLRequest*)getThreadContentRequest:(ThreadSummary*)thread
                               isCollect:(BOOL)isCollect;

+ (NSURLRequest*)getHotChannelsListRequest;

+ (NSURLRequest*)getHotChannelsThreadsRequestWithChannelId:(long)channelId
                                            newsCount:(NSInteger)newsCount
                                                 page:(NSInteger)page;

// 根据分类id获取频道列表
+(NSURLRequest*) getSubsChannelsRequest:(long)cateId page:(NSInteger)page;

// 获取该推荐订阅频道列表
+(NSURLRequest*) getRecommendSubsChannelsRequest;

// 获取订阅频道的新闻列表
+(NSURLRequest*) getSubsChannelThreadsRequest:(long)channelId
                                        newsCount:(NSInteger)newsCount
                                         page:(NSInteger)page;
// 获取最新订阅列表
+(NSURLRequest*) getSubsChannelNewsRequestScids:(NSString *)scids with:(NSInteger)page;
// 获取搜索订阅列表
+(NSURLRequest*) getSearchSubsChannelRequestName:(NSString *)name with:(NSInteger)page;

// 获取手机报ZIP包
+ (NSURLRequest*)getPhoneNewsZIP:(NSString*)urlString;

// 获取手机报列表
+ (NSURLRequest*)getPhoneNewsList:(NSString *)userId page:(NSUInteger)pageIdx;
// 手机报取消收藏
+ (NSURLRequest*)getPhoneNEwsCancleFavs:(NSString*)userId hashCode:(NSString*)hash;
//用户登录
+(NSURLRequest*)userLoginRequestWithPhoneNum:(NSString*)number password:(NSString*)pwd;
//获取验证码
+(NSURLRequest*)getVerifyCodeWithPhoneNum:(NSString*)number capType:(NSString*)type;
//用户注册
+(NSURLRequest*)userRegisterWithPhoneNum:(NSString*)number password:(NSString*)pwd verify:(NSString*)code;
//重置密码
+(NSURLRequest*)resetPasswordWithPhoneNum:(NSString*)number password:(NSString*)pwd verify:(NSString*)code;

#pragma mark - 段子频道
// 段子频道 赞、踩、分享 请求
+ (NSURLRequest *)getJokeChannelUpDownRequestWithNewsId:(NSInteger)newsId type:(NSInteger)type;

typedef void (^SurfRequestResultHandler)(BOOL successed);

// 提交 赞、踩、分享
+ (void)commitUpDownShareWithNewsId:(NSInteger)newsId type:(NSInteger)type withCompletionHandler:(SurfRequestResultHandler)handler;


#pragma mark - 期刊
//-------------------------------------期刊--------------------------------------
//获取用户期刊订阅关系
+ (NSURLRequest*)getMagazineSubsWithUserId:(NSString*)userId;
//获取期刊列表
+ (NSURLRequest*)getMagazineListWithPage:(NSInteger)page;
//获取一种期刊的期刊列表
+ (NSURLRequest*)getPeriodicalListWithMagazineId:(long)magazineId
                                      serverTime:(long long)serverTime;
//获取期刊的更新期刊列表
+ (NSURLRequest*)getUpdatePeriodicalList:(NSArray *)magazineIdArray;
//获取期刊索引页
+ (NSURLRequest*)getPeriodicalIndexWithMagazineId:(long)magazineId
                                     periodicalId:(long)periodicalId;

+(NSURLRequest *)getPeriodicalContentWithURL:(NSString *)link;

//意见反馈
+(NSURLRequest*) checkFeedBackRequestWithUserId:(NSString *)userId andCont:(NSString *)cont andPhoneNum:(NSString *)phoneNum;

//流量查询
+(NSURLRequest*) checkFindFlowRequestWithUserId:(NSString *)userId andIsAuto:(NSString *)isAutoStr;

// 图集频道列表
+ (NSURLRequest*)photoCollectionChannelList;
// 图集列表
+ (NSURLRequest*)photoCollectionList:(PhotoCollectionChannel*)pcc;
+ (NSURLRequest*)getMorephotoCollectionList:(PhotoCollectionChannel*)pcc page:(NSUInteger)page; // 获取更多图集列表
+ (NSURLRequest*)photoCollectionContent:(PhotoCollection*)pc;// 图集内容

+ (NSURLRequest*)getPhotoCollectionListThreadsRequestWithChannelId:(long)channelId
                                                 newsCount:(NSInteger)newsCount
                                                      page:(NSInteger)page;

// 正文相关推荐是否开启
+ (NSURLRequest*)webContentRecommendIsOpen;

//财经频道股市行情信息接口
+ (NSURLRequest*)stockMarketInfoRequest;

//榜单信息接口
+ (NSURLRequest*)rankingListRequestWithRankType:(NSInteger)type;

// 推送请求
+ (NSURLRequest*)getNotifiRequest;
+ (NSURLRequest*)getNotifiTurnRequest:(BOOL)enable;
+ (NSURLRequest*)getNotifiRequestWithMid:(NSInteger)mid andType:(NSInteger)type;

//嗯，根据用到的URL，我也不知道该起什么函数名，我知道我用来实现一键注册的，嗯，就是这样
+ (NSURLRequest*)quickRegisterRequestWithIdentifier:(NSString *)identifier;

// 广告信息请求
+ (NSURLRequest*)adInfoRequest;

// 分享统计请求
+ (NSURLRequest*)shareCountStatisticsRequestWithActiveId:(NSString *)activeId shareType:(NSInteger)type;

// 分类最新更新新闻
+(NSURLRequest*)classifyUpdateFlag:(NSArray*)magazineIds
                       subcribeIds:(NSArray*)subsIds;


//发送能量值
+(NSURLRequest*)getEnergyRequestWith:(ThreadSummary *)thread andEnergyScore:(long)energyScore;


//发送用户行为统计数据到服务端
+ (NSURLRequest*)getRealTimeUserActionStatisticsRequest:(id)obj andWithType:(RealTimeStatisticType)type;

//美女统计
+ (NSURLRequest*)getRealTimeBelleActionStatisticsRequest:(id)obj andWithType:(RealTimeBelle_Type)type;


//获取个人信息
+ (NSURLRequest*)getFindUserInfoRequest:(NSString *)userId;

//更新个人信息
+ (NSURLRequest*)modifyUserInfoRequestNickName:(NSString *)nickName andSex:(NSString *)Sex;

//上传头像
+ (NSURLRequest *)UpdateImageRequest:(UIImage *)imageData_PNG;


//获取任务列表
+ (NSURLRequest*)findTasksRequest;

//获取金币
+ (NSURLRequest*)postUserScoreRequest;

// 获取新闻评论c2s
+ (NSURLRequest*)getNewsCommentRequest:(ThreadSummary*)ts
                               pageNum:(NSInteger)page;
// 更多热门新闻评论
+ (NSURLRequest*)moreHotNewsCommentRequest:(ThreadSummary*)ts
                                pageNum:(NSInteger)page;
// 提交新闻评论态度
+ (NSURLRequest*)commitCommentAittitude:(CommentBase*)coment;
// 提交新闻评论
+ (NSURLRequest*)commitNewsComment:(ThreadSummary*)thread
                    commentContent:(NSString*)contnet;

// 发现-》搜索新闻
+ (NSURLRequest*)disSearchNews:(NSString*)keyword
                          page:(NSUInteger)page;

// 正文-》举报
+ (NSURLRequest*)newsReport;
// 正文-》提交举报
+ (NSURLRequest*)newsReportSubmit:(ThreadSummary*)ts
                    reportContent:(NSString*)content;
//add duanqi
 //收藏新闻
+ (NSURLRequest*)addCollect:(ThreadSummary*)dic;

//取消收藏
+ (NSURLRequest*)unSubscribeCollect:(ThreadSummary*)dic;

//收藏列表
+ (NSURLRequest*)getCollectedList:(int)currentPage;


//提交投票结果
+ (NSURLRequest*)submitVote:(VoteMode*)vote;
@end
