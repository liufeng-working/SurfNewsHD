//
//  WeatherInfo.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WeatherInfo.h"
#import "UpdateWeatherResponse.h"
#import "NSDate+Extension.h"


/*
// 天气图片对于的大图片文件名
static NSString *ImageNameArray[32] =
{
    @"sunny" ,       // 晴                (d0)
    @"cloudy",       // 晴-多云            (d1)
    @"sunless",      // 阴                (d2)
    @"midrain",      // 中雨              (d3)
    @"thunderrain",  // 雷阵雨             (d4)
    @"snow",         // 雷阵雪(奇怪的名称)   (d5)
    @"hailstone",    // 阵雨加冰雹          (d6)
    @"midrain",      // 中雨               (d7)
    @"midrain",      // 中雨               (d8)
    @"midrain",      // 中雨               (d9)
    @"midrain",      // 中雨               (d10)
    @"midrain",      // 中雨               (d11)
    @"midrain",      // 中雨               (d12)
    @"midsnow",      // 中雪               (d13)
    @"heavysnow",    // 大雪               (d14)
    @"heavysnow",    // 大雪               (d15)
    @"heavysnow",    // 大雪               (d16)
    @"heavysnow",    // 大雪               (d17)
    @"fog",          // 雾天               (d18)
    @"midsnow",      // 中雪               (d19)
    @"sandy",        // 扬尘               (d20)
    @"midrain",      // 中雨               (d21)
    @"midrain",      // 中雨               (d22)
    @"midrain",      // 中雨               (d23)
    @"midrain",      // 中雨               (d24)
    @"midrain",      // 中雨               (d25)
    @"midsnow",      // 中雪               (d26)
    @"midsnow",      // 中雪               (d27)
    @"heavysnow",    // 大雪               (d28)
    @"sandy",        // 扬尘               (d29)
    @"sandstorm",    // 沙尘暴              (d30)
    @"sandy",        // 扬尘               (d31)
};
*/
@implementation WeatherInfo
//@synthesize weathersArray = __ELE_TYPE_FutureWeather;


- (id)initWithWeatherInfo:(UpdateWeatherResponse *)weather{
    if (self = [super init]) {
        [self updateWeatherInfo:weather];
    }
    return self;
}


- (void)updateWeatherInfo:(UpdateWeatherResponse *)weather
{
    [self clearWeatherInfo];
    NSString * wind_scale;
    if (weather) {
        _cityId = [weather cityId];
        _cityName = [weather cityName];
        _temperature = [weather tempRange];
        _temp = [weather temp];
        _futureWeather = [weather.weathers copy];
        _weather = [weather weather];
        _week = weather.week;
        if(weather.wdws && weather.wind_scale){
            wind_scale = [NSString stringWithFormat:@"%@风%@级",weather.wdws, weather.wind_scale];
        }
        _wind_scale = wind_scale;
        // 加载天气图片
        NSString *imgPath0 =
        [NSString stringWithFormat:@"w_d%@",[weather img1]];
        NSString *imgPath1 =
        [NSString stringWithFormat:@"g_d%@",[weather img1]];
        _weatherIcon_w = [UIImage imageNamed:imgPath0];
        _weatherIcon_g = [UIImage imageNamed:imgPath1];
        
        // 天气更新时间
        _isToday = YES;
        if ([weather serverTime]){
            NSTimeInterval timeInterval = [[weather serverTime] doubleValue] / 1000.f;
            NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSDateFormatter* df = [NSDateFormatter new];
            [df setDateFormat:@"MM-dd"];
            _updateTime = [df stringFromDate:serverDate];
            // yyyy-MM-dd HH:mm:ss.ff
            [df setDateFormat:@"yyyy-MM-dd"];
            _longUpdateTime = [df stringFromDate:serverDate];
            
            
            // 是否是今天天气
            NSTimeInterval maxInterval = 12*60*60;
            NSTimeInterval minInterval = -maxInterval;
            NSTimeInterval todayInterval =
            [[NSDate date] timeIntervalSince1970] - timeInterval;
            if (todayInterval < maxInterval &&
                todayInterval > minInterval) {
                _isToday = YES;
            }
        }
    }
}

- (void)updateWithWeather:(WeatherInfo*)info
{
    _weatherIcon_w = info.weatherIcon_w;
    _weatherIcon_g = info.weatherIcon_g;
    _cityId = info.cityId;
    _cityName = info.cityName;
    _temperature = info.temperature;
    _updateTime = info.updateTime;
    _futureWeather = [NSArray arrayWithArray:info.futureWeather];
    _longUpdateTime = info.longUpdateTime;
    _weather = info.weather;
    _week = info.week;
}

// 清空天气信息
- (void)clearWeatherInfo
{
    _weatherIcon_w = nil;
    _weatherIcon_g = nil;
    _cityId = nil;
    _cityName = nil;
    _temperature = nil;
    _updateTime = nil;
    _futureWeather = nil;
    _longUpdateTime = nil;
    _weather = nil;
    _week = nil;
}
@end


@implementation FutureWeather

// 获取温度区间
-(NSString*)tempInterval{
    NSString *temp = nil;
    if (_mintemp.length > 0 && _maxtemp.length > 0) {
        temp = [NSString stringWithFormat:@"%@~%@℃", _mintemp, _maxtemp];
    }
    return temp;    
}

// 周几
//-(void)setWeek:(NSString *)week{
//    if (week.length >= 3) {
//        _week = [NSString stringWithFormat:@"周%@",[week substringFromIndex:2]];
//    }
//    else{
//        _week = week;
//    }
//}


-(void)setMorning_img_title:(NSString *)morning_img_title{
    _morning_img_title = morning_img_title;    
    NSString *imgPath = [NSString stringWithFormat:@"g_d%@",morning_img_title];
    _weatherIcon = [UIImage imageNamed:imgPath];
}
@end


