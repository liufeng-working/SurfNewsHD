//
//  ThreeDayWeatherView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreeDayWeatherView : UIView

+ (CGSize)fitSize;

-(void)refreshWeatherFromFutureWeatherArray:(NSArray *)futureArray;
@end
