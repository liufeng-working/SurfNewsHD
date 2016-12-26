//
//  ContextUtil.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-1.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ContextUtil.h"

@implementation ContextUtil

// 绘制图片，在UIView 中绘制图片是到过来的
+ (void)drawImage:(CGContextRef)context imgRef:(CGImageRef)image rect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);//4
    CGContextTranslateCTM(context, 0, rect.size.height);//3
    CGContextScaleCTM(context, 1.0, -1.0);//2
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);//1
    CGContextDrawImage(context, rect, image);
    CGContextRestoreGState(context);
}
@end
