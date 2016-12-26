//
//  ThreeDayWeatherView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ThreeDayWeatherView.h"
#import "NSString+Extensions.h"
#import "WeatherInfo.h"


@interface ThreeDayWeatherView() {
    
    
    NSMutableArray *_weathers;
    NSInteger _status;
    UIImage *_naIcon;           // 背景颜色
    UIColor *_separatorColor;   // 分割线颜色
    UIColor *_textColor;        // 文字的颜色

}


@end

@implementation ThreeDayWeatherView

+ (CGSize)fitSize
{
    return CGSizeMake(kContentWidth, 150);
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _naIcon = [UIImage imageNamed:@"NA"];
        _weathers = [NSMutableArray arrayWithCapacity:3];
        
        self.backgroundColor = [UIColor clearColor];
        BOOL isN = [ThemeMgr sharedInstance].isNightmode;
        [self viewNightModeChanged:isN];
    }
    return self;
}

-(void)refreshWeatherFromFutureWeatherArray:(NSArray *)futureArray
{
    [_weathers removeAllObjects];
    
    _status = 1;
    if (futureArray && [futureArray count] > 0) {
        _status = 0;
        [_weathers addObjectsFromArray:futureArray];
    }
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIFont *midFont = [UIFont systemFontOfSize:15.f];
    UIFont *smallFont = [UIFont systemFontOfSize:12.f];
    UIColor *grayColor =[UIColor colorWithHexValue:0xFF999292];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);

    
    // 0 默认状态  1 NA状态   2 加载状态 3 加载异常状态
    if (_status > 0) {
        NSString *titleStr;
        if (_status == 1) {     // NA状态
            titleStr = @"没有天气信息";
        }
        else if(_status == 2){  // 2 加载状态
            titleStr = @"正在加载. . .";
        }
        else if(_status == 3){  // 加载异常状态
            titleStr = @"天气加载异常！！！";
        }
        
        // 显示提示文字
        CGRect strRect = CGRectZero;
        strRect.size = SN_TEXTSIZE(titleStr, midFont);
        strRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(strRect)) * 0.5;
        strRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(strRect)) * 0.5;
        [titleStr surfDrawString:strRect
                        withFont:midFont
                       withColor:_textColor
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentLeft];
    }
    else {
        NSInteger showDays = 4; //未来4天天气
        CGFloat y = 10;
        CGFloat w = CGRectGetWidth(self.bounds) / showDays;
        for (NSInteger i = 1; i< [_weathers count] && i <= showDays; ++i) {
            FutureWeather *futureWeather = _weathers[i];
            if (![futureWeather isKindOfClass:[FutureWeather class]]) {
                continue;
            }
            
            CGFloat begionX = (i-1)*w;
            CGFloat begionY = y;
            
            
            // 周几 居中显示
            if (futureWeather.week.length > 0) {
                [_textColor setFill];
                CGSize weekSize = SN_TEXTSIZE(futureWeather.week, midFont);
                [futureWeather.week surfDrawAtPoint:CGPointMake(begionX + (w-weekSize.width) * 0.5, y) withFont:midFont];
                begionY += weekSize.height;
            }
            
            
            // 天气图片
            UIImage *icon = futureWeather.weatherIcon;
            if (!icon) {
                icon  = _naIcon;
            }
            begionY += 6.f;
            CGRect iconRect = CGRectZero;
            iconRect.size = icon.size;
            iconRect.origin = CGPointMake(begionX + (w-CGRectGetWidth(iconRect))*0.5f, begionY);
            [icon drawInRect:iconRect];
            begionY += iconRect.size.height;
            
            
            // 天气
            {
                begionY += 6.f;
                CGRect weatherRect = CGRectZero;
                weatherRect.size =
                SN_TEXTSIZE(futureWeather.weather, smallFont);
                weatherRect.origin.y = begionY;
                weatherRect.origin.x = begionX + (w-CGRectGetWidth(weatherRect))*0.5f;
                [futureWeather.weather surfDrawString:weatherRect
                                             withFont:smallFont
                                            withColor:grayColor
                                        lineBreakMode:NSLineBreakByWordWrapping
                                            alignment:NSTextAlignmentLeft];
                begionY += CGRectGetHeight(weatherRect);
            }
            
            
            // 温度
            begionY += 10.f;
            NSString *temp = [futureWeather tempInterval];
            if (temp.length <= 0) {
                temp = @"N/A";
            }
            CGRect weekRect = CGRectMake(0.f, begionY, 0.f, 0.f);
            weekRect.size = SN_TEXTSIZE(temp, smallFont);
            weekRect.origin.x = begionX + (w-CGRectGetWidth(weekRect))*0.5f;
            [temp surfDrawString:weekRect
                        withFont:smallFont
                       withColor:_textColor
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentLeft];
            
            // 绘制分割线
            if (i > 1) {
                begionY += CGRectGetHeight(weekRect) + 10;
                [_separatorColor setStroke];
                CGContextMoveToPoint(context, begionX, y);
                CGContextAddLineToPoint(context, begionX, begionY);
                CGContextStrokePath(context);
            }
        }
    }
    UIGraphicsPopContext();
}


-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        _textColor = [UIColor whiteColor];
        _separatorColor = [UIColor colorWithHexValue:0xFF3C3C3E];
    }
    else {
        _separatorColor = [UIColor colorWithHexValue:0xFFdcdbdb];
        _textColor = [UIColor colorWithHexValue:0xff333333];
    }
    [self setNeedsDisplay];
}


@end
