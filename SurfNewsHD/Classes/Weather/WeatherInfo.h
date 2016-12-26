//
//  WeatherInfo.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UpdateWeatherResponse;

// 在iPad版本中，天气被弱话，不需要那么多的属性，改成简化版本的天气信息
@interface WeatherInfo : NSObject


@property(nonatomic,strong) NSString *cityId;         // 城市ID
@property(nonatomic,strong) NSString *cityName;         // 城市名称
@property(nonatomic,strong) NSString *weather;          // 天气情况
@property(nonatomic,readonly) UIImage *weatherIcon_g;      // 灰色天气图片
@property(nonatomic,readonly) UIImage *weatherIcon_w;      // 白色天气图片
@property(nonatomic,readonly) NSString *temperature;    // 温度区间
@property(nonatomic,readonly) NSString *temp;           // 当前温度
@property(nonatomic,readonly) NSString *updateTime;     // 天气更新的日期
@property(nonatomic,readonly) NSString *longUpdateTime; // 天气更新的日期
@property(nonatomic,readonly) NSString *week;
@property(nonatomic,readonly) NSString *wind_scale; //风力等级。
@property(nonatomic,strong) NSArray *futureWeather;
@property BOOL isToday;

- (id)initWithWeatherInfo:(UpdateWeatherResponse *)weather;
- (void)updateWeatherInfo:(UpdateWeatherResponse *)weather;
- (void)updateWithWeather:(WeatherInfo*)info;
- (void)clearWeatherInfo;
@end


////////////////
// 未来天气
//{"dindex":"1","maxtemp":"0","mintemp":"-9","morning_img_title":"1","night_img_title":"99","time":"2013-01-07","weather":"多云","week":"星期一"}
@interface FutureWeather : NSObject

@property NSInteger dindex; 
@property NSString* maxtemp;
@property NSString* mintemp;
@property(nonatomic) NSString* morning_img_title;
@property NSString* night_img_title;
@property NSString* time;
@property NSString* weather;
@property(nonatomic,strong) NSString* week;

@property(nonatomic,readonly)UIImage *weatherIcon;

// 获取温度区间
-(NSString*)tempInterval;


@end


