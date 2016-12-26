//
//  PopMenuView.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-8-2.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PopMenuView.h"
#import "UserManager.h"


@implementation PopMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        ThemeMgr *mgr = [ThemeMgr sharedInstance];
        isNight = [mgr isNightmode];
        
        // 阴影区域
        if (isNight) {
            self.layer.shadowColor = [UIColor colorWithHexString:@"1b1b1c"].CGColor;
        }
        else
        {
            self.layer.shadowColor = [UIColor grayColor].CGColor;
        }
        
        
        self.layer.shadowOpacity = 0.7f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.masksToBounds = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    float arrowHeight = 15.f; // 箭头高度
    float arrowX = 130.f;
    
    UIColor *lineColor;
    
    CGColorRef bgColorRef;
    if (isNight)
    {
        bgColorRef = [UIColor colorWithHexString:@"1b1b1c"].CGColor;
        lineColor = [UIColor colorWithHexString:@"3c3c3e"];
    }
    else
    {
        bgColorRef = [UIColor whiteColor].CGColor;
        lineColor = [UIColor colorWithHexString:@"F1F0F0"];
    }
    
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);
    
    // 背景
    {
        float width = CGRectGetWidth(self.bounds);
        float height = CGRectGetHeight(self.bounds);
        
        float ax = 0.f;
        float ay = arrowHeight;
        float bx = arrowX;
        float by = arrowHeight;
        float cx = arrowX+13.f;
        float cy = 0.f;
        float dx = cx;
        float dy = arrowHeight;
        float ex = width;
        float ey = arrowHeight;
        float fx = width;
        float fy = height;
        float gx = 0.f;
        float gy = height;
        
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, ax, ay);
        CGPathAddLineToPoint(pathRef, NULL, bx, by);
        CGPathAddLineToPoint(pathRef, NULL, cx, cy);
        CGPathAddLineToPoint(pathRef, NULL, dx, dy);
        CGPathAddLineToPoint(pathRef, NULL, ex, ey);
        CGPathAddLineToPoint(pathRef, NULL, fx, fy);
        CGPathAddLineToPoint(pathRef, NULL, gx, gy);
        CGPathCloseSubpath(pathRef);
        CGContextAddPath(context, pathRef);
        CGContextSetFillColorWithColor(context, bgColorRef);
        CGContextFillPath(context);
        CGPathRelease(pathRef);
    }

    UIGraphicsPopContext();
    
    
    float btnHeight = 44.f + 2;
    float btnWidth = 170 + 2;
    UIFont *btnFont = [UIFont systemFontOfSize:15];
    
    nightBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [nightBt setTag:10];
    [nightBt setFrame:CGRectMake(-1, 15 - 1, btnWidth, btnHeight)];
    nightBt.titleLabel.font = btnFont;
//    [nightBt setBackgroundColor:[UIColor redColor]];
    [nightBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [nightBt setBackgroundImage:[UIImage imageNamed:@"navBtnBG"] forState:UIControlStateHighlighted];
    [nightBt.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [nightBt addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nightBt];
    
    UIImageView *nightImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 24, 24)];
    [nightBt addSubview:nightImage];
    
    if ([[ThemeMgr sharedInstance] isNightmode])
    {
        [nightBt setTitle:@"    日间模式" forState:UIControlStateNormal];
        [nightImage setImage:[UIImage imageNamed:@"daytime"]];
    }
    else
    {
        [nightBt setTitle:@"    夜间模式" forState:UIControlStateNormal];
        [nightImage setImage:[UIImage imageNamed:@"nighttime"]];
    }    
    
    // 离线下载
    UIButton *offline = [UIButton buttonWithType:UIButtonTypeCustom];
    [offline setTag:50];
    [offline setTitle:@"    离线下载" forState:UIControlStateNormal];
    [offline.titleLabel setTextAlignment:NSTextAlignmentCenter];
    offline.frame = CGRectMake(-1, 44.f + 15 - 1, btnWidth, btnHeight);
    offline.titleLabel.font = btnFont;
    [offline setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [offline setBackgroundImage:[UIImage imageNamed:@"navBtnBG"] forState:UIControlStateHighlighted];
//    [offline setTitleColor:[UIColor colorWithHexValue:0xFFad2f2f] forState:UIControlStateHighlighted];
    [offline addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:offline];
    
    UIImageView *offlineImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 24, 24)];//btnHeight + 23
    [offlineImage setImage:[UIImage imageNamed:@"downLoadLogo"]];
    [offline addSubview:offlineImage];
    
    if ([UserManager sharedInstance].loginedUser.userID)
    {   
        // 流量
        UIButton *orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [orderButton setTag:100];
        [orderButton setTitle:@"    余额流量" forState:UIControlStateNormal];
        orderButton.titleLabel.font = btnFont;
        [orderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [orderButton setBackgroundImage:[UIImage imageNamed:@"navBtnBG"] forState:UIControlStateHighlighted];
        orderButton.frame =  CGRectMake(-1, 44.f * 2 + 15 - 1, btnWidth, btnHeight);
        [orderButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [orderButton addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:orderButton];
        
        UIImageView *flowIndicatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 24, 24)];//btnHeight * 2 + 20
        [flowIndicatorImage setImage:[UIImage imageNamed:@"flowIndicator"]];
        [orderButton addSubview:flowIndicatorImage];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 44.f * 2 + 15, 170, 1)];
        [line2 setBackgroundColor:lineColor];
        [self addSubview:line2];
    }

    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 44.f + 15, 170, 1)];
    [line1 setBackgroundColor:lineColor];
    [self addSubview:line1];
}

- (void)clickBt:(UIButton *)bt
{
    if ([_popMenuViewDelegate respondsToSelector:@selector(clickMenuBt:)])
    {
        [_popMenuViewDelegate clickMenuBt:bt];
    }
}


@end
