//
//  UIView+Category_nightMode.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UIView+NightMode.h"
#import "UIImage+animatedGIF.h"

@implementation UIView (NightMode)
-(void)viewNightModeChanged:(BOOL)isNight{}

// 找到UIView层次结构中的对象
-(id)findUserObject:(Class)aClass{
    id object = [self nextResponder];
    while (![object isKindOfClass:aClass] && object != nil) {
        object = [object nextResponder];
    }
    return object;
}

- (void)viewShadow:(BOOL)shadow{
    if (shadow) {
        // 雨乐请在这个修改。
//        self.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色值
        self.layer.shadowOpacity = 0.2f;                // 阴影的不透明值（0，1之间）
        self.layer.shadowOffset = CGSizeZero;           // 阴影的偏移量
        self.layer.masksToBounds = NO;
    }
    else{
        self.layer.shadowColor = [UIColor blackColor].CGColor;// 默认值是黑色
        self.layer.shadowOpacity = 0.f;                 // 默认值是0
        self.layer.shadowOffset = CGSizeMake(0, -3);    // 默认值是(0, -3)
        self.layer.masksToBounds = NO;                  // 默认值是NO
    }
}

//点赞弹出动画
-(void)commentSupport
{
    CGFloat W=20.f;
    CGFloat H=20.f;
    CGFloat X=(self.bounds.size.width-W)/2.0;
    CGFloat Y=(self.bounds.size.height-H)/2.0;
    CGRect rect=CGRectMake(X, Y, W, H);
    UIImageView * supportView=[[UIImageView alloc]initWithFrame:rect];
    
    NSMutableArray * supportArray=[NSMutableArray arrayWithCapacity:0];
    for (NSInteger i=0; i<6; i++)
    {
        NSString * nameStr=[NSString stringWithFormat:@"support_%@",@(i)];
        UIImage * supportImage=[UIImage imageNamed:nameStr];
        [supportArray addObject:supportImage];
    }
    supportView.animationImages=supportArray;
    supportView.animationDuration=1;
    supportView.animationRepeatCount=1;
    [supportView startAnimating];
    [self addSubview:supportView];
    
    [supportView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.f];
}
@end
