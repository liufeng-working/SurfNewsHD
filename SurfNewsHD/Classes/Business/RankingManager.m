//
//  RankingManager.m
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RankingManager.h"
#import "PathUtil.h"
#import "NSString+Extensions.h"
#import "AppSettings.h"



@implementation RankingManager

+ (RankingManager*)sharedInstance{
    static RankingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RankingManager alloc] init];
    });
    return sharedInstance;
}
- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    _pRankList_day  = [NSMutableArray new];
    _nRankList_day  = [NSMutableArray new];
    _pRankList_week = [NSMutableArray new];
    _nRankList_week = [NSMutableArray new];
    
    NSString *dayRankPath = [PathUtil pathOfDayRankingList];
    NSString *weekRankPath = [PathUtil PathOfWeekRankingList];
    
    
    NSString *rankDayStr =
    [NSString stringWithContentsOfFile:dayRankPath
                              encoding:NSUTF8StringEncoding
                                 error:nil];
    NSString *rankWeekStr =
    [NSString stringWithContentsOfFile:weekRankPath
                              encoding:NSUTF8StringEncoding
                                 error:nil];
    
    if (rankDayStr && ![rankDayStr isEmptyOrBlank]) {
        RankingInfoResponse* dayRes =
        [EzJsonParser deserializeFromJson:rankDayStr
                                   AsType:[RankingInfoResponse class]];
        if(dayRes && [dayRes.positiveNews count] > 0){
            [self initRankingList:dayRes isRankDay:YES];
        }
    }
    
    if (rankWeekStr && ![rankWeekStr isEmptyOrBlank]) {
        RankingInfoResponse* weekRes =
        [EzJsonParser deserializeFromJson:rankWeekStr
                                   AsType:[RankingInfoResponse class]];
        if(weekRes && [weekRes.positiveNews count] > 0){
            [self initRankingList:weekRes isRankDay:NO];
        }
    }
    
    return self;
}
- (void)refreshRankingInfo:(int)type
     withCompletionHandler:(void(^)(BOOL, RankingInfoResponse*))handler
{
    //type : 0 日榜单 1月榜单
    __block BOOL blk_isDayRanking = (type==0);

    id req = [SurfRequestGenerator rankingListRequestWithRankType:type];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         RankingInfoResponse* res = nil;
         BOOL is_succeed = NO;
         if(!error){
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             res = [EzJsonParser deserializeFromJson:body AsType:[RankingInfoResponse class]];
             if ([res.positiveNews count] > 0) {
                 is_succeed = YES;
                 
                 // 保存到本地
                 NSString *rankPath = nil;
                 NSString *dateKey = nil;
                 if (blk_isDayRanking) {
                     dateKey = DateEnergyList_Day;
                     rankPath = [PathUtil pathOfDayRankingList];
                 }
                 else {
                     dateKey = DateEnergyList_Week;
                     rankPath = [PathUtil PathOfWeekRankingList];
                 }
                 
                 // 保存刷新时间
                 [AppSettings setDate:[NSDate date]
                                                forkey:dateKey];
                 
                 // 保存数据到文件中
                 [body writeToFile:rankPath
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:nil];
                 
                 //初始化榜单
                 [self initRankingList:res isRankDay:blk_isDayRanking];
             }
         }
         
         if(handler)
             handler(is_succeed, res);
        }];
    
}

- (void)initRankingList:(RankingInfoResponse*)res isRankDay:(BOOL)isRankDay
{
    NSArray *pList = nil;
    NSArray *nList = nil;
    if ([res.positiveNews count] > 0)
        pList = res.positiveNews;
    if ([res.negativeNews count] > 0)
        nList = res.negativeNews;

    
    if (isRankDay) {
        if (pList) {
            [_pRankList_day removeAllObjects];
            [_pRankList_day addObjectsFromArray:pList];
            [self sortList:_pRankList_day];
        }
        
        if (nList) {
            [_nRankList_day removeAllObjects];
            [_nRankList_day addObjectsFromArray:nList];
            [self sortList:_nRankList_day];
        }
    }
    else {
        if (pList) {
            [_pRankList_week removeAllObjects];
            [_pRankList_week addObjectsFromArray:pList];
            [self sortList:_pRankList_week];
        }
        
        if (nList) {
            [_nRankList_week removeAllObjects];
            [_nRankList_week addObjectsFromArray:nList];
            [self sortList:_pRankList_week];
        }
    }
}

-(void)sortList:(NSMutableArray*)list
{
    [list sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RankingNews *rn1 = obj1;
        RankingNews *rn2 = obj2;
        if (rn1.seqId < rn2.seqId) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
}
//
- (RankingNews *)getBestPositive:(int)type
{
    //type: 0 日榜单 1周榜单
    if (type == 0) {
        return [_pRankList_day firstObject];
    }
    else {
        return [_pRankList_week firstObject];
    }
}

- (RankingNews *)getWorstNegative:(int)type
{
    //type: 0 日榜单 1周榜单
    if (type == 0) {
        return [_nRankList_day firstObject];
    }
    else {
        return [_nRankList_week firstObject];
    }
}

// 计算刷新的时间间隔
-(NSInteger)calcRefreshDateInterval:(BOOL)isDayRank
{
    NSInteger hour = NSIntegerMax;
    NSDate *date = [AppSettings dateForKey:isDayRank?DateEnergyList_Day:DateEnergyList_Week];
    if (date) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:date];
        hour = ((int)time)%(3600*24)/3600;
        hour = (hour < 0) ? NSIntegerMax : hour;
    }
    return hour;
}
@end
