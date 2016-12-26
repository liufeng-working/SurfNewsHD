//
//  UIButton+Block.h
//  SurfNewsHD
//
//  Created by XuXg on 15/1/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^ActionBlock)();

@interface UIButton(block)
//@property (readonly) NSMutableDictionary *event;

- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end

// UIButton 扩大点击区域
@interface UIButton(EnlargeTouchArea)


/**
 *  设置button点击扩大的范围
 *
 *  @param top    上扩大值
 *  @param right  右扩大值
 *  @param bottom 底部扩大值
 *  @param left   左边扩大值
 */
- (void)setEnlargeEdgeWithTop:(CGFloat)top
                        right:(CGFloat)right
                       bottom:(CGFloat)bottom
                         left:(CGFloat)left;


// 获取按钮点击扩大的区域
-(CGRect)enlargeFrame;

@end
