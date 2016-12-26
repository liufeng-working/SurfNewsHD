//
//  RankingManager.h
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "RankingInfoResponse.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"

@interface RankingManager : NSObject

// 每天的正负能量列表
@property (nonatomic,readonly) NSMutableArray *pRankList_day;
@property (nonatomic,readonly) NSMutableArray *nRankList_day;

// 每周正负能量列表
@property (nonatomic,readonly) NSMutableArray *pRankList_week;
@property (nonatomic,readonly) NSMutableArray *nRankList_week;



+ (RankingManager*)sharedInstance;

- (void)refreshRankingInfo:(int)type
     withCompletionHandler:(void(^)(BOOL succeed, RankingInfoResponse* res))handler;

// 获取最高正能量
//type: 0 日榜单 1周榜单
- (RankingNews *)getBestPositive:(int)type;

// 获取最低负能量
- (RankingNews *)getWorstNegative:(int)type;


// 计算时间间隔，返回小时
-(NSInteger)calcRefreshDateInterval:(BOOL)isDayRank;

@end
