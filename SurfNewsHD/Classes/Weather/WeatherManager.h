//
//  WeatherManager.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WeatherInfo.h"

@class GTMHTTPFetcher;
@class WeakRefArray;

// 天气更新委托协议
@protocol WeatherUpdateDelegate <NSObject>
@required
- (void)weatherWillUpdate; // 天气将要更新
- (void)handleWeatherInfoChanged:(BOOL)succeeded weatherInfo:(WeatherInfo*)info;
@end

// 天气的cityId发生改变通知协议
@protocol CityIdChangeDelegate <NSObject>
@required
- (void)NotifyCityIdChanged:(NSString*)newCityId;
@end


// 快讯定位服务
typedef void (^SurfLocationHandle)(WeatherInfo *locationWeather);



/**
 *  冲浪快讯定位助手
 */
@interface SurfLocationHelper : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;
    GTMHTTPFetcher *_fetcher;
}

@property(nonatomic,readonly)WeatherInfo *locationCityWeather; // GPS定位到的城市天气
@property(nonatomic,readonly)NSString *cityName; // GPS定位到的城市名

+(SurfLocationHelper*)sharedInstance;

// 是否允许定位
+(BOOL)isLocationEnable;


-(void)startLocation;   // 开始定位
-(void)stopLocation;    // 停止定位

// 定位城市发生改变
-(void)locationCityChanged:(SurfLocationHandle)handler;
@end



@interface WeatherManager : NSObject {
    
    WeakRefArray *_weatherUpdateObservers;
    WeakRefArray *_cityIdChangedDelegates;
}
@property(nonatomic,readonly) WeatherInfo *weatherInfo;
//@property(nonatomic,readonly) BOOL isUpdateWeather;

+(WeatherManager*)sharedInstance;

- (void)updateWeatherInfo; // 更新天气

// 添加和删除天气更新观察者(使用的弱引用数组)
- (void)addWeatherUpdatedNotify:(id<WeatherUpdateDelegate>)observer;



// 2013.7.24 添加的新需求
// 只定位城市，不做什么改变
-(BOOL)isSuportLocationServices;    // 是否支持定位服务

// 定位城市天气
-(void)locationCityWeather:(void (^)(WeatherInfo *newWeather))handler;




// 针对选择城市时候使用
- (void)setCityInfoAndUpdateWeather:(NSString*)cityName
                             cityId:(NSString*)cityId;


// 添加/cityID改变委托(使用的弱引用数组)
- (void)addCityIdChangeDelegate:(id<CityIdChangeDelegate>)delegate;
@end
