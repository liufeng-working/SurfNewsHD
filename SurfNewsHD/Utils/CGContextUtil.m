//
//  CGContextUtil.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CGContextUtil.h"

@implementation CGContextUtil



// 获取一个圆角矩形路径，
// 我用analyze检查，外部使用CGPathRelease()就会警告，
+ (CGPathRef)RoundedRectPathRef:(CGRect)drawRect
                         radius:(NSInteger)radius
{
    // 弧度＝(角度/180)*PI  PI = 3.1415
    // 角度 = 弧度/PI * 180
    // 圆角矩形(绘制顺序上右下左)
    CGFloat angle0 = 0.f;
    CGFloat angle90 = M_PI_2;         // 90/180*PI
    CGFloat angle180 = M_PI;          // 180/180*PI
    CGFloat angle270 = M_PI + M_PI_2; // 270/180*PI
    
    NSInteger x = drawRect.origin.x;
    NSInteger y = drawRect.origin.y;
    NSInteger w = drawRect.size.width;
    NSInteger h = drawRect.size.height;
    
    CGFloat ax = x + radius + 0.5f;
    CGFloat ay = y + 0.5f;
    CGFloat bx = x + w - radius + 0.5f;
    CGFloat by = ay;
    CGFloat cx = x + w + 0.5f;
    CGFloat cy = y + radius + 0.5f;
    CGFloat dx = cx;
    CGFloat dy = y + h - radius + 0.5f;
    CGFloat ex = bx;
    CGFloat ey = y + h + 0.5f;
    CGFloat fx = ax;
    CGFloat fy = ey;
    CGFloat gx = x + 0.5f;
    CGFloat gy = dy;
    CGFloat hx = gx;
    CGFloat hy = cy;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, ax, ay);
    CGPathAddLineToPoint(pathRef, NULL, bx, by);
    CGPathAddArc(pathRef, NULL, bx, cy, radius, angle270, angle0, 0);
    CGPathAddLineToPoint(pathRef, NULL, cx, cy);
    CGPathAddLineToPoint(pathRef, NULL, dx, dy);
    CGPathAddArc(pathRef, NULL, bx, dy, radius, angle0, angle90, 0);
    CGPathAddLineToPoint(pathRef, NULL, ex, ey);
    CGPathAddLineToPoint(pathRef, NULL, fx, fy);
    CGPathAddArc(pathRef, NULL, fx, dy, radius, angle90, angle180, 0);
    CGPathAddLineToPoint(pathRef, NULL, gx, gy);
    CGPathAddLineToPoint(pathRef, NULL, hx, hy);
    CGPathAddArc(pathRef, NULL, ax, cy, radius, angle180, angle270, 0);
    CGPathCloseSubpath(pathRef);
    return pathRef;
}
@end
