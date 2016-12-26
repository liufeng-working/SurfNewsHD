//
//  SNPictureSummary.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SNPictureSummaryView.h"

//#define NormalHeight 40.f   // 正常高度
#define FoldHeight 50.f       // 正常高度
#define UnfoldHeight 150.f      // 展开的高度
#define TitleFontSize 16.f      // 字体大小
#define DescFontSize 12.f

#define ButtonWidth 30.f        // Button 宽度
#define ButtonHeight 30.f
#define BtnRightMargin 10.f     // Button 右边距

@implementation SNPictureSummaryView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithBottomY:(float)btmY{
    _foldY = btmY - FoldHeight;
    _unfoldY = btmY - UnfoldHeight;
    CGRect rect = CGRectMake(0, _foldY, kContentWidth, FoldHeight);
    if (self = [super initWithFrame:rect]) {        
        
        _upArrow = [UIImage imageNamed:@"upArrow"];
        _downArrow = [UIImage imageNamed:@"downArrow"];
        
        
        
        // 添加一个展开收缩部分的按钮        
        CGRect btnRect = CGRectMake(CGRectGetWidth(self.bounds)-ButtonWidth - BtnRightMargin,
                                    0.f, ButtonWidth, ButtonHeight);
        _unfoldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _unfoldBtn.frame = btnRect;
        _unfoldBtn.backgroundColor = [UIColor clearColor];
        [_unfoldBtn setBackgroundImage:_upArrow forState:UIControlStateNormal];
        [_unfoldBtn addTarget:self action:@selector(unfoldClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_unfoldBtn];
        
        
        // 显示标题
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:TitleFontSize];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel setText:NSTextAlignmentLeft];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        
        // 显示内容
        // 现在给的区域是随便给，目的是不要覆盖_titleLabel 控件就行了。后面会更情况修改。
        CGRect scrollRect = CGRectMake(0.f, FoldHeight, kContentWidth, 20.f);
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
        [self addSubview:_scrollView];
        _descLabel = [UILabel new];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textColor = [UIColor whiteColor];
        [_descLabel setTextAlignment:NSTextAlignmentLeft];
        _descLabel.font = [UIFont systemFontOfSize:DescFontSize];
        _descLabel.numberOfLines = 0;
        [_scrollView addSubview:_descLabel];
        
        self.clipsToBounds = YES;   
    }
    return self;
}


- (void)setBottomY:(float)btmY
{
    _foldY = btmY - FoldHeight;
    _unfoldY = btmY - UnfoldHeight;
    
    
    CGRect rect = self.frame;
    rect.origin.y = _foldY;
    self.frame = rect;
}


-(void)setTitle:(NSString *)title{
    _titleLabel.text = title;
    _title = title;

    float marge_L = 10.f;
    float marge_R = 10.f;
    float marge_T = 5.f;
    UIFont *font = _titleLabel.font;
    float width = CGRectGetWidth(self.bounds);
    float displayerWidth = width - marge_L - marge_R;
    float titleWidth = displayerWidth - ButtonWidth - BtnRightMargin;
    CGSize titleSize = [title surfSizeWithFont:font
                             constrainedToSize:CGSizeMake(titleWidth, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
    
    if (titleSize.height >= font.lineHeight + font.lineHeight) {
        _titleLabel.frame = CGRectMake(marge_L, marge_T, titleWidth,  font.lineHeight + font.lineHeight);
    }
    else{
        _titleLabel.frame = CGRectMake(marge_L, marge_T, titleWidth,  font.lineHeight);
    }
}

- (void)setDesc:(NSString *)desc
{
    _describe = desc;
    _descLabel.text = desc;
    
    CGFloat marge_L = 10.f;
    CGFloat marge_R = 10.f;
    CGFloat marge_B = 5.f;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat scrollWidth =  width - marge_L - marge_R;
    CGFloat scrollHeight = UnfoldHeight - FoldHeight - marge_B;
    // 设置SCroll的Frame
    _scrollView.frame = CGRectMake(marge_L, FoldHeight, scrollWidth, scrollHeight);
    CGSize descSize = [_descLabel sizeThatFits:CGSizeMake(scrollWidth, MAXFLOAT)];
    _descLabel.frame = CGRectMake(0.f, 0.f, descSize.width, descSize.height);
    _scrollView.contentSize = descSize;
    _scrollView.contentOffset = CGPointZero;
}

-(void)unfoldClick:(id)sender{
    UIButton *btn = sender;
    
    float height = CGRectGetHeight(self.bounds);
    if (height == FoldHeight) {// 需要展开
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect tempRect = self.frame;
            tempRect.origin.y = _unfoldY;
            tempRect.size.height = UnfoldHeight;
            self.frame = tempRect;
            [btn setBackgroundImage:_downArrow forState:UIControlStateNormal];
        }];
    }
    else{// 收缩
        [self setNormalState:YES];// 这个函数会设置Button 的背景图片
//        [btn setBackgroundImage:_upArrow forState:UIControlStateNormal];
    }
}


- (void)setNormalState:(BOOL)isAction{
    float height = CGRectGetHeight(self.bounds);
    if (height == UnfoldHeight) {
        if (isAction) {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect tempRect = self.frame;
                tempRect.origin.y = _foldY;
                tempRect.size.height = FoldHeight;
                self.frame = tempRect;
                [_unfoldBtn setBackgroundImage:_upArrow forState:UIControlStateNormal];
            }];
        }
        else{
            CGRect tempRect = self.frame;
            tempRect.origin.y = _foldY;
            tempRect.size.height = FoldHeight;
            self.frame = tempRect;
            [_unfoldBtn setBackgroundImage:_upArrow forState:UIControlStateNormal];
        }
    }
}
@end
