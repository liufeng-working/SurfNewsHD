//
//  SNNewsContentInfoResponse.h
//  SurfNewsHD
//
//  Created by XuXg on 15/7/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

// 新闻推荐信息
@interface SNRecommendationInfo : NSObject

@property(nonatomic,strong) NSNumber *channelId;     /**< 频道ID */
@property(nonatomic,strong) NSNumber *newsId;        /**< 新闻ID */
@property(nonatomic,strong) NSNumber *updateTime;    /**< 更新时间 */
@property(nonatomic,strong) NSString *newsTitle;     /**< 新闻标题 */
@property(nonatomic,strong) NSNumber *newsType;      /**< 新闻类型 */
@property(nonatomic,strong) NSString *content_url;   /**< 新闻链接 */
@property(nonatomic,strong) NSString *source;        /**< 来源 */
@property(nonatomic,strong) NSString *channelName;   /**< 频道名称 */
@end


@interface SNVoteInfo : NSObject
@property(nonatomic,strong) NSNumber *voteId;     /**< 投票id */
@property(nonatomic,strong) NSString *content;    /**< 投票内容 */
@property(nonatomic,strong) NSNumber *count;      /**< 投票数量 */
@end

// 新闻的扩展信息
@interface SNNewsExtensionInfo : NSObject


@property(nonatomic,strong) NSString *title;    /**< 新闻标题 */
@property(nonatomic,strong) NSNumber *time;     /**< 新闻发布时间 */
@property(nonatomic,strong) NSString *source;   /**< 新闻来源 */
@property(nonatomic,strong) NSString *content_url;   /**< 新闻URl */
@property(nonatomic,strong) NSString *newsUrl;       /**< 新闻原网页地址 */
@property(nonatomic,strong) NSNumber *positive_count; /**< 点赞人数 */
@property(nonatomic,strong) NSNumber *negative_count; /**< 反对人数 */
@property(nonatomic,strong) NSNumber *total_energy;   /**< 总能量值 */
@property(nonatomic,strong) NSArray *recommendation_list;/**< 推荐新闻列表 */
@property(nonatomic,strong) NSArray *hot_comment_list;  /**< 热门评论列表 */
@property(nonatomic,strong) NSNumber *is_energy;        /**< 是否是正负能量 */
@property(nonatomic,strong) NSNumber *positive_energy;  /**< 正能量 */
@property(nonatomic,strong) NSNumber *negative_energy;  /**< 负能量 */
@property(nonatomic,strong) NSNumber *isComment;        /**< 是否评论 */
@property(nonatomic,strong) NSNumber *comment_count;    /**< 评论总数 */
@property(nonatomic,strong) NSNumber *updateTime;       /**< 更新时间 */
@property(nonatomic,strong) NSNumber *is_collected;     /**< 是否收藏 */

// 订阅数据
//"rssId":59332630,"rssName":"大家",
//"rssIcon":"http://go.10086.cn/hotpic/201507/20/source59332630.jpg",
@property(nonatomic,strong) NSNumber *rssId;            /**< 订阅频道id */
@property(nonatomic,strong) NSString *rssName;          /**< 订阅频道名称 */
@property(nonatomic,strong) NSString *rssIcon;          /**< 订阅频道iconUrl */

// 新闻投票
@property(nonatomic,strong) NSString *vote_title;   /**<投票标题 */
@property(nonatomic,strong) NSNumber *vote_type;    /**<投票类型 1单选*/
@property(nonatomic,strong) NSNumber *vote_time;    /**< 投票时间 */
@property(nonatomic,strong) NSNumber *vote_count;   /**< 投票总数 */
@property(nonatomic,strong) NSNumber *begin_time;   /**< 开始时间 */
@property(nonatomic,strong) NSNumber *end_time;     /**< 开始时间 */
@property(nonatomic,strong) NSArray  *options;      /**< 投票列表*/


// 本地业务需要属性，不序列化(由外部初始化)
@property(nonatomic) long newsId;       /**< 新闻id*/


// 是否可以投票
-(BOOL)isVote;
@end



// 新闻内容信息返回数据模型
@interface SNNewsContentInfoResponse : SurfJsonResponseBase


@property(nonatomic,strong) SNNewsExtensionInfo *news; /**< 新闻附属信息，正负能量，热门评论，相关推荐等信息 */

@end



