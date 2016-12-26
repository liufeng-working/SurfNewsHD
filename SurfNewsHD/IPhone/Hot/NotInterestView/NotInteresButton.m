//
//  NotInteresButton.m
//  NotInterestNewsView
//
//  Created by NJWC on 16/2/23.
//  Copyright © 2016年 LF. All rights reserved.
//

#import "NotInteresButton.h"

@implementation NotInteresButton

//初始化
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].delegate.window];
    
    if([_delegate respondsToSelector:@selector(notInteresButton:withClickPoint:)]){
        [_delegate notInteresButton:self withClickPoint:point];
    }
}

//去除点击时的高亮状态
-(void)setHighlighted:(BOOL)highlighted
{
    
}

@end
