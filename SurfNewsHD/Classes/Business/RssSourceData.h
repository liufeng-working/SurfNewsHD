//
//  RssSourceData.h
//  SurfNewsHD
//
//  Created by jsg on 14-7-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HotChannelsListResponse.h"

@interface RssSourceManager : NSObject {
    NSArray *_rssSourceList;
    NSMutableArray*  mHotChannelRecList;
    HotChannelRec* mCurRec;
}

@property (nonatomic,strong) NSMutableArray *mRssSourceDataList;
@property (nonatomic,strong) NSMutableArray*  mHotChannelRecList;
@property (nonatomic,strong) HotChannelRec* mCurRec;
+ (RssSourceManager*)sharedInstance;

/**
 *  设置Rss源
 *
 */
-(void)setRssList:(NSArray*)rssList;


/**
 *  获取频道下面的RSS源
 *
 *  @param channelId 频道ID
 *
 *  @return 频道对应的RSS源，有可能为nil;
 */
-(NSArray *)rssListWithChannelId:(NSInteger)channelId;


/**
 *  随机获取频道下面的RSS源
 *
 *  @param channelID 频道Id
 *
 *  @return RSS数据 有可能是nil
 */
- (HotChannelRec *)getRandomRssDataWithChannelId:(NSUInteger)channelID;
@end
