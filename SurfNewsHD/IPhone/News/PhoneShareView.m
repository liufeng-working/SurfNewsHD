//
//  PhoneShareView.m
//  SurfNewsHD
//
//  Created by apple on 13-6-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneShareView.h"
#import "ThemeMgr.h"
#import "UIColor+extend.h"

#define BGHeight   155.0f



@implementation PhoneShareView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shadowView = [[UIView alloc] initWithFrame:self.bounds];
        _shadowView.alpha = 0.f;
        _shadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        [self addSubview:_shadowView];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height,
                                                          frame.size.width,  BGHeight)];
        _bgView.backgroundColor = [UIColor colorWithHexString:[[ThemeMgr sharedInstance] isNightmode]?@"2D2E2F":@"FFFFFF"];
        [self addSubview:_bgView];
        
        //这里初始化的时候没有设定大小，是因为ShareMenuView自己设定
        ShareMenuView *shareMenu = [[ShareMenuView alloc] initWithFrame:CGRectMake(27.0f, 15.0f, 0.0f, 0.0f)];
        shareMenu.delegate = self;
        [_bgView addSubview:shareMenu];
    }
    return self;
}

// 显示分享面板
- (void)showShareView:(BOOL)isShow
            isAnimate:(BOOL)animate
           completion:(void (^)(BOOL finished))completion
{
    if (animate) {
        [UIView animateWithDuration:0.3f animations:^{
            if (isShow) {
                _shadowView.alpha = 1.f;
                float dy = -BGHeight - kToolsBarHeight;
                _bgView.frame = CGRectOffset(_bgView.frame, 0, dy);
            }
            else{
                _shadowView.alpha = 0.0f;
                _bgView.frame = CGRectOffset(_bgView.frame, 0, CGRectGetHeight(self.bounds));
            }
        } completion:completion];
    }
    else{
        if (isShow) {
            _shadowView.alpha = 1.f;
            _bgView.frame = CGRectOffset(_bgView.frame, 0, BGHeight);
        }
        else{
            _shadowView.alpha = 0.0f;
            _bgView.frame = CGRectOffset(_bgView.frame, 0, CGRectGetHeight(self.bounds));
        }
    }
}

//- (void)drawRect:(CGRect)rect
//{
//    UIColor *bgColor = [[ThemeMgr sharedInstance] isNightmode] ? [UIColor colorWithHexValue:0xFF1b1b1C] : [UIColor whiteColor];
//
//    float arrowHeight = 15.f; // 箭头高度
//    float arrowX = 195.f;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIGraphicsPushContext(context);
//    CGContextClearRect(context, rect);
//    
//    // 背景
//    float width = 286.0f;
//    float height = 150.0f;
//    
//    float ax = width;
//    float ay = 0.f;
//    float bx = 0.f;
//    float by = 0.f;
//    float cx = 0.f;
//    float cy = height;
//    float dx = arrowX;
//    float dy = height;
//    float ex = arrowX + 13.0f;
//    float ey = height + arrowHeight;
//    float fx = ex;
//    float fy = height;
//    float gx = width;
//    float gy = height;
//    
//    CGMutablePathRef pathRef = CGPathCreateMutable();
//    CGPathMoveToPoint(pathRef, NULL, ax, ay);
//    CGPathAddLineToPoint(pathRef, NULL, bx, by);
//    CGPathAddLineToPoint(pathRef, NULL, cx, cy);
//    CGPathAddLineToPoint(pathRef, NULL, dx, dy);
//    CGPathAddLineToPoint(pathRef, NULL, ex, ey);
//    CGPathAddLineToPoint(pathRef, NULL, fx, fy);
//    CGPathAddLineToPoint(pathRef, NULL, gx, gy);
//    CGPathCloseSubpath(pathRef);
//    CGContextAddPath(context, pathRef);
//    CGContextSetFillColorWithColor(context, bgColor.CGColor);
//    CGContextFillPath(context);
//    CGPathRelease(pathRef);
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenPhoneShare];
}

- (void)hiddenPhoneShare
{
    [self.delegate hiddenShareView];
}

#pragma mark ShareMenuViewDelegate
- (void)menuSelected:(ShareWeiboType)tag
{
    [delegate hiddenShareView];
    if ([self.delegate respondsToSelector:@selector(shareWeibo:)]) {
        [self.delegate shareWeibo:tag];
    }
}

@end
