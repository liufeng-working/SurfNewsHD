//
//  CloudViewBase.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CloudViewBase.h"



@implementation CloudViewBase

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_scrollView];
    }
    return self;
}



#pragma mark  无数据显示图片和文子
// 初始化无数据控件
- (void)initNotDateCtrl{
    if (_notDataImageView == nil) {
        
        CGRect rect = CGRectZero;
        UIImage *img = [UIImage imageNamed:@"notData"];
        _notDataImageView = [[UIImageView alloc] initWithImage:img];
        rect.size = img.size;
        rect.origin.x = (kContentWidth - rect.size.width) * 0.5;
        rect.origin.y = (kContentHeight - rect.size.height) * 0.3;
        [_notDataImageView setFrame:rect];
        [self addSubview:_notDataImageView];
        
        
        rect.origin.y += rect.size.height + 10.f;
        rect.size.width = 300.f;
        rect.size.height = 27.f;
        rect.origin.x = (kContentWidth - rect.size.width ) * 0.5;
        _notDataMsgLbl = [[UILabel alloc] initWithFrame:rect];
        [_notDataMsgLbl setText:@"您还未进行收藏"];
        [_notDataMsgLbl setFont:[UIFont boldSystemFontOfSize:18.f]];
        [_notDataMsgLbl setTextColor:[UIColor colorWithHexValue:0xFF908678]];
        [_notDataMsgLbl setBackgroundColor:[UIColor clearColor]];
        [_notDataMsgLbl setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_notDataMsgLbl];
    }
}


- (void)hiderNotDataView:(BOOL)hider{
    if (!hider) {
        [self initNotDateCtrl];
    }
    [_notDataMsgLbl setHidden:hider];
    [_notDataImageView setHidden:hider];
}

// 相同一天的时间
- (BOOL)equalDayDate:(NSDate*)date1 date:(NSDate*)date2{
    if (date1 == nil) {
        if (date2 == nil) {
            return YES;
        }
        return NO;
    }
    
    if (date2 == nil) {
        if (date1 != nil) {
            return NO;
        }
        return YES;
    }
    
    
    // 只要年月日相同，就表示是相同的时间区域
    NSUInteger flags = NSCalendarUnitWeekday;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComp1 = [calendar components:flags fromDate:date1];
    NSDateComponents* dateComp2 = [calendar components:flags fromDate:date2];
    if ([dateComp1 year] != [dateComp2 year] ||
        [dateComp1 month] != [dateComp2 month] ||
        [dateComp1 day] != [dateComp2 day]) {
        return NO;
    }
    return YES;
}
@end
