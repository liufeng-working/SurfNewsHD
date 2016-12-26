//
//  WeatherView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WeatherView.h"
#import "WeatherManager.h"
#import "ThemeMgr.h"
#import "NotificationManager.h"
#import "UIColor+extend.h"
#import "NSString+Extensions.h"

#ifdef ipad
    #define WeatherViewWidth 136.f
    #define WeatherImageWidth 45.f
    #define WeatherImageHeight 45.f
#else
    #define WeatherViewWidth 100.f
    #define WeatherImageWidth 40.f
    #define WeatherImageHeight 40.f
#endif

#define WeatherViewHeight 50.f
#define CityNameFont 10.f     // 城市名 + 温度 加粗
#define DateFont 9.f          // 日期字体 加粗
#define NAStr @"N/A"
#define TextColor 0xFF4d4e53
#define kHighlighted @"highlighted"

@interface WeatherView (){
    __weak UIActivityIndicatorView *_loadingView;
    
    
    UIColor *_textColor;
    UIColor *_textHLColor;
}
@end



@implementation WeatherView
@synthesize origin=_origin;


+ (CGSize)suitableSize{
    return CGSizeMake(WeatherViewWidth, WeatherViewHeight);
}

- (id)initWithPoint:(CGPoint)origin{
    _origin = origin;
    CGRect rect = {_origin, [WeatherView suitableSize]};
    self = [super initWithFrame:rect];   
    if (self) {
        _timeFont = [UIFont boldSystemFontOfSize:DateFont];
        _cityNameFont = [UIFont boldSystemFontOfSize:CityNameFont];        
        [self initWeatherInfo];
        [self setOpaque:NO];
    }
    return self;    
}
-(void)dealloc{
    [self removeObserver:self forKeyPath:kHighlighted];
}
- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    CGSize size = [WeatherView suitableSize];
    CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
    [super setFrame:rect];
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}


#pragma mark 天气
- (void)initWeatherInfo
{
    CGFloat midX = CGRectGetMidX(self.bounds);
    CGFloat midY = CGRectGetMidY(self.bounds);
    UIActivityIndicatorView *activity =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingView = activity;
    [activity sizeToFit];
    activity.center = CGPointMake(midX, midY);
    [self addSubview:activity];
    [[WeatherManager sharedInstance] addWeatherUpdatedNotify:self];
    
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    [self viewNightModeChanged:isN];
    

    // add KVO 监听是否被点击，来更新界面
   [self addObserver:self forKeyPath:kHighlighted options:NSKeyValueObservingOptionNew context:nil];
}

- (void)checkWeatherChange
{
    if (!_weatherInfo || _weatherInfo.updateTime.length == 0) {
        WeatherManager *wm = [WeatherManager sharedInstance];
        _weatherInfo = wm.weatherInfo; // 注意这里复制一个天气
        [wm updateWeatherInfo];
    }
}


#pragma mark WeatherUpdateDelegate
// 天气将要更新
- (void)weatherWillUpdate
{
    // 获取天气信息
    [_loadingView startAnimating];
    [self setNeedsDisplay];
}

// 天气信息发送改变
- (void)handleWeatherInfoChanged:(BOOL)succeeded
                     weatherInfo:(WeatherInfo*)info
{
    [_loadingView stopAnimating];
    if (succeeded) {
        // 判读天气是否是当日天气，不是就隐藏自己
        _weatherInfo = info;
        [self setNeedsDisplay];
    }

    [self setHidden:!info.isToday]; // 不是今天的天气，就隐藏控件
    [[NotificationManager sharedInstance] sendNotifiWithDeviceInfo];

}


