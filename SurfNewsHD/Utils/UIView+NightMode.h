//
//  UIView+Category_nightMode.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NightMode)
// UIView 夜间模式切换
-(void)viewNightModeChanged:(BOOL)isNight;

// 找到使用自己的对象，找不到返回nil;
-(id)findUserObject:(Class)aClass;

// 给View添加阴影，如何使用就是全局的
//（在快讯范围内，里面的值给张雨乐来修改。哈哈，雨乐）
- (void)viewShadow:(BOOL)shadow;

//点赞弹出动画
-(void)commentSupport;

@end
