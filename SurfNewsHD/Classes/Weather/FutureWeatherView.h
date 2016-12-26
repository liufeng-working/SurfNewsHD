//
//  FutureWeatherView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherManager.h"


@class WeatherInfo;

@interface FutureWeatherView : UIView<UIGestureRecognizerDelegate,WeatherUpdateDelegate>{
    __weak WeatherInfo *_weather;
    UIImage *_naIcon;
    CGRect _touchRect;
    BOOL _isHighlight;
    
    // 刷新天气失败
    NSUInteger _status; // 0 默认状态  1 NA状态   2 加载状态   3 加载异常状态
    CGRect _touchRefreshRect;// 点击刷新区域
    UIActivityIndicatorView *_loadingView;
    
    UIColor *_bgColor;        // 背景颜色
    UIColor *_separatorColor; // 分割线颜色
}


-(void)reloadWeatherInfo:(WeatherInfo*)weather;
@end
