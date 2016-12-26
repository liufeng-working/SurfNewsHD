//
//  CityManage.h
//  SurfNewsHD
//
//  Created by yujiuyin on 14/12/22.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonResponseBase.h"


@interface CityRssListData : NSObject

@property(nonatomic,strong) NSString *cityId;
@property(nonatomic,strong) NSString *cityName;
@property(nonatomic,strong) NSString *parentName;
@property long parentId;
@property(nonatomic,copy)NSString * enName;

@property(nonatomic,copy)NSString * firstLetter; //自己增加的属性


@end



@interface CityRssData : SurfJsonResponseBase

@property long long cityRssTime;
@property NSArray *cityRssList;

@end


@interface CityManager : NSObject{
    CityRssData *cityRssData;
}

+ (CityManager*)sharedInstance;

// 获取本地城市列表信息
- (CityRssData *)getCityRssData;

//保存城市列表到本地
- (void)saveCityRssDataWithBodyStr:(NSString *)body;

@end
