//
//  SubsChannelsListResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface SubsChannelsListResponse : SurfJsonResponseBase

@property NSString* apicPass;
@property NSString* userId;
@property NSArray* item;

@end


//{"columnId":59334631,"name":"中金财经","desc":"全国领先的网络财经媒体和权威的投资者服务平台。国内知名金融门户网站。","ImageUrl":"201509/23/source59334631.png","indexId":"34","ssCount":1022,"isVisible":1,"payType":0,"rssType":0,"rowNum":1,"isSelected":0,"isPay":0,"periodNum":0},
@interface SubsChannel : NSObject


@property long channelId;
@property NSString* desc;
@property(nonatomic,strong) NSString* ImageUrl;
@property NSString* index;

 //是否可见。有些频道只在wap页面显示，在客户端上不给显示。不可见的频道对于客户端而已，视作未订阅
@property NSString* isVisible;
@property int rssType;                        //1:栏目, 6:刊物
@property NSString* name;
@property int ssCount;
@property int isSelected;                     //推荐栏目订阅 1为选中, 0为不选中

// 订阅频道最新一条栏目新闻（新加字段）
@property long newsId;      // 栏目下最新一条新闻id
@property NSString *newsTitle;   // 栏目下最新一条新闻标题
@property NSString *newsImage;   // 栏目下最新一条新闻缩略图

// 5.0.0 之后不知道怎么用的数据
@property int payType;
@property int rowNum;
@property BOOL isPay;
@property int periodNum;


// 本地属性
//@property int tilesIdx;         // 用来在Tiles控件中排序用。默认为0，数值越大，排序越靠前。
@property long cateId;          // 用来记录当前频道所属的分类id。可能为0
@property NSString* cateName;   // 用来记录当前频道所属的分类名称。可能为null
@property BOOL supportOffLineDownload;// 用来记录当前频道是否支持离线下载。

@property(nonatomic) double time;               //更新日期（since1970，单位为ms）
@property int newThreadSummaryCount;        // iphone中使用，用来表示订阅频道中，有多少条新的帖子详情
//纪录对应hotChannl ID
@property long hotChannelID;
@property double threadsSummaryMaxTime;       // 订阅频道中最大帖子时间



@end