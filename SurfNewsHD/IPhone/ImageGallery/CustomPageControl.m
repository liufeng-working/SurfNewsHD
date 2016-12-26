//
//  CustomPageControl.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CustomPageControl.h"
#import "CGContextUtil.h"
#import "UIColor+extend.h"
#import "NSString+Extensions.h"

#define LineCount 5

@interface CustomPageControl (private)  //声明一个私有方法，该方法不允许对象直接使用
- (void)updateDots;
@end

@implementation CustomPageControl
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _indicatorSpace = 5.f;
        _indicatorSize = CGSizeMake(10, 2);        
        _indicatorNormalColor = [UIColor grayColor];
        _indicatorHighlightedColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setIndicatorSize:(CGSize)indicatorSize{
    _indicatorSize = indicatorSize;
    [self setNeedsDisplay];
}


- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount{    
    return CGSizeMake((_indicatorSize.width + _indicatorSpace)*pageCount + 20, _indicatorSize.height+20);
}


//numberOfPages
// 重载一下
-(void)setNumberOfPages:(NSInteger)numberOfPages{    
    _numberOfPages = numberOfPages;
    [self setNeedsDisplay];
}

-(void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    if (_numberOfPages == 0 || (_hidesForSinglePage && _numberOfPages == 1)) {
        return;
    }


    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (_numberOfPages <= LineCount) {
        float width = CGRectGetWidth(self.bounds);
        float height = CGRectGetHeight(self.bounds);
        float indicatorTotalWidth = _numberOfPages*(_indicatorSize.width+_indicatorSpace)-_indicatorSpace;
        float bX = (width - indicatorTotalWidth) / 2.f;
        float bY = (height - _indicatorSize.height)/2.f;
    
        for (NSInteger i=0; i<_numberOfPages; ++i) {            
            // 开始绘制长方形
            CGRect rect = CGRectMake(bX+ (_indicatorSize.width+_indicatorSpace)*i, bY, _indicatorSize.width, _indicatorSize.height);
            CGPathRef rectPath = [CGContextUtil RoundedRectPathRef:rect radius:0];
            CGContextSetFillColorWithColor(context,i == _currentPage ? _indicatorHighlightedColor.CGColor:_indicatorNormalColor.CGColor);
            CGContextAddPath(context, rectPath);
            CGContextFillPath(context);
            CGPathRelease(rectPath);
        }        
    }
    else{
        // 直接使用文字表述
        UIFont *font = [UIFont systemFontOfSize:15];
        UIColor *textColor = [UIColor colorWithHexValue:0xFF999292];
        NSString *text = [NSString stringWithFormat:@"%@/%@",@(self.currentPage+1), @(_numberOfPages)];
        [text surfDrawString:self.bounds
                    withFont:font
                   withColor:textColor
               lineBreakMode:NSLineBreakByWordWrapping
                   alignment:NSTextAlignmentCenter];
    }
    UIGraphicsPopContext();
}

@end
