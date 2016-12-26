//
//  SNSubsThreadSummaryViewCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SNSubsThreadSummaryViewCell.h"
#define SummaryCell_Height 45.f



static UIImage *bg = nil;
static UIImage *bg_n = nil;

@implementation SNSubsThreadSummaryViewCell
+ (float)CellHeight{
    return SummaryCell_Height;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code       
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [[self contentView] addSubview:_titleLabel];
        
        _titleAlignment = NSTextAlignmentLeft;
        self.backgroundView = [UIImageView new];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if (bg == nil) {
            bg = [UIImage imageNamed:@"channel_magazine_bg"];
            bg_n = [UIImage imageNamed:@"channel_magazine_bg_night"];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, _titleEdgeInsets);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setTitle:(NSString *)title{
    _titleLabel.text = title;
}


- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets{
    _titleEdgeInsets = titleEdgeInsets;
    [_titleLabel setFrame:UIEdgeInsetsInsetRect(self.bounds, _titleEdgeInsets)];
}

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment{
    _titleAlignment = titleAlignment;
    _titleLabel.textAlignment = titleAlignment;
}


- (void)viewNightModeChanged:(BOOL)isNight{
    if (isNight) {        
        ((UIImageView*)self.backgroundView).image = bg_n;        
        _titleLabel.textColor = [UIColor whiteColor];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    }
    else{
        ((UIImageView*)self.backgroundView).image = bg;
        _titleLabel.textColor = [UIColor colorWithHexValue:0xFF999292];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
}


@end
