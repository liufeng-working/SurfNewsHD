//
//  ShareView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicPopupView.h"

@interface ShareItemView : UIView
{
    UIImageView *itemView;
    UIImageView *selectView;
}

- (void)setItemViewImage:(UIImage*)image select:(BOOL)select;

@end

@interface ShareView : UIView <UITextViewDelegate>
{
    PublicPopupView *backgroundView;
    UIImageView *shareBackgroundView;
    UITextView *shareTextView;
    UIButton *cleanButton;
}

@property(nonatomic, assign) NSInteger leftWordCount;
@property(nonatomic, strong) UITextView *shareTextView;

- (id)initWithFrame:(CGRect)frame controller:(id)controller;
- (void)setItemViewImageWithTag:(int)tag bind:(BOOL)bind share:(BOOL)share;
- (void)calculateTextLength;

@end
