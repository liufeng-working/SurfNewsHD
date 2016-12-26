//
//  CGContextUtil.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGContextUtil : NSObject

// 获取一个圆角矩形路径，
// 我用analyze检查，外部使用CGPathRelease()就会警告
+ (CGPathRef)RoundedRectPathRef:(CGRect)rect
                         radius:(NSInteger)radius;
@end
