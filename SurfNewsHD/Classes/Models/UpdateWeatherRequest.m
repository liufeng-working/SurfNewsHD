//
//  UpdateWeatherRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UpdateWeatherRequest.h"


///////////////////////////////////////
@implementation UpdateWeatherRequestBase
-(id) init
{
    if(self = [super init])
    {
        self.serverTime = @"";
        self.cityVersion = @"1.0"; // 固定代码        
        if([self isKindOfClass:[UpdateWeatherRequestByGPS class]])
            self.method = @"gps";
        else if([self isKindOfClass:[UpdateWeatherRequestByCityId class]])
            self.method = @"cityWeather4week";
    }
    return self;
}
@end


////////////////////////////////////////////
@implementation UpdateWeatherRequestByGPS

-(id)initWithGPS:(double)lng latitude:(double)lat serverTime:(NSString*)serverTime
{
    if(self = [super init])
    {
        self.lng = lng;
        self.lat = lat;        
        if(serverTime != nil)
        {
            self.serverTime = serverTime;
        }
    }
    return self;
}
@end


////////////////////////////////////////////
@implementation UpdateWeatherRequestByCityId

-(id)initWithCityID:(NSString*)cityID serverTime:(NSString*)serverTime
{
    if(self = [super init])
    {
        self.cityId = cityID;
        if(serverTime != nil)
        {
            self.serverTime = serverTime;
        }
    }
    return self;
}
@end








