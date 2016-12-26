//
//  HotChannelsManager.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 注意：HotChannelsManager设计为单例
 */

//@succeeded:刷新操作是否成功
//@noChanges:热推频道列表是否未发生了改变(未发生改变时，UI无需做任何操作)
typedef void (^HotChannelsRefreshResultHandler)(BOOL succeeded,BOOL noChanges);

@class HotChannel;
@interface HotChannelsManager : NSObject
{
    NSMutableArray* visibleHotChannels_;
    NSMutableArray* invisibleHotChannels_;
//    NSMutableArray* selectedArray;
//    NSMutableArray* isNewArray;
    
    BOOL isSortChannels_; // 表示新闻频道顺序是否发生改变
}

//access the singleton HotChannelsManager instance
+(HotChannelsManager *)sharedInstance;

//返回可视的热推频道列表
@property(nonatomic,retain) NSMutableArray* visibleHotChannels;

//返回不可视的热推频道列表
@property(nonatomic,retain) NSMutableArray* invisibleHotChannels;

//记录选中的频道标号
@property(nonatomic,assign)int selectChannelIndex;



//排序发生变化后，调用此方法
-(void)handleHotChannelsResorted;

//刷新热推频道列表
//注：刷新回来的热推频道列表，如果跟本地的相比发生了改变，则
//HotChannelsManager内部会负责覆盖本地数据。调用者无须额外处理。
-(void)refreshWithCompletionHandler:(HotChannelsRefreshResultHandler)handler;

// 获取一样Id的热门频道
-(HotChannel*)getChannelWithSameId:(HotChannel*)channel inArray:(NSArray*)array;
// 获取一样Id的热门频道
-(HotChannel*)hotChannelWithId:(NSUInteger)channelId;

//提醒已经存在最新新闻（没有被点击过）
//-(BOOL)handleHotChannelsUpdate;

//保存点击过的最新新闻选项，调用此方法
//-(void)handleHotChannelsIsNew:(HotChannel*)hc;

//保存点击过的最新新闻提示，调用此方法
//-(void)handleHotChannelsSelected:(HotChannel*)hc;

//查询最近新闻提示，调用此方法
//-(BOOL)handleHotChannelsShow:(HotChannel*)hc;
@end
