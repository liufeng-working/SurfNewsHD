//
//  FutureWeatherView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FutureWeatherView.h"
#import "WeatherInfo.h"
#import "CGContextUtil.h"
#import "PhoneSelectCityController.h"
#import "PhoneHotRootcontroller.h"
#import "UIColor+extend.h"

@implementation FutureWeatherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];        
        _naIcon = [UIImage imageNamed:@"NA"];
        
        // 加载风火轮
        float width = CGRectGetWidth(self.bounds);
        float hieght = CGRectGetHeight(self.bounds);
        CGRect loadingRect = CGRectMake((width-40)/2, (hieght-40)/2, 40, 40);
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView setFrame:loadingRect];
        [_loadingView setHidesWhenStopped:YES];
        [self addSubview:_loadingView];
        
        
        // 天气更新事件
        [[WeatherManager sharedInstance] addWeatherUpdatedNotify:self];
        
        // 点击事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(selectCityClick:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    }
    return self;
}


-(void)reloadWeatherInfo:(WeatherInfo*)weather{
    _touchRect = CGRectZero;
    _touchRefreshRect = CGRectZero;
    _weather = weather;
    
    _status = ([_weather longUpdateTime].length == 0) ? 1 : 0;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (_weather == nil) {
        return;
    }
    
    float arrowHeight = 15.f; // 箭头高度
    float arrowX = 180.f;
    
    static UIFont *bigFont = nil;
    static UIFont *midFont = nil;
    static UIFont *smallFont = nil;
    if (!bigFont) {
        bigFont = [UIFont systemFontOfSize:18.f];
        midFont = [UIFont systemFontOfSize:15.f];
        smallFont = [UIFont systemFontOfSize:12.f];
    }
    

    UIColor *redColor = [UIColor colorWithHexValue:0xFFad2f2f];
    UIColor *grayColor =[UIColor colorWithHexValue:0xFF999292];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);
    
    
    // 背景
    if (CGPointEqualToPoint(rect.origin, CGPointZero)) {
        float width = CGRectGetWidth(self.bounds);
        float height = CGRectGetHeight(self.bounds);
        
        float ax = 0.f;
        float ay = arrowHeight;
        float bx = arrowX;
        float by = arrowHeight;
        float cx = arrowX+13.f;
        float cy = 0.f;
        float dx = cx;
        float dy = arrowHeight;
        float ex = width;
        float ey = arrowHeight;
        float fx = width;
        float fy = height;
        float gx = 0.f;
        float gy = height;
        
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, ax, ay);
        CGPathAddLineToPoint(pathRef, NULL, bx, by);
        CGPathAddLineToPoint(pathRef, NULL, cx, cy);
        CGPathAddLineToPoint(pathRef, NULL, dx, dy);
        CGPathAddLineToPoint(pathRef, NULL, ex, ey);
        CGPathAddLineToPoint(pathRef, NULL, fx, fy);
        CGPathAddLineToPoint(pathRef, NULL, gx, gy);
        CGPathCloseSubpath(pathRef);
        CGContextAddPath(context, pathRef);
        CGContextSetFillColorWithColor(context, _bgColor.CGColor);
        CGContextFillPath(context);
        CGPathRelease(pathRef);
    }

    
    // 第一排元素
    float rowHeight1 = bigFont.lineHeight;
    
    // 大标题（冲浪天气）
    NSString *title = @"天气";
    CGRect titleRect = CGRectZero;
    titleRect.origin = CGPointMake(12.f, 12.f + arrowHeight);
    titleRect.size = SN_TEXTSIZE(title, bigFont);
    
    
    if (CGRectContainsRect(rect, titleRect)){
        [title surfDrawString:titleRect
                     withFont:bigFont
                    withColor:redColor
                lineBreakMode:NSLineBreakByWordWrapping
                    alignment:NSTextAlignmentCenter];
    }
  

    // 城市名
    {
        // 背景
        CGRect cityBgRect = CGRectMake(60.f, 12.f + arrowHeight, 65.f, rowHeight1);        
        CGContextSetFillColorWithColor(context, redColor.CGColor);
        CGContextFillRect(context, cityBgRect);
        _touchRect = cityBgRect;
        
        // 名字
        CGRect cityNameRect = cityBgRect;
        cityNameRect.origin.y += (rowHeight1-smallFont.lineHeight)*0.5;
        cityNameRect.size.height = smallFont.lineHeight;
        UIColor *cityNameColor = _isHighlight ? [UIColor grayColor] :[UIColor whiteColor];
        [_weather.cityName surfDrawString:cityNameRect withFont:smallFont withColor:cityNameColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }



    // 天气更新时间
    NSString *updateTime;
    if ([_weather longUpdateTime].length > 0) {
        updateTime = [NSString stringWithFormat:@"更新时间: %@", [_weather longUpdateTime]];
    }else{
        updateTime = @"更新时间: 无";
    }
    CGRect updateTimeRect = CGRectMake(140.f, 12.f + arrowHeight, 0.f, 0.f);
    updateTimeRect.size = SN_TEXTSIZE(updateTime, smallFont);
    updateTimeRect.origin.y += (rowHeight1 - smallFont.lineHeight) * 0.5f;
    if (CGRectContainsRect(rect, updateTimeRect)) {
//        CGContextSetFillColorWithColor(context, grayColor.CGColor);
//        [updateTime drawInRect:updateTimeRect withFont:smallFont];
        [updateTime surfDrawString:updateTimeRect withFont:smallFont withColor:grayColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }
    else{
        return;// 后面的元素就不执行了。主要是绘制局部区域。
    }

    // 0 默认状态  1 NA状态   2 加载状态   3 加载异常状态
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
                       withColor:redColor
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentLeft];
        
        // 刷新按钮
        if (_status != 2) {
            float btnWidth = 60.f;
            float btnX = (CGRectGetWidth(self.bounds) - btnWidth) * 0.5f;
            CGRect btnRect = CGRectMake(btnX, 130, btnWidth, 30.f);
            CGContextSetFillColorWithColor(context, redColor.CGColor);
            CGContextFillRect(context, btnRect);
            _touchRefreshRect = btnRect;
            NSString *btnStr = @"刷新";
            CGRect btnStrRect = btnRect;
            btnStrRect.size.height = midFont.lineHeight;
            btnStrRect.origin.y += (CGRectGetHeight(btnRect)-midFont.lineHeight) * 0.5f;
            [btnStr surfDrawString:btnStrRect withFont:midFont withColor:[UIColor whiteColor] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        }
        return;
    }
    
    
    
  // 第二排元素
    float rowY = arrowHeight + rowHeight1 + 14.f;
    float rowHeight2 = 40;
    float rowCurWidth = 0.f;
    
    // 天气图标
    if (_weather.weatherIcon_g) {
        CGRect weatherImageRect = CGRectZero;
        weatherImageRect.size = _weather.weatherIcon_g.size;
        weatherImageRect.origin = CGPointMake(10.f, rowY);
        [_weather.weatherIcon_g drawInRect:weatherImageRect];
        rowHeight2 = CGRectGetHeight(weatherImageRect);
    }

    // 天气温度
    if ([_weather temperature].length > 0) {
        CGRect tempRect = CGRectMake(60.f, rowY+10.f, 0.f, 0.f);
        tempRect.size = SN_TEXTSIZE([_weather temperature], bigFont);
        [[_weather temperature] surfDrawString:tempRect withFont:bigFont withColor:redColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        rowCurWidth = tempRect.origin.x + tempRect.size.width;
    }


    // 天气
    if ([_weather weather].length > 0) {
        CGRect rect = CGRectMake(rowCurWidth + 13.f, rowY+13.f, 0.f, 0.f);
        rect.size = SN_TEXTSIZE([_weather weather], smallFont);
        [[_weather weather] surfDrawString:rect
                                  withFont:smallFont
                                 withColor:redColor
                             lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }
    
    
    // 第三排元素
    // 未来3天天气
    if ([[_weather futureWeather] count] > 3)
    {
        float y = rowY + rowHeight2 + 10;
        float w = CGRectGetWidth(self.bounds) / 3;
        for (NSInteger i = 1; i < 4; ++i) {
            FutureWeather *futureWeather = _weather.futureWeather[i];
            if (![futureWeather isKindOfClass:[FutureWeather class]]) {
                continue;
            }
            
            CGFloat begionX = (i-1)*w;
            CGFloat begionY = y;
            
            
            // 周几 居中显示
            if (futureWeather.week.length > 0) {
                CGSize weekSize = SN_TEXTSIZE(futureWeather.week, smallFont);
                CGContextSetFillColorWithColor(context, redColor.CGColor);
                [futureWeather.week surfDrawAtPoint:CGPointMake(begionX + (w-weekSize.width) * 0.5, y) withFont:smallFont];
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
                weatherRect.size = SN_TEXTSIZE(futureWeather.weather, smallFont);
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
            weekRect.size = SN_TEXTSIZE(temp, midFont);
            weekRect.origin.x = begionX + (w-CGRectGetWidth(weekRect))*0.5f;
            [temp surfDrawString:weekRect
                        withFont:midFont
                       withColor:redColor
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentLeft];
            
            // 绘制分割线
            if (i > 1) {
                begionY += CGRectGetHeight(weekRect) + 10;
                CGContextSetStrokeColorWithColor(context, _separatorColor.CGColor);
                CGContextMoveToPoint(context, begionX, y);
                CGContextAddLineToPoint(context, begionX, begionY);
                CGContextStrokePath(context);
            }
        }
    }

    UIGraphicsPopContext();
}


-(void)selectCityClick:(id)sender
{/*
    Class classType = [PhoneHotRootController class];
    PhoneHotRootController *controller = [self findUserObject:classType];
    if (controller && [controller isKindOfClass:classType]) {
        _isHighlight = NO;
        [controller accessSelectCityController];
        [self setNeedsDisplay];
    }
    */
}

#pragma mark UITapGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint touchPoint = [touch locationInView:self];
    if (!CGRectIsEmpty(_touchRect) && CGRectContainsPoint(_touchRect, touchPoint)) {
        _isHighlight = YES;
        [self setNeedsDisplayInRect:_touchRect];
        return YES; // 不返回YES 手势事件就不触发
    }
    else if (_status > 0 && !CGRectIsEmpty(_touchRefreshRect) && ![_loadingView isAnimating]) {    // 点击刷新按钮
        _touchRefreshRect = CGRectZero;
        
        // 重新请求天气
        [[WeatherManager sharedInstance] updateWeatherInfo];
    }
    
    return NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_isHighlight) {
         _isHighlight = NO;
        [self setNeedsDisplayInRect:_touchRect];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_isHighlight) {
        _isHighlight = NO;
        [self setNeedsDisplayInRect:_touchRect];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_touchRect, touchPoint)) {
        if (_isHighlight) {
            _isHighlight = NO;
            [self setNeedsDisplayInRect:_touchRect];
        }
    }
    else{
        if (!_isHighlight) {
            _isHighlight = YES;
            [self setNeedsDisplayInRect:_touchRect];
        }
    }
}

#pragma mark WeatherUpdateDelegate
// 天气将要更新
- (void)weatherWillUpdate{
    _status = 2; // 加载状态
    [_loadingView startAnimating];
    [self setNeedsDisplay];
}
- (void)handleWeatherInfoChanged:(BOOL)succeeded weatherInfo:(WeatherInfo*)info{
    _status = succeeded ? 0 : 3;    
    [_loadingView stopAnimating];
    _touchRect = CGRectZero;
    _touchRefreshRect = CGRectZero;
    _weather = info;
    [self setNeedsDisplay];
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight)
    {
        _bgColor = [UIColor colorWithHexValue:0xFF1b1b1C];
        _separatorColor = [UIColor colorWithHexValue:0xFF3C3C3E];
    }
    else
    {
        _separatorColor = [UIColor colorWithHexValue:0xFFdcdbdb];
        _bgColor = [UIColor whiteColor];
    }
}
@end
