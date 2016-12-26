//
//  DateUtil.m
//  SurfNewsHD
//
//  Created by XuXg on 15/6/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+(NSString*)calcTimeInterval:(double)timeInterval
{
    NSTimeInterval nowIner = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = nowIner - timeInterval;
    if(interval < 60)
        return @"1分钟前";
    else if(interval > (3600*24)){
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd";
        return [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }else {
        NSInteger hours = ((NSInteger)interval)%(3600*24)/3600;
        NSInteger minute = ((NSInteger)interval)%(3600*24)%3600/60;
        if (hours == 0) {
            return [[NSString alloc] initWithFormat:@"%@分钟前",@(minute)];
        }
        return [[NSString alloc] initWithFormat:@"%@小时前",@(hours)];
    }
    return @"最新";
}







@end
