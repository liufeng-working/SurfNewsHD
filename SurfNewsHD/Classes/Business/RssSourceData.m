//
//  RssSourceData.m
//  SurfNewsHD
//
//  Created by jsg on 14-7-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RssSourceData.h"

@implementation RssSourceManager
@synthesize mRssSourceDataList;
@synthesize mHotChannelRecList;
@synthesize mCurRec;
+ (RssSourceManager*)sharedInstance
{
    static RssSourceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [RssSourceManager new];
    });
    return sharedInstance;
}


/**
 *  设置Rss源
 *
 */
-(void)setRssList:(NSArray*)rssList
{
    if ([rssList count] > 0) {
        _rssSourceList = nil;
        _rssSourceList = [rssList copy];
    }
}


/**
 *  获取频道下面的RSS源
 *
 *  @param channelId 频道ID
 *
 *  @return 频道对应的RSS源，有可能为nil;
 */
-(NSArray *)rssListWithChannelId:(NSInteger)channelId
{
    if ([_rssSourceList count] > 0) {
        return [_rssSourceList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(channelId==%@)",@(channelId)]];
    }
    return nil;
}

/**
 *  随机获取频道下面的RSS源
 *
 *  @param channelID 频道Id
 *
 *  @return RSS数据 有可能是nil
 */
- (HotChannelRec *)getRandomRssDataWithChannelId:(NSUInteger)channelID
{
    NSArray *rssList = [self rssListWithChannelId:channelID];
    if ([rssList count] > 0) {
        NSUInteger idx = arc4random() % [rssList count];
        return [rssList objectAtIndex:idx];
    }
    return nil;
}
@end
