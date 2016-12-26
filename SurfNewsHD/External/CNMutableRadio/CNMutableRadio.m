//
//  CNMutableRadio.m
//  CNMutableRadioExample
//
//  Created by shscce on 15/5/12.
//  Copyright (c) 2015年 shscce. All rights reserved.
//


#import "CNMutableRadio.h"

#define kOffWH 16  // 宽高

@implementation CNMutableRadio
{
    NSArray *_choices;
    __weak UILabel *_titleLabel;        //显示状态文字
    __weak UIView *_onView;             //显示选中背景
    __weak UIView *_offView;            //显示未选中的背景
    __weak UIView *_onInnerView;        //显示选中状态内部view
    __weak UIView *_offInnerView;       //显示未选中状态内部view
    __weak UIView *_containerView;
}

- (instancetype)init{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit{
        
    //配置状态背景颜色
    self.onTintColor = [UIColor orangeColor];
    self.offTintColor = [UIColor lightGrayColor];
    
    //配置状态文字颜色
    self.onTextColor = [UIColor orangeColor];
    self.offTextColor = [UIColor darkTextColor];
    
    self.backgroundColor = [UIColor clearColor];
    
    //初始化文字显示
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:15.0f];
    titleLabel.textColor = self.offTextColor;
    titleLabel.highlightedTextColor = self.onTextColor;
    [self addSubview:_titleLabel = titleLabel];
    
    // 容器控件
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(5, (CGRectGetHeight(self.bounds) - kOffWH)/2, kOffWH, kOffWH)];
    [containerView setUserInteractionEnabled:NO];
    
    //初始化关闭背景
    UIView *offView = [[UIView alloc] initWithFrame:containerView.bounds];
    offView.layer.cornerRadius = kOffWH/2;
    offView.backgroundColor = self.offTintColor;
    [containerView addSubview:_offView = offView];
    
    UIView *onView = [[UIView alloc] initWithFrame:containerView.bounds];
    onView.backgroundColor = self.onTintColor;
    onView.hidden = YES;
    onView.layer.cornerRadius = kOffWH/2;
    [containerView addSubview:_onView = onView];
    
    
    CGFloat innerWH = kOffWH-5;
    UIView *offInnerView = [[UIView alloc] initWithFrame:CGRectMake(2.5, 2.5, innerWH, innerWH)];
    offInnerView.backgroundColor = [UIColor whiteColor];
    offInnerView.layer.cornerRadius = innerWH/2;
    [containerView addSubview:_offInnerView = offInnerView];
    
    UIView *onInnerView = [[UIView alloc] initWithFrame:CGRectMake(2.5, 2.5, innerWH, innerWH)];
    onInnerView.hidden = YES;
    onInnerView.backgroundColor = [UIColor darkGrayColor];
    onInnerView.layer.cornerRadius = innerWH/2;
    [containerView addSubview:_onInnerView = onInnerView];
    
    [self addSubview:_containerView = containerView];
}


- (void)layoutSubviews{
    
    CGFloat height = self.height;
    [_titleLabel setFrame:CGRectMake(30, 0, _titleLabel.frame.size.width, height)];
    [_containerView setFrame:CGRectMake(5, (height-kOffWH)/2, kOffWH, kOffWH)];

    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 35 + _titleLabel.frame.size.width, height)];
    
}


#pragma mark - setters & getters
- (void)setTitle:(NSString *)title{
    
    _title = title;
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    [self layoutIfNeeded];
    
}
-(void)setOnTextColor:(UIColor *)onTextColor{
    _onTextColor = onTextColor;
    _titleLabel.highlightedTextColor = onTextColor;
}

- (void)setOn:(BOOL)on{
    if (_on == on) {
        return;
    }
    _on = on;
    [_titleLabel setHighlighted:_on];
    if (_on) {
        _onView.bounds = _onInnerView.bounds = CGRectZero;
        _onView.hidden = _onInnerView.hidden = NO;
        
        [UIView animateWithDuration:.3 animations:^{
            _onInnerView.bounds = CGRectMake(0, 0, kOffWH-5, kOffWH-5);
            _onView.bounds = CGRectMake(0, 0, kOffWH, kOffWH);
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            _onInnerView.bounds = _onView.bounds = CGRectZero;
        } completion:^(BOOL finished) {
            _onView.hidden = _onInnerView.hidden = YES;
        }];
    }
}

- (void)setY:(CGFloat)y{
    [self setFrame:CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height)];
}

- (CGFloat)height{
    return 30;
}

- (CGFloat)width{
    return self.frame.size.width;
}

@end
