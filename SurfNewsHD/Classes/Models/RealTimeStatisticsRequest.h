//
//  RealTimeStatisticsRequest.h
//  SurfNewsHD
//
//  Created by xuxg on 14-9-11.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"




typedef enum {
    // 新闻列表跳转
    kRTS_NewsList_TextNews = 1001,                     // 新闻列表文本新闻
    kRTS_NewsList_UrlNews,                      // 新闻列表URL新闻
    kRTS_NewsList_Photos,                       // 新闻列表图集新闻
    kRTS_NewsList_Periodical,                   // 新闻列表期刊列表
    
    kRTS_NewsList_RSSList,                      // 新闻列表RSS列表
    
    kRTS_RSSNews = 2001,                               // RSS文本新闻
    kRTS_Photos = 3001,                                // 图集正文
    kRTS_Periodical = 4001,                            // 期刊
    
    // 推送跳转
    kRTS_PushNotify_TextNews = 5001,                   // 推送跳转文本新闻
    kRTS_PushNotify_UrlNews,                   // 推送跳转URL新闻
    kRTS_PushNotify_RSSList,                   // 推送跳转RSS列表
    kRTS_PushNotify_PhotosContent,               // 推送跳转图集正文
    kRTS_PushNotify_PeriodicalDirectory,       // 推送跳转期刊目录
    kRTS_PushNotify_PeriodicalDetail           // 推送跳转杂志详细
} RealTimeStatisticType;



typedef enum {
    // 新闻列表跳转
    kBelleGirl_Refresh = 1,                     // 上拉触发更新
    kBelleGirl_Click,                           // 点击大图
    kBelleGirl_Save,                       // 保存
    kBelleGirl_Intimacy,                   // 亲密度
    kBelleGirl_Hate,                      // 讨厌
    kBelleGirl_Report                        // 举报
} RealTimeBelle_Type;



@interface RealTimeBelleGirlData : SurfJsonRequestBase
@property(nonatomic,strong) NSString *mobile;              // 手机号码
@property(nonatomic,assign) long picId;
@property(nonatomic,assign) long type;

-(id)initWhitThreadSummary:(id)obj andWithType:(RealTimeBelle_Type)belle_type;

@end


// 实时统计接口
@interface RealTimeStatisticsData : SurfJsonRequestBase

@property(nonatomic,strong) NSString *model;            // 类型RealTimeStatisticType
@property(nonatomic,strong) NSString *mob;              // 手机号码
@property(nonatomic,strong) NSString *newsId;           // 新闻id
@property(nonatomic,strong) NSString *referer;          // T+新闻专有字段(如果此值存在)

// 新闻所属频道类型:
// 热推、本地等一般频道此值为0，
// RSS频道此值为1，
// 微精选频道此值为3，
// 视频频道此值为4
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *channelid;        // 频道id
@property(nonatomic,strong) NSString *newsPosition;     // 新闻在新闻列表位置
@property(nonatomic,strong) NSString *channelPosition;  // 频道在频道列表位置
@property(nonatomic,strong) NSString *albumid;          // 对应图集id
@property(nonatomic,strong) NSString *magazineid;       // 期刊id
@property(nonatomic,strong) NSString *periodicalid;     // 期刊下某本杂志的id
@property(nonatomic,strong) NSString *rssJumpid;        // 新闻列表中RSS推荐新闻所要跳转的RSS频道id


-(id)initWhitThreadSummary:(id)obj rtsType:(RealTimeStatisticType)type;

@end



@class GTMHTTPFetcher;

@interface RealTimeStatisticsManager : NSObject



+ (RealTimeStatisticsManager *)sharedInstance;


-(BOOL)isBusy;

- (void)sendRealTimeUserActionStatistics:(id)obj andWithType:(RealTimeStatisticType)type and:(void(^)(BOOL succeeded))handler;

- (void)sendRealTimeBelleGirlActionStatistics:(id)obj andWithType:(RealTimeBelle_Type)type  and:(void(^)(BOOL succeeded))handler;

@end
