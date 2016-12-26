//
//  SubsChannelsManager.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"
#import "GTMHTTPFetcher.h"
#import "GetMagazineSubsResponse.h"
#import "RecommendSubsChannelResponse.h"
#import "AppSettings.h"

/*
 注意：SubsChannelsManager设计为单例
 */

//@succeeded:刷新操作是否成功
//@noChanges:热推频道列表是否未发生了改变(未发生改变时，UI无需做任何操作)
typedef void (^SubsChannelsRefreshResultHandler)(BOOL succeeded,BOOL noChanges);

@class SubsChannel;
@class SubsChannelsListResponse;
@class SubsChannelsManager;
@class MagazineSubsInfo;

@interface SubsChannelsSortInfo : NSObject
@property NSMutableArray* visibleIdsArray;
@property NSMutableArray* invisibleIdsArray;
@property NSMutableArray* wapVisibleSubsChannels;
@end

@interface SubsChannelsCommitTaskInfo : NSObject

@property(nonatomic,strong)NSMutableArray* toSubs;  //元素：SubsChannel
@property(nonatomic,strong)NSMutableArray* toUnsubs;//元素：channel id
@property(nonatomic,strong)NSMutableArray* toMagazineSubs;  //元素：MagazineSubsInfo
@property(nonatomic,strong)NSMutableArray* toMagazineUnsubs;//元素：magazine id
-(BOOL) isEmpty;

@end


@protocol SubsChannelChangedObserver <NSObject>

@required
-(void)subsChannelChanged;
@end

@interface SubsChannelsManager : NSObject<UserManagerObserver>
{
    __strong NSMutableArray* subsChannels_;
    __strong SubsChannelsCommitTaskInfo* commitTaskInfo_;
    __strong NSMutableArray* observers_;
    __strong NSMutableArray* catesCache_;   //订阅分类缓存
    
    //可视的订阅列表
    NSMutableArray* visibleSubsChannels;
    NSMutableArray *backupVisibleSubsChannels; // 备份数据，用来做网络异常，订阅顺序恢复使用。
    
    //不可视的订阅列表
    NSMutableArray* invisibleSubsChannels;
    //wap端可见列表
    NSMutableArray* wapVisibleSubsChannels;
    
    GTMHTTPFetcher *categoriesFetcher;// 分类请求
    
    //不可以展示的订阅列表
    NSMutableArray* inShowSubsChannels;
    //是否提交订阅中
    BOOL isCommitChannels;
}
-(BOOL)userSubsInfoUpSucesss;
+(SubsChannelsManager*)sharedInstance;
//返回可视的订阅列表
@property(nonatomic,strong) NSMutableArray* visibleSubsChannels;
//返回不可视的订阅列表
@property(nonatomic,strong) NSMutableArray* invisibleSubsChannels;
//返回wap端可见
@property(nonatomic,readonly) NSMutableArray* wapVisibleSubsChannels;
//获取本地订阅关系包含可视和不可视
-(NSMutableArray*)loadLocalSubsChannels;

//获取订阅分类列表
//@cates: 元素类型CategoryItem
-(void)loadCategoriesWithCompletionHandler:(void(^)(NSArray* cates))hanlder;
-(void)refreshCategoriesWithCompletionHandler:(void(^)(NSArray* cates))hanlder;

//根据分类id获取该分类下的可订阅频道列表
-(void)loadSubsChannelsOfCategory:(long)cateId page:(NSInteger)page withCompletionHandler:(void(^)(NSArray* channels))handler;
//获取该推荐订阅频道列表
-(void)loadRecommendSubsChannelsWithCompletionHandler:(void(^)(NSArray* channels))handler;
//获取搜索到的订阅频道列表
-(void)loadSearchedSubsChannels:(NSString *)name page:(int)page withCompletionHandler:(void(^)(BOOL success, NSArray* channels))handler;

-(void)addChannelObserver:(id<SubsChannelChangedObserver>)observer; //订阅频道changed事件
-(void)removeChannelObserver:(id<SubsChannelChangedObserver>)observer;//退订频道changed事件

-(BOOL)channelSubsStatus:(long)channelId;               //检测某个频道的订阅状态,包括已订阅还是将要订阅
-(BOOL)isChannelSubscribed:(long)channelId;             //检测某个频道是否被订阅
-(BOOL)isChannelReadyToSubscribed:(long)channelId;      //检测某个频道是否要被订阅,在toSubs
-(BOOL)isChannelReadyToUnsubscribed:(long)channelId;    //检测某个频道是否要被取消订阅,在toUnsubs
-(BOOL)magazineSubsStatus:(long)magazineId;              //检测某个期刊的订阅状态,包括已订阅还是将要订阅
-(BOOL)isMagazineReadyToSubscribed:(long)magazineId;    //检测某个期刊是否要被订阅,在toMagazineSubs
-(BOOL)isMagazineReadyToUnsubscribed:(long)magazineId;  //检测某个期刊是否要被取消订阅,在toMagazineUnsubs
-(SubsChannel*)getChannelById:(long)channelId;          //根据频道id获取频道信息

-(void)addSubscription:(SubsChannel*)channel;           //添加订阅
-(void)removeSubscription:(SubsChannel*)channel;        //退订
//要订阅的栏目的个数
- (NSInteger)countOfToSubs;
//将刚加入的要订阅的栏目移除
- (void)removeChannelFromToSubs:(SubsChannel*)channel;
//将刚加入的要被取消订阅的栏目移除
- (void)removeChannelFromToUnsubs:(SubsChannel*)channel;
//增加期刊订阅
- (void)addMagazinze:(MagazineSubsInfo*)magazine;
//退订期刊订阅
- (void)removeMagazine:(MagazineSubsInfo*)magazine;
//将刚加入的要订阅的期刊移除
- (void)removeMagazineFromToMagazineSubs:(MagazineSubsInfo*)magazine;
//将刚加入的要被取消订阅的期刊移除
- (void)removeMagazineFromToMagazineUnsubs:(MagazineSubsInfo*)magazine;
-(BOOL)commitChangesWithHandler:(void(^)(BOOL succeeded))handler;   //提交更改
-(void)removeAllToSubs;                                 //清空所有要提交的订阅
-(BOOL)isInCommitting;                                  //当前是否正在提交更改

//完全覆盖本地的订阅关系
-(void)overwriteLocal:(SubsChannelsListResponse*)resp;
//跟本地订阅关系进行合并后再提交至服务端
-(void)mergeLocalAndCommitIfNecessary:(SubsChannelsListResponse*)resp;
//判断本地存储的订阅关系是否跟第一次获得的默认订阅频道发生了变更（即用户修改过订阅关系）
-(BOOL)isLocalSubsChannelsDifferFromFirstGot;
//游客用户
-(void)loadSortInfoChannls;
//-(void)handleSubsChannelsResorted;

//是否有栏目订阅要提交
- (BOOL)hasChannelToSubs;
//是否有期刊订阅要提交
- (BOOL)hasMagazineToSubs;
//是否是最后一个栏目订阅
- (BOOL)alreadyLastChannel;

// 刷新订阅列表(游客不刷新)
- (void)refreshSubsChannelListWithUser:(UserInfo*)info handler:(void(^)(BOOL succeeded))handler;
@end
