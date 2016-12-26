//
//  TodayWeatherView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/7/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherInfo.h"


@interface TodayWeatherView : UIView



- (void)refreshWeatherInfo:(WeatherInfo *)weather;

@end
