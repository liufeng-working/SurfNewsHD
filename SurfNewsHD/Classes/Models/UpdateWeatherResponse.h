//
//  UpdateWeatherResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"


@interface UpdateWeatherResponse : SurfJsonResponseBase


@property NSString* cityId;     // 城市ID
@property NSString* cityName;   // 城市名称
@property NSString* gmzs;       // 感冒指数
@property NSString* img1;       // 白天天气图标（即时）
@property NSString* img2;       // 夜晚天气图标（即时）
@property NSString* index;      // 穿衣指数
@property NSString* index_ag;   // 过敏指数
@property NSString* index_cl;   // 晨练指数
@property NSString* index_co;   // 舒适指数
@property NSString* index_ls;   // 晾晒指数
@property NSString* index_tr;   // 旅游指数
@property NSString* index_uv;   // 紫外线指数
@property NSString* index_xc;   // 洗车指数
@property NSString* method;     // 请求方法
@property NSString* sd;         // 湿度
@property NSNumber *serverTime; // 服务器时间
@property NSString* temp;       // 当前温度(服务器有问题NA,所有这个字段变成了占位了)
@property NSString* wcode;      // 网络状态
@property NSString* wdws;       // 风向级别
@property NSString* weather;    // 天气
@property NSArray* weathers;    // 未来5天天气信息
@property NSString* week;       // 周几
@property(nonatomic,strong)NSNumber *wind_scale; // 风力等级

- (NSString *)tempRange; // 温度范围
@end
