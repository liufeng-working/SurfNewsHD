//
//  RankingInfoResponse.m
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RankingInfoResponse.h"
#import "ThreadSummary.h"

@implementation RankingNews

@synthesize ranking_id = __KEY_NAME_id;
@synthesize title = __KEY_NAME_title;
@synthesize desc = __KEY_NAME_desc;
@synthesize time = __KEY_NAME_time;
@synthesize source = __KEY_NAME_source;
@synthesize imgUrl = __KEY_NAME_imgUrl;
@synthesize newsUrl = __KEY_NAME_newsUrl;
@synthesize isTop = __KEY_NAME_isTop;
@synthesize type = __KEY_NAME_type;
@synthesize coid = __KEY_NAME_coid;
@synthesize isTopOrderby = __KEY_NAME_isTopOrderby;
@synthesize webp_flag = __KEY_NAME_webp_flag;
@synthesize open_type = __KEY_NAME_open_type;
@synthesize iconId = __KEY_NAME_iconId;
@synthesize iconPath = __KEY_NAME_iconPath;
@synthesize hot = __KEY_NAME_hot;
@synthesize content_url = __KEY_NAME_content_url;
@synthesize positive_energy = __KEY_NAME_positive_energy;
@synthesize negative_energy = __KEY_NAME_negative_energy;
@synthesize total_energy = __KEY_NAME_total_energy;
@synthesize positive_count = __KEY_NAME_positive_count;
@synthesize negative_count = __KEY_NAME_negative_count;
@synthesize recommendType = __KEY_NAME_recommendType;
@synthesize imgc = __KEY_NAME_imgc;
@synthesize is_energy = __KEY_NAME_is_energy;
@synthesize rankType = __KEY_NAME_rankType;
@synthesize seqUpdate = __KEY_NAME_seqUpdate;

- (ThreadSummary *)getThread
{
    ThreadSummary *ts = [ThreadSummary new];
    ts.threadId = self.ranking_id;
    ts.channelId = [self.coid integerValue];
    ts.title = self.title;
    ts.desc = self.desc;
    ts.time = [self.time doubleValue];
    ts.threadM = HotChannelThread;
    ts.channelType = 0;     // 姜军解释  0：冲浪新闻  1 快讯新闻，  默认是快讯新闻 ，在相关推荐中都是冲浪新闻
    ts.newsUrl = self.newsUrl;
    ts.imgUrl = self.iconPath;
    ts.source = self.source;
    ts.is_energy = [self.is_energy integerValue];
    ts.positive_energy = [self.positive_energy integerValue];
    ts.negative_energy = [self.negative_energy integerValue];
    ts.isComment = [_isComment boolValue];
    ts.comment_count = [_comment_count integerValue];
    [ts ensureFileDirExist];
    return ts;
}
@end



@implementation PositiveNews
@end


@implementation NegativeNews

@end


@implementation RankingInfoResponse
@synthesize positiveNews = __ELE_TYPE_PositiveNews;
@synthesize negativeNews = __ELE_TYPE_NegativeNews;
@end
