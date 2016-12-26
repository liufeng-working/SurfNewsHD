//
//  SurfDbManager.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SurfDbManagerInitProtocol <NSObject>
@required

//db数据重置后的回调
-(void)dbHasBeenRecoveredFromCurruption;

//db将要被升级
-(void)dbWillBeUpgraded;

//db升级完成，error为0表示成功，非0表示升级失败
-(void)dbUpgradedWithError:(int)error;

@end

@class ThreadSummary;
@class FMDatabase;
@class HotChannel;
@class SubsChannel;
@class SurfUserInfo;
@class CategoryItem;
@class CommentBase;

@interface SurfDbManager : NSObject
{
@private
    __weak id<SurfDbManagerInitProtocol> initDelegate_;
    __strong FMDatabase* fmdb_;
}
//access the singleton SurfDbManager instance
+ (SurfDbManager *)sharedInstance;

-(void)initDbWithDelegate:(id<SurfDbManagerInitProtocol>)delegate;

//增加阅读记录
//即标记某个帖子为已读
-(BOOL)addReadingHistory:(ThreadSummary*) thread;
//查询某个帖子是否已读
-(BOOL)isThreadRead:(ThreadSummary*)thread;

//标记某个帖子为“已赞”
-(BOOL)addRatingHistory:(ThreadSummary*) thread;
//查询某个帖子是否已赞
-(BOOL)isThreadRated:(ThreadSummary*)thread;

#pragma mark - 段子频道帖子 赞、踩
// 标记段子频道帖子 赞或踩
- (BOOL)addUpedOrDownedHistory:(ThreadSummary *)thread;

// 查询段子频道帖子 赞1 或 踩2
- (int)isThreadUpedOrDowned:(ThreadSummary *)thread;
#pragma mark -----

// 正负能量值
-(long)energyScore:(ThreadSummary*)thread;
// 保存正负能量值
-(BOOL)saveEnergyScore:(ThreadSummary*)thread energyScore:(int)score;
// 查询新闻评论是否点赞
-(BOOL)isCommentRated:(CommentBase*)comment;
// 标记新闻评论观点
-(BOOL)addCommentRatingHistory:(CommentBase*)comment;

// 新闻是否投票
-(BOOL)isNewsVote:(NSInteger)newId;
// 标记新闻评论观点
-(BOOL)addNewsVote:(NSInteger)newId;

//获取存储过的用户信息
//尚未登录过，则返回nil
//数据库支持多用户，但目前业务决定了只可能有单用户
-(SurfUserInfo*)getUserInfo;
-(BOOL)setUserInfo:(SurfUserInfo*)userInfo;
-(BOOL)deleteUserInfo;

//获取用户绑定的微博信息
-(NSDictionary*)getSinaWeiboInfoForUser:(NSString*)userId;
-(NSDictionary*)getTencentWeiboInfoForUser:(NSString*)userId;
-(NSDictionary*)getRenrenWeiboInfoForUser:(NSString*)userId;
-(NSDictionary*)getCMWeiboInfoForUser:(NSString*)userId;

//添加用户绑定的微博信息
-(BOOL)addSinaWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info;
-(BOOL)addTencentWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info;
-(BOOL)addRenrenWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info;
-(BOOL)addCMWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info;

//清空用户绑定的微博信息
//即取消微博绑定
-(BOOL)clearSinaWeiboInfoForUser:(NSString*)userId;
-(BOOL)clearTencentWeiboInfoForUser:(NSString*)userId;
-(BOOL)clearRenrenWeiboInfoForUser:(NSString*)userId;
-(BOOL)clearCMWeiboInfoForUser:(NSString*)userId;

@end
