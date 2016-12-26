//
//  ThreadsManager.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-15.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadDownloadTask.h"

/*
 注意：ThreadsManager设计为单例
 */


@class HotChannel;
@class SubsChannel;
@class PhotoCollectionChannel;

@interface ThreadsFetchingResult : NSObject

@property BOOL succeeded;   //操作是否成功
@property BOOL noChanges;   //是否无新数据
@property BOOL isAppear;    //是否显示浮动栏
@property long channelId;   //刷新的频道id
@property NSInteger  addedThreadsCount; // 新增帖子数
@property(nonatomic,strong) NSArray* threads;   //该操作返回的帖子列表
+(ThreadsFetchingResult *)sharedInstance;
@end

//注：目前业务决定了只有已读通知，没有未读通知
typedef void (^ThreadReadChangedHandler)(ThreadSummary* thread,BOOL read);


@interface ThreadsManager : NSObject
{
    NSMutableDictionary* hotChannelsRefreshDateDict_;
    NSMutableDictionary* subsChannelsRefreshDateDict_;
    NSMutableDictionary* hotChannelsGetMoreDateDict_;
    NSMutableDictionary* subsChannelsGetMoreDateDict_;
    NSMutableDictionary* hotChannelThreadsCache_;
    NSMutableDictionary* subsChannelThreadsCache_;
    NSMutableDictionary* hotChannelsPageNumDict_;   //记录热推各频道当前页码（用于加载更多）
    NSMutableDictionary* subsChannelsPageNumDict_;  //记录用户订阅各频道当前页面（用于加载更多）
    NSMutableDictionary* imageGalleryThreadsCache_;
    NSMutableDictionary* imageGalleryPageNumDict_;
    
    NSDate* updateSubschennelLastNewsDate_;         // 更新订阅频道中的新闻时间
    
    NSMutableArray* fetchingTasks_;
    NSMutableArray* readThreadIdsCache_;    //已读帖子id缓存
    NSMutableArray* unreadThreadIdsCache_;  //未读帖子id缓存
    NSMutableArray* ratedThreadIdsCache_;   //已赞帖子id缓存
    NSMutableArray* unratedThreadIdsCache_; //未赞帖子id缓存
    NSMutableArray* threadReadChangedHandler;
    //
    NSMutableArray* lockedThreads_; //被锁定了资源的帖子数组
    //
    __weak ThreadSummary* lastReadThread_;  //上一次阅读的帖子。帖子列表需要将上一次阅读的帖子定位在可视区域
#ifdef ipad
    NSMutableArray* getAboutHotChannelArr;
#endif
}

//access the singleton ThreadsManager instance
+(ThreadsManager *)sharedInstance;

//新切换到一个频道时，使用该方法来获取本地帖子缓存
-(NSArray*)getLocalThreadsForHotChannel:(HotChannel*)hotChannel;
-(NSArray*)getLocalThreadsForHotChannelId:(u_long)coid;
-(NSArray*)getLocalThreadsForSubsChannel:(SubsChannel*)subsChannel;
-(NSArray *)getLocalThreadsForSubsChannelID:(long)channelId;
-(ThreadSummary*)getThreadSummaryForCoid:(u_long)coid threadId:(u_long)cid;

// 清除新闻频道的缓存帖子
-(void)clearCachedThreadsForHotChannel:(HotChannel*)hotChannel;

//刷新频道
-(void)refreshHotChannel:(id)target hotChannel:(HotChannel*)hotChannel
   withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;
-(void)refreshSubsChannel:(id)target subsChannel:(SubsChannel*)subsChannel
    withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;

//取消刷新频道
-(void)cancelRefreshHotChannel:(id)target hotChannel:(HotChannel*)hotChannel;
-(void)cancelRefreshSubsChannel:(id)target subsChannel:(SubsChannel*)subsChannel;
-(void)cancelPhotoCollectionChannel:(id)target pcChannel:(PhotoCollectionChannel*)pcChannel;
//获取更多
-(void)getMoreForHotChannel:(id)target hotChannel:(HotChannel*)hotChannel
      withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;
