//
//  UpdateWeatherRequest.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface UpdateWeatherRequestBase : SurfJsonRequestBase

@property NSString *method;         // 更新方法  "gps"or "cityWeather4week"
@property NSString *serverTime;     // 服务器更新天气时间
@property NSString *cityVersion;    // 城市版本 固定 1.0

@end

///////////////////////////////
// 根据GPS信息更新天气数据
@interface UpdateWeatherRequestByGPS : UpdateWeatherRequestBase
@property double lng;
@property double lat;

-(id)initWithGPS:(double)lng latitude:(double)lat serverTime:(NSString*)serverTime;
@end


//////////////////////////////
// 根据城市ID更新天气数据
@interface UpdateWeatherRequestByCityId : UpdateWeatherRequestBase
//@property NSString *cityId;

-(id)initWithCityID:(NSString*)cityID serverTime:(NSString*)serverTime;
@end