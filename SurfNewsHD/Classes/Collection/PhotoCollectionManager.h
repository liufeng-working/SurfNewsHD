//
//  ImageCollectionManager.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>



@class PhotoCollectionChannel;
@class ThreadsFetchingResult;


@interface PhotoCollectionManager : NSObject{
    NSMutableDictionary* _pccPageNumDict;   // 记录图集频道当前页码（用于加载更多）
    NSMutableDictionary *_pccLocalDict;     // 图集频道本地属性
    NSMutableDictionary *_photoCollectionListCache;// 图集缓存
    NSMutableDictionary *_pcpListCache;          // 图集的图片信息列表
    
    NSMutableArray* _fetchingTasks; // 任务列表
}

// 图集频道列表
@property(nonatomic,strong,readonly)NSMutableArray *photoCollecChannelList;



// 单例函数
+ (PhotoCollectionManager*)sharedInstance;

// 刷新图集频道列表
- (void)refreshPhotoCollectionChannelList:(void (^)(BOOL succeeded, BOOL noChanges))handle;

// 改变图集频道列表的顺序
- (BOOL)changePhotoCollectionChannelListOrder:(NSArray*)orderArray;


// 刷新图集列表
- (void)refreshPhotoCollectionList:(PhotoCollectionChannel*)pcChannel
             withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;
// 加载更多图集列表
- (void)getMorePhotoCollectionList:(PhotoCollectionChannel*)pcChannel
             withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;
// 获取图集频道的刷新时间
- (NSDate*)lastRefreshDateOfPhotoCollectionChannel:(PhotoCollectionChannel*)pcc;
// 获取最后加载更多请求时间
- (NSDate*)lastMoreDateOfPhotoCollectionChannel:(PhotoCollectionChannel*)pcc;
// 获取本地图集列表
- (NSArray*)loadLocalPhotoCollectionListForPCC:(PhotoCollectionChannel*)pcc;

// 通过图集频道id获取图集频道
- (PhotoCollectionChannel*)getPhotoCollectionChannelWithId:(u_long)ppcId;

// 图集的图片信息列表
- (NSArray*)getPhotoInfoListWithPhotoCollection:(PhotoCollection*)pc;

// 图集列表正在加载
- (BOOL)photoCollectionListIsLoading:(PhotoCollectionChannel*)pcc;

// 请求图集内容
- (void)requestPhotoCollectionContent:(PhotoCollection*)pc withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler;
@end
