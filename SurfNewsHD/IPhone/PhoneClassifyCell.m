//
//  PhoneClassifyCell.m
//  SurfNewsHD
//
//  Created by xuxg on 14-10-13.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneClassifyCell.h"
#import "UIView+NightMode.h"
#import "ThemeMgr.h"
#import "NSString+Extensions.h"
#import "SurfFlagsManager.h"


@interface PhoneClassifyCell ()
{
    
    UIColor *_selectBgColor;            // 选择的背景颜色
    UIColor *_backgroundColorClone;     // 原始的背景颜色
    
    UIColor *_titleColor;
    UIColor *_contentColor;
    
    UIFont *_titleFont;
    UIFont *_contentFont;
    
    UIColor *_lineColor;    // 分割线颜色
    UIColor *_arrowColor;   // 右箭头颜色
}

@end



@implementation PhoneClassifyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroundColorClone = [UIColor clearColor];
        
        _titleColor = [UIColor colorWithHexValue:0xFFAD2F2F];
        _contentColor = [UIColor colorWithHexValue:kReadContentColor];
        
        _titleFont = [UIFont systemFontOfSize:18.f];
        _contentFont = [UIFont systemFontOfSize:12.f];
        
        _lineColor = [UIColor colorWithHexValue:0xFFe3e2e2];
        _arrowColor = [UIColor colorWithHexValue:0xFFAD2F2F];
        [self viewNightModeChanged:[[ThemeMgr sharedInstance] isNightmode]];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    
    //  icon
    if (_icon) {
        float iconX = 15.f;
        float iconY = (CGRectGetHeight(self.bounds)-_icon.size.height)/2.f;
        [_icon drawAtPoint:CGPointMake(iconX, iconY)];
        
        if (_isFlag) {
            UIImage *flagImg = [SurfFlagsManager flagImage];
            float flagX = iconX + _icon.size.width - flagImg.size.width;
            float flagY = iconY;
            [flagImg drawAtPoint:CGPointMake(flagX, flagY)];
        }
    }
    
    //  title
    if (_title) {
        
        CGRect tR = CGRectMake(80.f, 15.f, 100, _titleFont.lineHeight);
        CGContextSetFillColorWithColor(context, _titleColor.CGColor);
        [_title surfDrawString:tR
                      withFont:_titleFont
                     withColor:_titleColor
                 lineBreakMode:NSLineBreakByWordWrapping
                     alignment:NSTextAlignmentLeft];
    }
    
    
    // content
    float contentWidth = CGRectGetWidth(self.bounds) - 80.f - 50.f;
    float contentHeight = [_contentFont lineHeight];
    CGRect contentR = CGRectMake(80.f, 40.f, contentWidth, contentHeight);
    if (!_content || [_content isEmptyOrBlank]) {
        [_defaultContent surfDrawString:contentR withFont:_contentFont withColor:_contentColor lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    }
    else {
        [_content surfDrawString:contentR withFont:_contentFont withColor:_contentColor lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    }
    
    
    //    arrow
    float arrowW = 10.f;
    float arrowH = 20.f;
    float halfH = arrowH / 2.f;
    float startX = CGRectGetWidth(self.bounds) - 25.f;
    float startY = (CGRectGetHeight(self.bounds) - arrowH ) / 2.f;
    float pX1 = startX + arrowW;
    float pY1 = startY + halfH;
    float pX2 = startX;
    float pY2 = startY + arrowH;
    CGContextSetLineWidth(context, 2.f);
    CGContextSetStrokeColorWithColor(context, _arrowColor.CGColor);
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, pX1, pY1);
    CGContextAddLineToPoint(context, pX2, pY2);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    //    分割线
    float lineBeginX = 70.f;
    float lineBeginY = CGRectGetHeight(self.bounds)-0.5f;
    float lineEndX = CGRectGetWidth(self.bounds);
    float lineEndY = lineBeginY;
    CGContextSetLineWidth(context, 1.f);
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextMoveToPoint(context, lineBeginX, lineBeginY);
    CGContextAddLineToPoint(context, lineEndX, lineEndY);
    CGContextDrawPath(context, kCGPathStroke);
    
    UIGraphicsPopContext();
}



- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setBackgroundColor:_selectBgColor];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setBackgroundColor:_backgroundColorClone];
    [super endTrackingWithTouch:touch withEvent:event];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self setBackgroundColor:_backgroundColorClone];
    [super cancelTrackingWithEvent:event];
}


-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {        
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    }
    else{
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
}

@end

