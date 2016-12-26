//
//  UIColor+extend.h
//  SurfBrowser
//
//  Created by SYZ on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// iphone/ipad不支持十六进制的颜色表示，对UIColor进行扩展
@interface UIColor(extend)

// added by yuleiming
//上面两个函数名太雷了，所以重新包装了一下。
//鉴于目前项目中已经大量使用，修改实在过于麻烦，暂时保留上面两个函数
+ (UIColor*)colorWithHexString:(NSString*)hex;

+ (UIColor*)colorWithHexValue:(NSInteger)hex;
//+ (UIColor *)hexChangeFloat:(NSString *) hexColor;
@end
