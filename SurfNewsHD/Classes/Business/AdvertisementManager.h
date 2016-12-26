//
//  AdvertisementManager.h
//  SurfNewsHD
//
//  Created by xuxg on 14-4-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonResponseBase.h"

// 广告信息
@interface AdvertisementInfo : NSObject

@property(nonatomic) double startTime;    // 广告开始时间
@property(nonatomic) double endTime;      // 广告结束时间


@property(nonatomic,strong) NSString *adId;     // 广告id
@property(nonatomic,strong) NSString *type;     // 广告类型  0. 文字广告  1. 图片广告
@property(nonatomic,strong) NSString *title;    // 广告标题
@property(nonatomic,strong) NSString *img_url;  // 广告图片链接
@property(nonatomic,strong) NSString *newsUrl;  // 广告位链接
@property(nonatomic,strong) NSString *coid;     // 频道Id


// 本地数据
@property(nonatomic) BOOL isReadyImage;

@end



// 广告请求回应
@interface AdvertisementResponse : SurfJsonResponseBase
@property(nonatomic) double updateTime;   // 更新间隔时间（单位毫秒）
@property(nonatomic,strong) NSArray *item;


- (BOOL)isNeedUpdate;// 是否需要更新，一些规则判断



@end



// 广告管理类，负责广告信息接受，管理。
@interface AdvertisementManager : NSObject


+(AdvertisementManager*)sharedInstance;


//- (void)loadDataFromFile;                       // 加载本地广告数据;
- (void)updateAdvertisement;                    // 更新广告信息
-(NSArray*)getAdvertisementOfCoid:(long)coid;   // 获取频道广告
@end
