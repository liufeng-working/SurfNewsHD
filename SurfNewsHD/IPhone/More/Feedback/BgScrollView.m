//
//  BgScrollView.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "BgScrollView.h"

@implementation BgScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.bgSvDelegate respondsToSelector:@selector(cilickBgScrollView:)])
    {
        [self.bgSvDelegate cilickBgScrollView:self];
    }
}

@end