#ifdef ipad
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Drawing code
    if(_weatherInfo == nil) return;
    
    NSInteger imgLeftGap = 4.f;         // 气象图片左边距
    NSInteger imgTopGap = .0f;          // 气象图片上边距
    NSInteger textTopGap = 8.f;         // 文字上边距
    NSInteger textLeftGap = 53.f;
    

    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    
    // 气象图片
    UIImage *img = _weatherInfo.weatherImg;
    CGRect imgRect = CGRectMake(imgLeftGap, imgTopGap, WeatherImageWidth, WeatherImageHeight);
    if (img == nil) {  
        img = [UIImage imageNamed:@"NA"];
    }
    [img drawInRect:imgRect];
    
    
    // 绘制文字区域
    // 日期
    CGSize timeSize = CGSizeZero;
    NSString *timeStr = _weatherInfo.updateTime;
    if (timeStr == nil || [timeStr length] == 0) {
        timeStr = NAStr;
    }
    
    
        // 圆角矩形
        timeSize.width = [timeStr sizeWithFont:_timeFont].width+4.f;
        timeSize.height = _timeFont.lineHeight;
        
        // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
        CGFloat radius = (timeSize.width + timeSize.height) * 0.05;
        
        // 弧度＝(角度/180)*PI  PI = 3.1415
        // 角度 = 弧度/PI * 180
        // 圆角矩形(绘制顺序上右下左)
        float angle0 = 0.f;
        float angle90 = M_PI_2;         // 90/180*PI
        float angle180 = M_PI;          // 180/180*PI
        float angle270 = M_PI + M_PI_2; // 270/180*PI
        
        float ax = textLeftGap + radius;
        float ay = textTopGap;
        float bx = textLeftGap + timeSize.width - radius;
        float by = textTopGap;
        float cx = textLeftGap + timeSize.width;
        float cy = textTopGap + timeSize.height - radius;
        float dx = textLeftGap + radius;
        float dy = textTopGap + timeSize.height;
        float ex = textLeftGap;
        float ey = textTopGap + radius;
 
        // 移动到初始点
        CGContextMoveToPoint(context, ax, ay);
        
        // 绘制第1条线和第1个1/4圆弧
        CGContextAddLineToPoint(context, bx, by);
        CGContextAddArc(context, bx, by+radius, radius, angle270, angle0, 0);
        
        // 绘制第2条线和第2个1/4圆弧
        CGContextAddLineToPoint(context, cx, cy);
        CGContextAddArc(context, cx-radius, cy, radius, angle0, angle90, 0);
        
        // 绘制第3条线和第3个1/4圆弧
        CGContextAddLineToPoint(context, dx, dy);
        CGContextAddArc(context, dx, dy - radius, radius, angle90, angle180, 0);
        
        // 绘制第4条线和第4个1/4圆弧
        CGContextAddLineToPoint(context, ex, ey);
        CGContextAddArc(context, ex + radius, ey, radius, angle180, angle270, 0);
        
        
        CGContextClosePath(context);// 闭合路径        
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.3);// 填充半透明黑色
        CGContextFillPath(context);
        
        // 绘制时间 color(4d4e53)
        CGContextSetFillColorWithColor(context, [UIColor colorWithHexValue:TextColor].CGColor);       
        
        [timeStr drawInRect:CGRectMake(textLeftGap+2, textTopGap, timeSize.width, timeSize.height) withFont:_timeFont];
        CGContextStrokePath(context);
  
    
    
    // 城市名字
    NSString *cityName = _weatherInfo.cityName; // 只能显示4个字符
    if ([cityName length] > 0) {
        CGRect cityNameRect = CGRectZero;
        cityNameRect.origin.x = 88.f;
        cityNameRect.origin.y = textTopGap - (_cityNameFont.lineHeight - _timeFont.lineHeight)*0.5f;
        cityNameRect.size.width = CGRectGetWidth([self bounds])-cityNameRect.origin.x;
        cityNameRect.size.height = _cityNameFont.lineHeight;        
        [cityName drawInRect:cityNameRect withFont:_cityNameFont
               lineBreakMode:NSLineBreakByTruncatingTail];
        CGContextStrokePath(context);
    }
    
    // 温度
    NSString *temp = _weatherInfo.temperature;
    if (temp == nil || [temp length ] == 0) {
        temp = NAStr;
    }
    CGRect tempRect = {{textLeftGap, textTopGap + _cityNameFont.lineHeight},
        {100.f, _cityNameFont.lineHeight}};
    [temp drawInRect:tempRect withFont:_cityNameFont];
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}
#else

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if(_weatherInfo == nil) return;
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat imgTopGap = (height-WeatherImageHeight)/2.f;// 气象图片上边距
    CGFloat textTopGap = 8.f;           // 文字上边距
    CGFloat textWidth = width - WeatherImageWidth - 2.f - 7.f;
    CGFloat textLeftGap = textWidth - 22.f+5.f;
    CGFloat imgLeftGap = 0.f;// 气象图片左边距
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);
    
    // 气象图片
    UIImage *img = isN?_weatherInfo.weatherIcon_w:_weatherInfo.weatherIcon_g;
    CGRect imgRect = CGRectMake(imgLeftGap, imgTopGap+3, 30, 30);
    if (img == nil) {
        img = [UIImage imageNamed:@"NA"];
    }
    [img drawInRect:imgRect];    
    
    UIColor *textColor = _textColor;
    if ([self isHighlighted]) {
        textColor = _textHLColor;
    }
    
    // 温度
    NSString *temp = _weatherInfo.temperature;
    if (temp == nil || [temp length ] == 0) {
        temp = NAStr;
    }
    CGRect tempRect = {{textLeftGap, textTopGap}, {textWidth, _cityNameFont.lineHeight}};
    [temp surfDrawString:tempRect
                withFont:_cityNameFont
               withColor:textColor
           lineBreakMode:NSLineBreakByWordWrapping
               alignment:NSTextAlignmentLeft];
    CGContextStrokePath(context);
    
    // 城市名字
    CGRect cityNameRect = CGRectZero;
    NSString *cityName = _weatherInfo.cityName; // 只能显示4个字符
    if ([cityName length] > 0) {
        cityNameRect.origin.x = textLeftGap ;
        cityNameRect.origin.y = textTopGap + _cityNameFont.lineHeight ;
        cityNameRect.size.width = textWidth;         // 只能显示4个字符
        cityNameRect.size.height = _cityNameFont.lineHeight;
        if (cityName.length >= 4) {
            cityName = [cityName substringWithRange:NSMakeRange(0, 4)];
        }
        [cityName surfDrawString:cityNameRect
                        withFont:_cityNameFont
                       withColor:textColor
                   lineBreakMode:NSLineBreakByTruncatingTail
                       alignment:NSTextAlignmentLeft];
        CGContextStrokePath(context);
    }
    
    UIGraphicsPopContext();
}

#endif

- (void)viewNightModeChanged:(BOOL)isNight
{
    //设置文字颜色
    _textHLColor = [UIColor colorWithHexValue:0xffAD2F2F];
    
    _textColor =
    isNight?[UIColor whiteColor]:[UIColor colorWithHexValue:0xFF333333];
    [self setNeedsDisplay];
}


#pragma mark- KVO 
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kHighlighted]) {
        [self setNeedsDisplay];
    }
}
@end
