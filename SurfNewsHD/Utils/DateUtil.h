//
//  DateUtil.h
//  SurfNewsHD
//
//  Created by XuXg on 15/6/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject


/**
 *  计算时间间隔，时间点源于1970
 *
 *  @param timeInterval 时间间隔
 *
 *  @return 返回和当前时间的文字描述
 */
+(NSString*)calcTimeInterval:(double)timeInterval;

@end
