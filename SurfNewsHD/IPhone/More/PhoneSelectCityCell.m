//
//  PhoneSelectCityCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSelectCityCell.h"
#import "CityInfo.h"
#import <UIKit/UIKit.h>
#import "NSString+Extensions.h"
#import "CGContextUtil.h"

#define CityCtrlFontSize 15.f



@interface SelectCityCellData (){
    float _maxWidth;
}

@property(nonatomic,readonly) NSMutableArray *cities;
@property(nonatomic,readonly) NSMutableArray *citiesRect;   // 坐标
@end

@implementation SelectCityCellData
@synthesize CellHeight = _CellHeight;

- (id)initWithCities:(NSArray*)cities showWidth:(int)maxWidth{
    if (self = [super init]) {
        _maxWidth = maxWidth;
        _cities = [NSMutableArray arrayWithArray:cities];
        _citiesRect = [NSMutableArray arrayWithCapacity:cities.count];
        [self calcCityCtrlLayout:_maxWidth];
    }
    return self;
}

// 计算控件布局数据
- (void)calcCityCtrlLayout:(NSInteger)maxWidth
{
    if ([_cities count] < 1) {
        return;
    }
    
    float lrSpace = 20.f;   // 左右间隔
    float tbSpace = 10.f;   // 上下间隔
    float beginX = 10.f;
    float beginY = 10.0;
    NSInteger row = beginY;
    NSInteger column = beginX;
    maxWidth -= 5.f;
    float ctlHeight = 25.f;
    [_citiesRect removeAllObjects];
    for (NSInteger i = 0; i < [_cities count]; ++i) {
        CityInfo *info = [_cities objectAtIndex:i];
        if (info != nil && [info isKindOfClass:[CityInfo class]]) {
            float ctrWidth = 80.f;
            if (column + ctrWidth > maxWidth) {
                column = beginX;
                row += ctlHeight + tbSpace;                
            }            
            CGRect ctlRect = CGRectMake(column, row, ctrWidth, ctlHeight);
            NSValue *rectValue = [NSValue valueWithCGRect:ctlRect];
            [_citiesRect addObject:rectValue];
            column += ctrWidth + lrSpace;
        }
    }
    _CellHeight = row + ctlHeight + lrSpace;
}

- (float)CellHeight{
    if (_CellHeight == 0) {
        [self calcCityCtrlLayout:_maxWidth];
    }
    return _CellHeight;
}

@end


///////////////////////////////////////////////////////////////////
// PhoneSelectCityCell
///////////////////////////////////////////////////////////////////
@implementation PhoneSelectCityCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _touchRect = CGRectZero;
        _touchCityInfo = nil;
        
        _btnFont = [UIFont systemFontOfSize:CityCtrlFontSize];
        _btnTextColor = [UIColor colorWithHexValue:0xFF999292];
        _btnTextHColor = [UIColor redColor];
        _roundBtbMargeColor = [UIColor colorWithHexValue:0xffBFBEC1];
        
        // 手势事件
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];        
        [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    }
    return self;
}

// 重新加载城市数据
- (void)reloadCities:(SelectCityCellData*)cityData{    
    _tempCellData = cityData;
    [self setNeedsDisplay];
}


// 恢复Cell状态
- (void)recoverCellState{
    if (CGRectGetHeight(_touchRect) > 0) {
        CGRect temp = _touchRect;
        _touchRect = CGRectZero;
        _touchCityInfo = nil;
        [self setNeedsDisplayInRect:temp];
    }
}



- (void)drawRect:(CGRect)rect
{
    if (!(_tempCellData.cities.count > 0)) {
        return;
    }
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);
    
    // 原因是因为默认情况下，锯齿显示，所以它显示为宽度= 2.0，关闭消除锯齿可以解决问题了。
//    CGContextSetShouldAntialias(context, NO);

    
    for(NSInteger i = 0; i < _tempCellData.cities.count; ++i){
        CityInfo *cityInfo = [_tempCellData.cities objectAtIndex:i];
        NSValue *rectValue = [_tempCellData.citiesRect objectAtIndex:i];
        
        // 只绘制相交的区域
        if (CGRectContainsRect(rect, [rectValue CGRectValue])) {
            // button 圆角矩形路径
            CGPathRef pathRef =
            [CGContextUtil RoundedRectPathRef:[rectValue CGRectValue]
                                       radius:2];
            
            // Button 背景矩形
            if (CGRectContainsRect(_touchRect, [rectValue CGRectValue])) {
               CGContextSetFillColorWithColor(context, _roundBtnHLColor.CGColor);
            }
            else{
                CGContextSetFillColorWithColor(context, _roundBtnBgColor.CGColor);
            }
            CGContextAddPath(context, pathRef);
            CGContextFillPath(context);
            
            // Button 边框
            CGContextSetStrokeColorWithColor(context, _roundBtbMargeColor.CGColor); // 圆角边距矩形颜色
            CGContextAddPath(context, pathRef);
            CGContextStrokePath(context);           
            
            
            // 绘制城市名         
            CGContextSetFillColorWithColor(context, _btnTextColor.CGColor); // 文字颜
            CGRect textRect = [rectValue CGRectValue];
            textRect.origin.y += (textRect.size.height-_btnFont.lineHeight) * 0.5f;
            textRect.size.height = _btnFont.lineHeight;
            [cityInfo.name surfDrawString:textRect
                                 withFont:_btnFont
                                withColor:_btnTextColor
                            lineBreakMode:NSLineBreakByWordWrapping
                                alignment:NSTextAlignmentCenter];
        }      
    }    
    
    
    UIGraphicsPopContext();
    
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint touchPoint = [touch previousLocationInView:self];
    if(touchPoint.x > 0 && touchPoint.y > 0){
        // 处理点击特效
        for(NSInteger i=0; i<_tempCellData.cities.count; ++i){
            NSValue *rectValue = [_tempCellData.citiesRect objectAtIndex:i];
            if (CGRectContainsPoint([rectValue CGRectValue], touchPoint)) {
                _touchRect = [rectValue CGRectValue];
                _touchCityInfo = [_tempCellData.cities objectAtIndex:i];
                [self setNeedsDisplayInRect:_touchRect];
                break;
            }
        }
    }
    return NO;// NO 会处理touchesBegan
}




-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];

    // 触发点击事件
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (touches.count == 1 && CGRectContainsPoint(_touchRect, touchPoint) && _touchCityInfo) {
        if ([self.selectCityDelegate respondsToSelector:@selector(selectCity:)]) {
            [self.selectCityDelegate selectCity:_touchCityInfo];
        }
    }
    
    // 恢复未点击效果
    [self recoverCellState];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_touchRect, touchPoint)) {
        [self recoverCellState];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self recoverCellState];
}


-(void)viewNightModeChanged:(BOOL)isNight{
    if (isNight) {
        _roundBtnBgColor = [UIColor colorWithHexValue:0xff1b1b1c];
        _roundBtnHLColor = [UIColor colorWithHexValue:0xffAD2F2F];
    }
    else{
        _roundBtnBgColor = [UIColor colorWithHexValue:0xffFFFFFF];
        _roundBtnHLColor = [UIColor colorWithHexValue:0xffAD2F2F];
    }
}
@end
