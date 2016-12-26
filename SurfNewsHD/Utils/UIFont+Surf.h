//
//  UIFont+Surf.h
//  SurfNewsHD
//
//  Created by XuXg on 15/4/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Surf)

// 自定义应用字体

+(void)loadCustomFont:(NSMutableArray *)customFontFilePaths;


+(UIFont*)surfFont:(CGFloat)size;
@end
