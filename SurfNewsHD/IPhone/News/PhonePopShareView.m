//
//  PhonePopShareView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-10-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhonePopShareView.h"
#import "AppDelegate.h"
#import "PhoneReadController.h"

@implementation PhonePopShareView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //zyl在这里调蒙版颜色
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
        
//        float bgViewHeight = 170.0f;
        float bgViewHeight = 90.0f;
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 286.0f, bgViewHeight)];
        bgView.center = CGPointMake(self.center.x, self.center.y - 5.0f);
        [bgView viewShadow:YES];
        bgView.backgroundColor = [UIColor colorWithHexString:[[ThemeMgr sharedInstance] isNightmode]?@"2D2E2F":@"FFFFFF"];
        
        [self addSubview:bgView];
        
        //这里初始化的时候没有设定大小，是因为ShareMenuView自己设定
        ShareMenuView *shareMenu = [[ShareMenuView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 0.0f, 0.0f)];
        shareMenu.center = self.center;
        shareMenu.delegate = self;
        [self addSubview:shareMenu];
    }
    return self;
}

#pragma mark ShareMenuViewDelegate methods
- (void)menuSelected:(ShareWeiboType)tag
{
    if ([_delegate respondsToSelector:@selector(shareWeibo:)]) {
        [_delegate shareWeibo:tag];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(hiddenShareView)]) {
        [_delegate hiddenShareView];
    }
}

@end