-(void)getMoreForSubsChannel:(id)target subsChannel:(SubsChannel*)subsChannel
       withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;

//取消获取更多
-(void)cancelGetMoreForHotChannel:(id)target hotChannel:(HotChannel*)hotChannel;
-(void)cancelUpdateSubsChannelsNews:(id)target;

//获取上一次刷新/加载更多的时间点
//返回nil表示从未刷新/加载更多过
-(NSDate*)lastRefreshDateOfHotChannel:(HotChannel*)hotChannel;
-(NSDate*)lastRefreshDateOfSubsChannel:(SubsChannel*)subsChannel;
-(NSDate*)lastGetMoreDateOfHotChannel:(HotChannel*)hotChannel;
-(NSDate*)lastGetMoreDateOfSubsChannel:(SubsChannel*)subsChannel;
-(NSDate*)LastUpdateSubsChannelNews;

//检测某个频道是否正处于刷新/获取更多进度中
-(BOOL)isHotChannelInRefreshing:(id)target hotChannel:(HotChannel*)hotChannel;
-(BOOL)isSubsChannelInRefreshing:(SubsChannel*)subsChannel;
-(BOOL)isHotChannelInGettingMore:(id)target hotChannel:(HotChannel*)hotChannel;
-(BOOL)isSubsChannelInGettingMore:(SubsChannel*)subsChannel;
-(BOOL)isUpdateSubsChannelsLastNews;//是否更新订阅频道新闻

//标记帖子为已读
-(void)markThreadAsRead:(ThreadSummary*)thread;
//查询某个帖子是否已读
-(BOOL)isThreadRead:(ThreadSummary*)thread;
//注册帖子已读状态改变通知
-(void)registerThreadReadChangedHandler:(ThreadReadChangedHandler)handler;
//取消注册帖子已读状态改变通知
-(void)unregisterThreadReadChangedHandler:(ThreadReadChangedHandler)handler;

//标记某个帖子为已赞
-(void)markThreadAsRated:(ThreadSummary*)thread;
//查询某个帖子是否已赞
-(BOOL)isThreadRated:(ThreadSummary *)thread;

#pragma mark - 段子 赞、踩 状态存取
// 标记段子某个帖子赞或踩
- (void)markJokeThreadAsUpedOrDowned:(ThreadSummary *)thread;

// 查询段子某个帖子 赞或踩
- (int)isJokeThreadUpedOrDowned:(ThreadSummary *)thread;

#pragma mark -------
//锁定某个帖子的资源
//被锁定后的帖子相关资源(尤其是info.txt)不允许被删除
//当一个帖子被webview打开后，需要将其锁定
-(void)lockThreadResource:(ThreadSummary *)thread;
//解锁某个帖子的资源
//当一个帖子不被webview使用时，需要将其解锁
-(void)unlockThreadResource:(ThreadSummary *)thread;
//检测某个帖子是否被锁定
-(BOOL)isThreadResourceLocked:(ThreadSummary *)thread;

//设置上一次阅读的帖子
//NOTE:@thread不会被retain
-(void)setLastReadThread:(ThreadSummary*)thread;
-(ThreadSummary*)getLastReadThread;

#ifdef ipad
//获取相关热门资讯
-(SubsChannel *)getAboutHotChannel:(HotChannel*)hotChannel;
//返回热推
-(HotChannel*)getAboutSubsChannel:(SubsChannel*)subsChannel;
#endif

// 添加频道的详情(by xuxg),
-(void)addThreadSummaries:(SubsChannel*)sc threadSummaries:(NSArray*)sums;

// 更新订阅频道的最新新闻
// 注：暂用于iphone需求
- (void)updateSubsChannelsLastNews:(id)target
                      subsChannels:(NSArray*)subschannels
                        completion:(void(^)(ThreadsFetchingResult*))handler;

//清除缓存
-(void)cleanAllCaches;
-(void)asynCleanAllCachesWithCompletionHandler:(void(^)(BOOL))handler;

//计算缓存大小
-(double)calculateCachesSize;

@end
