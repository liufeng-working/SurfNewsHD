//
//  MagazineManager.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeriodicalHtmlResolving.h"
#import "UserManager.h"

@class GetMagazineSubsResponse;
@class MagazineSubsInfo;

/*
 注意：MagazineManager设计为单例
 */

@interface MagazinesSortInfo : NSObject

@property NSMutableArray* magazineIdsArray;
@property NSMutableArray* wapMagazineIdsArray;

@end

@protocol SubsMagazineChangedObserver <NSObject>

@required
-(void)subsMagazineChanged;

@end

@interface MagazineManager : NSObject <UserManagerObserver>
{
    __strong NSMutableArray* observers;
    NSMutableArray* subsMagazines;
    NSMutableArray* wapVisiableMagazines;
    //请求队列
    NSMutableArray* fetchingTasks_;
    
    NSDate* updateMagazineLastDate;         // 更新期刊列表的时间
}

@property(nonatomic,readonly) NSMutableArray* subsMagazines;
@property(nonatomic,readonly) NSMutableArray* wapVisiableMagazines;

//access the singleton HotChannelsManager instance
+ (MagazineManager*)sharedInstance;
//检测某个期刊是否被订阅
- (BOOL)isMagazineSubscribed:(long)magazineId;
//返回期刊
- (MagazineSubsInfo *)getMagazineWithMagazineId:(long)magazineId;
//返回期刊下标
- (NSInteger)getMagazineIndexWithMagazineId:(long)magazineId;
//查询期刊的介绍
- (NSString *)getMagazineDescWithMagazineId:(long)magazineId;
//载入本地订阅关系
- (NSArray*)loadLocalMagazineSubs;
//返回更新期刊列表的时间
- (NSDate*)lastDateOfMagazineUpdate;
//完全覆盖本地的期刊订阅关系
- (void)overwriteLocalMagazines:(GetMagazineSubsResponse*)resp;
//保存期刊订阅信息
- (void)handleMagazinesResorted;
//期刊列表的下拉刷新,回调函数分别室请求是否成功和是否要刷新UI
- (void)refreshMagazinesWithCompletionHandler:(void (^)(BOOL, BOOL))handler;
//使用magazineId请求该期刊的每期别表
- (void)refreshPeriodicalsWithMagazineId:(long)magazineId completionHandler:(void(^)(BOOL, BOOL, NSArray*))handler;
//使用page请求期刊列表
- (void)refreshMagazineWithPage:(NSInteger)page completionHandler:(void(^)(BOOL, NSArray*))handler;
//获得更新期刊列表
- (void)getUpdatePeriodicalListCompletionHandler:(void(^)(BOOL, BOOL))handler;

// 获取期刊期刊索引页
- (void)getPeriodicalContentIndex:(PeriodicalInfo*)periodicalInfo complete:(void(^)(BOOL, PeriodicalHtmlResolvingResult*))handler;
// 取消获取期刊索引页
- (void)cancelPeriodicalContent:(PeriodicalInfo*)periodicalInfo;
// 获取期刊期刊正文
- (void)getPeriodicalContent:(PeriodicalLinkInfo *)info complete:(void(^)(BOOL, PeriodicalHtmlResolvingResult*))handler;
// 取消获取期刊正文
- (void)cancelPeriodicalLinkInfo:(PeriodicalLinkInfo*)periodicalInfo;

//订阅期刊观察
-(void)addMagazineObserver:(id<SubsMagazineChangedObserver>)observer;
//退订期刊观察
-(void)removeMagazineObserver:(id<SubsMagazineChangedObserver>)observer;

//获取登录用户的期刊订阅列表
-(void)refreshMagazineListWithUser:(UserInfo*)info handler:(void(^)(BOOL succeeded))handler;

@end
