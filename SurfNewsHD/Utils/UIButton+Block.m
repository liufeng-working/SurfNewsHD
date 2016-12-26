//
//  UIButton+Block.m
//  SurfNewsHD
//
//  Created by XuXg on 15/1/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "UIButton+Block.h"
#import <objc/runtime.h>

@implementation UIButton(Block)
static char overviewKey;

//@dynamic event;

- (void)handleControlEvent:(UIControlEvents)event
                 withBlock:(ActionBlock)block
{
    objc_setAssociatedObject(self, &overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}


- (void)callActionBlock:(id)sender
{
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {
        block();
    }
}
@end


/**
 *  UIButton 扩大点击区域
 */
@implementation UIButton(EnlargeTouchArea)

static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;

- (void) setEnlargeEdgeWithTop:(CGFloat)top
                         right:(CGFloat)right
                        bottom:(CGFloat)bottom
                          left:(CGFloat)left
{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// 获取按钮点击扩大的区域
-(CGRect)enlargeFrame
{
    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge)
    {
        return CGRectMake(self.frame.origin.x - leftEdge.floatValue,
                          self.frame.origin.y - topEdge.floatValue,
                          self.frame.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.frame.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }
    else
    {
        return self.frame;
    }
}

- (CGRect) enlargedRect
{
    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge)
    {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }
    else
    {
        return self.bounds;
    }
}

- (UIView*) hitTest:(CGPoint) point withEvent:(UIEvent*) event
{
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? self : nil;
}

@end
