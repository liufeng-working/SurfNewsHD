//
//  PopDialog.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PopDialog.h"

@implementation PopDialog

+ (PopDialog *)sharedInstance{
    
    static PopDialog *sharedInstance = nil;
    static dispatch_once_t onceToken;    
    dispatch_once(&onceToken, ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        sharedInstance = [PopDialog new];
        sharedInstance.backgroundColor = [UIColor clearColor];
        [window.rootViewController.view addSubview:sharedInstance];
    });    
    return sharedInstance;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)show:(NSString *)message fontSize:(CGFloat)fsize drawPoint:(CGPoint)p{
    msg = [message copy];
    msgFont = [UIFont systemFontOfSize:fsize];   
    CGSize msgSize = [msg sizeWithFont:msgFont];
    self.frame = CGRectMake(p.x, p.y, msgSize.width, msgSize.height);

    
    [self setHidden:NO];
    [self setNeedsDisplay];
    [self performSelector:@selector(showComplate) withObject:nil afterDelay:5.2];
}

- (void)showComplate{    
    CGRect rect = [self frame];
    rect.size.height = 0;
    [UIView animateWithDuration:.3f animations:^{
        self.frame = rect; //高度收缩的过程
    } completion:^(BOOL finished){
        [self setHidden:YES];
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{   
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 背景
    float r,g,b,a;
    [self getUIColorGRB:[UIColor orangeColor] red:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBFillColor(context, r, g, b, a);
    CGContextFillRect(context, rect);
    
    // 绘制文字
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    [msg drawInRect:rect withFont:msgFont];
}

// 得到UIColor 的RGB值
-(void)getUIColorGRB:(UIColor *)color red:(float*)r green:(float *)g blue:(float*)b alpha:(float*)a{
    if (color != nil) {
        CGColorRef colorRef = [color CGColor];
        int numComponents = CGColorGetNumberOfComponents(colorRef);
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(colorRef);
            *r = components[0];
            *g = components[1];
            *b = components[2];
            *a = components[3];
        }
    }    
}

@end
