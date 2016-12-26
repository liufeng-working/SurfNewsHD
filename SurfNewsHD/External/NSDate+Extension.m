//
//  NSDate+Extension.m
//  SurfNewsHD
//
//  Created by XuXg on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)


- (NSString *)getWeek
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSUInteger flag = NSCalendarUnitWeekday;
    NSDateComponents *components = [cal components:flag fromDate:self];
    NSInteger week = [components weekday];
    
    
//    1~7 (0 padded Day of Week)
//    E~EEE:  Sun/Mon/Tue/Wed/Thu/Fri/Sat
//EEEE: Sunday/Monday/Tuesday/Wednesday/Thursday/Friday/Saturday
    if (week >0 && week <=7) {
        return @[@"",@"周日" ,@"周一" ,@"周二" ,@"周三" ,@"周四" ,@"周五",@"周六"][week];
    }
    return @"";
}

@end
