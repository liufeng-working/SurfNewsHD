//
//  UpdateWeatherResponse.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UpdateWeatherResponse.h"
#import "WeatherInfo.h"

@implementation UpdateWeatherResponse

@synthesize weathers = __ELE_TYPE_FutureWeather;

//{"cityId":"101010100","cityName":"北京","gmzs":"少发","img1":"1","img2":"1","index":"冷","index_ag":"极不易发","index_cl":"较适宜","index_co":"较不舒适","index_ls":"基本适宜","index_tr":"较适宜","index_uv":"最弱","index_xc":"适宜","method":"cityWeather4week","sd":"58","serverTime":"1357537151929","temp":"NA","wcode":"200","wdws":"微风","weather":"多云","weathers":[{"dindex":"1","maxtemp":"0","mintemp":"-9","morning_img_title":"1","night_img_title":"99","time":"2013-01-07","weather":"多云","week":"星期一"},{"dindex":"2","maxtemp":"-1","mintemp":"-11","morning_img_title":"0","night_img_title":"99","time":"2013-01-08","weather":"晴","week":"星期二"},{"dindex":"3","maxtemp":"0","mintemp":"-9","morning_img_title":"0","night_img_title":"1","time":"2013-01-09","weather":"晴转多云","week":"星期三"},{"dindex":"4","maxtemp":"-1","mintemp":"-7","morning_img_title":"2","night_img_title":"1","time":"2013-01-10","weather":"阴转多云","week":"星期四"},{"dindex":"5","maxtemp":"1","mintemp":"-9","morning_img_title":"1","night_img_title":"0","time":"2013-01-11","weather":"多云转晴","week":"星期五"},{"dindex":"6","maxtemp":"0","mintemp":"-7","morning_img_title":"0","night_img_title":"1","time":"2013-01-12","weather":"晴转多云","week":"星期六"}],"week":"星期一"}




- (NSString *)tempRange{
    NSString* tempR = nil;
    if ([[self weathers] count] > 0) {
        FutureWeather *fw = [[self weathers] objectAtIndex:0];
        tempR = [fw tempInterval];       
    }
    return tempR;
}

@end
