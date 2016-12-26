//
//  NewestManager.h
//  SurfNewsHD
//
//  Created by apple on 13-3-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    NewestNetworkStateNone = 0,       // 无请求状态
    NewestNetworkStateRefresh = 1,    // 刷新中
    NewestNetworkStateMore = 2        // 请求更多中
} NewestNetworkState;

@interface NewestManagerResult : NSObject

@property BOOL succeeded;   // 操作是否成功
@property(nonatomic,strong) NSArray* threads;   //该操作返回的帖子列表

@end
@interface NewestManager : NSObject
{
    NewestNetworkState networkState;
    NSMutableArray *threadsDirNames_;
    NSInteger currentPage;
    void(^completionHandler)(NewestManagerResult*);
    BOOL isNewestChannel;
}

+(NewestManager*)sharedInstance;

//获取本地缓存
-(NSArray*)loadLocalNewestChannels;

-(NSDate*)lastUpdateTime; // 最后更新时间

//刷新频道
-(void)refreshNewestCompletionHandler:(void(^)(NewestManagerResult*))handler;

//获取更多
-(void)getMoreForNewestCompletionHandler:(void(^)(NewestManagerResult*))handler;
@end
