//
//  TodayWeatherView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/7/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TodayWeatherView.h"
#import "NSString+Extensions.h"




@interface TodayWeatherView () {
    
    
    __weak WeatherInfo *_weather;
    UIImage *_bgImage;
    UIImage *_centigradeImg; // 摄氏度图片
}

@end
@implementation TodayWeatherView

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(kContentWidth, 350.f);
}



- (void)refreshWeatherInfo:(WeatherInfo *)weather
{
    _weather = weather;
    
    
    // 加载背景图片
    _bgImage = [self weatherBgImage:_weather.weather];
    
    if(!_centigradeImg){
        _centigradeImg = [UIImage imageNamed:@"centigrade"];
    }
    // 根据天气来变化的背景图片
    [self setNeedsDisplay];
    
}

#pragma mark- private method
-(UIImage *)weatherBgImage:(NSString *)weatherDes
{
    NSString *bgName = @"sun";
    NSRange r = [weatherDes rangeOfString:@"/"];
    if (r.location != NSNotFound && r.length > 0) {
        NSArray* comp = [weatherDes componentsSeparatedByString:@"/"];
        weatherDes = comp[0];
    }
    
    NSDictionary *weatherBgImageNames =
  @{    @"晴":@"sun",
        @"云":@"sun",
        @"雪":@"snow",
        @"雷阵雨":@"thundershower",
        @"雨":@"rain",
        @"阴":@"cloudy",
        @"雾":@"fog",
        @"沙":@"fromdust",
        @"尘":@"fromdust",
        @"霾":@"haze",
        @"霰":@"haze",
        @"飑线":@"haze"
    };
    
    if (weatherDes && ![weatherDes isEmptyOrBlank]) {
        for (id key in [weatherBgImageNames allKeys]) {
            NSRange rang = [weatherDes rangeOfString:key];
            if (rang.location != NSNotFound && rang.length >0) {
                bgName = [weatherBgImageNames objectForKey:key];
                break;
            }
        }
        
    }
    return [UIImage imageNamed:bgName];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    // 绘制背景
    if(_bgImage){
        // 720/2 × 480/2 = 360 240
        CGFloat imgW  = _bgImage.size.width;
        CGFloat imgH  = _bgImage.size.height;
        CGFloat imgX = (width - imgW) / 2;
        CGFloat imgY = (height - imgH) / 2;
        [_bgImage drawAtPoint:CGPointMake(imgX, imgY)];
    }
    
    
    // 从Bottom -> top 开始绘制
    CGFloat hSpace = 10.f; // 上下间隔
    CGFloat beginX = 0.f;
    CGFloat h = CGRectGetHeight(self.bounds);
    UIColor *textColor = [UIColor whiteColor];
    
    // 日期 + 周几
    UIFont *dateF = [UIFont systemFontOfSize:12.f];
    CGFloat bottomY = h - 20.f - dateF.lineHeight;
    NSMutableString *text = [NSMutableString stringWithCapacity:20];
    if ([_weather longUpdateTime] &&
        ![[_weather longUpdateTime] isEmptyOrBlank]) {
        [text appendString:[_weather longUpdateTime]];
        [text appendString:@" "];
    }
    if ([_weather week] && ![[_weather week] isEmptyOrBlank]) {
        [text appendString:[_weather week]];
    }
    CGRect dwR = CGRectMake(beginX, bottomY, width, dateF.lineHeight);
    if([text length] > 0) {
        [text surfDrawString:dwR withFont:dateF withColor:textColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        [text deleteCharactersInRange:NSMakeRange(0,text.length)];
    }
    
    // 温度区间数据
    if ([_weather temperature] && ![[_weather temperature] isEmptyOrBlank]) {
        [text appendString:[_weather temperature]];
        dwR = CGRectOffset(dwR, 0, -(hSpace + dateF.lineHeight));
        CGRect dwR2 = CGRectMake(-35, dwR.origin.y, dwR.size.width, dwR.size.height);
        [text surfDrawString:dwR2 withFont:dateF withColor:textColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        [text deleteCharactersInRange:NSMakeRange(0,text.length)];
    }
    if ([_weather wind_scale] && ![[_weather wind_scale] isEmptyOrBlank]) {
        [text appendString:[_weather wind_scale]];
        CGRect dwR3 = CGRectMake(35, dwR.origin.y, dwR.size.width, dwR.size.height);
        if ([text length] > 0) {
            [text surfDrawString:dwR3 withFont:dateF withColor:textColor lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
            [text deleteCharactersInRange:NSMakeRange(0, text.length)];
        }
    }
    
    // 当前温度
    CGRect tempR = CGRectZero;
    if ([_weather temp] && ![[_weather temp] isEmptyOrBlank]) {
        UIFont *tf = [UIFont boldSystemFontOfSize:120];
        [text appendString:[_weather temp]];
        CGFloat tempW =
        [text surfSizeWithFont:tf
             constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                 lineBreakMode:NSLineBreakByWordWrapping].width;
        CGFloat tY = dwR.origin.y - hSpace - tf.pointSize;
        CGFloat tX = (width - tempW)/2.f;
        tempR = CGRectMake(tX, tY, tempW, tf.pointSize);
        [text surfDrawString:tempR withFont:tf withColor:textColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        [text deleteCharactersInRange:NSMakeRange(0,text.length)];
        
        // 绘制摄氏度
        CGPoint centigradePoint = tempR.origin;
        centigradePoint.x += tempW;
        centigradePoint.y += 23.f;
        [_centigradeImg drawAtPoint:centigradePoint];
        
    }
    
    // 当前天气情况
    CGRect wR = CGRectZero;
    if ([_weather weather] &&
        ![[_weather weather] isEmptyOrBlank]) {
        CGFloat wY= tempR.origin.y - 20.f;
        UIFont *wf = [UIFont boldSystemFontOfSize:14];
        wR = CGRectMake(0.f, wY, width, wf.lineHeight);
        [[_weather weather] surfDrawString:wR withFont:wf
                                 withColor:textColor
                             lineBreakMode:NSLineBreakByWordWrapping
                                 alignment:NSTextAlignmentCenter];
    }
    
    // 天气图片
    UIImage *weatherIcon = [_weather weatherIcon_w];
    CGPoint weatherImgPoint = wR.origin;
    weatherImgPoint.x = (width - weatherIcon.size.width)/2.f;
    weatherImgPoint.y -= (weatherIcon.size.height + 5.f);
    [weatherIcon drawAtPoint:weatherImgPoint];
    
    UIGraphicsPopContext();
}


@end
