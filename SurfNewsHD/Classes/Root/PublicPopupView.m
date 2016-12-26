//
//  PublicPopupView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PublicPopupView.h"

@implementation PublicPopupView

@synthesize title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView.image = [UIImage imageNamed:@"public_popup"];
        [self addSubview:backgroundView];
        
        titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, frame.size.width - 10.0f, 30.0f)];
        titleLable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [titleLable setTextAlignment:NSTextAlignmentCenter];
        titleLable.backgroundColor = [UIColor clearColor];
        titleLable.textColor = [UIColor blackColor];
        titleLable.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:titleLable];
    }
    return self;
}

- (void)setTitle:(NSString *)theTitle
{
    title = theTitle;
    titleLable.text = title;
}

@end
