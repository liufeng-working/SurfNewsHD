//
//  HotChannelsListResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface HotChannelBrowsed : NSObject

@property(nonatomic,strong) NSMutableArray * isBrowsed;
@end

@interface HotChannelRec : NSObject

@property long recid;                           // 推荐订阅的栏目id
@property NSInteger channelId;                  // 频道id
@property(nonatomic,strong) NSString* recimg;   // 图片地址
@property(nonatomic,strong) NSString* recname;  // 推荐订阅的名称

-(SubsChannel*)buildSubsChannel;
@end


@interface HotChannel : NSObject


@property NSInteger channelId;
@property NSInteger channelIndex;
@property(nonatomic,strong) NSString *channelName;
@property NSInteger isBeauty;              // 1 是美女或帅哥
@property NSInteger isWidget;
@property NSInteger isnew;    //新闻频道最新新闻显示红点
@property NSInteger openType;
@property NSInteger parent_id;
@property NSInteger position; //0-上；1-下
@property NSInteger type;     //0-热推；1-其他热门频道 4 视频


/**
 *  本地属性区域
 */
@property(nonatomic) CGFloat listScrollOffsetY; /**< 频道ID  用来标记滚动条的位置,不需要保存*/
@property(nonatomic, getter = isRefresh) BOOL refresh; // 标记是否在刷新状态。
@property(nonatomic,strong) NSNumber* updateTime;      // 更新日期（since1970，单位为ms）

// 是否是热推频道
-(BOOL)isHotChannel;

// 是否是订阅频道
-(BOOL)isSubschannel;

// 是否是本地频道
-(BOOL)isLocalChannel;

// 是否是财经频道
-(BOOL)isStockChannel;

// 是否是美女频道
-(BOOL)isBeautifulChannel;

//是否是视频频道
-(BOOL)isVideoChannel;

// 是否是段子频道
- (BOOL)isJokeChannel;

@end

@interface HotChannelsListResponse : SurfJsonResponseBase

@property(nonatomic,strong) NSMutableArray *channelList;        // 频道列表
@property(nonatomic,strong) NSMutableArray *rec ;               // RSS 源

@end
