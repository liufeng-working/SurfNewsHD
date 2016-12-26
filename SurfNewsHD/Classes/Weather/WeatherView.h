//
//  WeatherView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherInfo.h"
#import "WeatherManager.h"

@interface WeatherView : UIControl<WeatherUpdateDelegate>{
    UIFont *_cityNameFont;
    UIFont *_timeFont;
    
    WeatherInfo *_weatherInfo;
}
@property(nonatomic) CGPoint origin;


+ (CGSize)suitableSize;

- (id)initWithPoint:(CGPoint)origin;
-(void)checkWeatherChange;          // 检查天气是否改变



- (void)setFrame:(CGRect)frame NS_DEPRECATED_IOS(2_0, 3_0);
- (id)initWithFrame:(CGRect)frame NS_DEPRECATED_IOS(2_0, 3_0);
@end
