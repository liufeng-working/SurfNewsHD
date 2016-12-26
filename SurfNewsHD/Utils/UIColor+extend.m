//
//  UIColor+extend.m
//  SurfBrowser
//
//  Created by SYZ on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIColor+extend.h"

@implementation UIColor(extend)

//+ (UIColor *)hexChangeFloat:(NSString *) hexColor {
//    return [self colorWithHexString:hexColor];
//}

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    if (hex.length <6) {
        return [UIColor clearColor];
    }
    
    
//    unsigned result = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:hex];
//    
//    [scanner setScanLocation:[hex hasPrefix:@"#"] ? 1 : 0]; // bypass '#' character
//    if([scanner scanHexInt:&result])
//    {
//        return [self colorWithHexValue:result];
//    }
//    else
//    {
//        return [UIColor clearColor];
//    }
    
    
	unsigned int redInt_, greenInt_, blueInt_;
	NSRange rangeNSRange_;
	rangeNSRange_.length = 2;  // 范围长度为2
	
	// 取红色的值
	rangeNSRange_.location = hex.length -6;
	[[NSScanner scannerWithString:[hex substringWithRange:rangeNSRange_]]
	 scanHexInt:&redInt_];
	
	// 取绿色的值
	rangeNSRange_.location = hex.length -4;
	[[NSScanner scannerWithString:[hex substringWithRange:rangeNSRange_]]
	 scanHexInt:&greenInt_];
	
	// 取蓝色的值
	rangeNSRange_.location = hex.length -2;
	[[NSScanner scannerWithString:[hex substringWithRange:rangeNSRange_]]
	 scanHexInt:&blueInt_];
	
	return [UIColor colorWithRed:(float)(redInt_/255.0f)
						   green:(float)(greenInt_/255.0f)
							blue:(float)(blueInt_/255.0f)
						   alpha:1.0f];
}

+ (UIColor*)colorWithHexValue:(NSInteger)hex
{
    float a = (float)(((hex&0xFF000000)>>24)/255.f);
    float r = (float)(((hex&0xFF0000)>>16)/255.f);
    float g = (float)(((hex&0xFF00)>>8)/255.f);
    float b = (float)((hex&0xFF)/255.f);
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
@end