//
//  FavsManager.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//收藏管理器
//设计为单例

@class ThreadSummary;
@class FavThreadSummary;
@interface FavsManager : NSObject
{
    NSMutableArray* threadsDirNames_;
}

+(FavsManager*)sharedInstance;

//获取总共收藏了多少个帖子
-(NSUInteger)threadsCount;

//按需获取部分收藏帖信息
-(NSArray*)fetchThreadsWithRange:(NSRange)range;

//测试是否某个帖子已经被收藏
-(BOOL)isThreadInFav:(ThreadSummary*)thread;

//是否能量显示
- (long)isEnergyInTs:(ThreadSummary*)thread;

//正能量数值
- (long)isPositive_energy:(ThreadSummary*)thread;

//负能量数值
- (long)isNegative_energy:(ThreadSummary*)thread;

//增加收藏（如果已经被收藏过则不进行任何操作）
-(void)addFav:(ThreadSummary*)thread withCompletionHandler:(void(^)(BOOL))handler;
-(void)addFav:(ThreadSummary*)thread;

//移除收藏（如果尚未被收藏过则不进行任何操作）
-(void)removeFav:(ThreadSummary*)thread;

//清空收藏
-(void)removeAllFavs;

@end
