//
//  PastPeriodicalCell.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PastPeriodicalCell.h"

@implementation PastPeriodicalTitle

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, 4.0f, 200.0f, 20.0f)];
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"往期期刊";
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        self.backgroundColor = [UIColor colorWithHexString:@"222223"];
        titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
        titleLabel.textColor = [UIColor colorWithHexString:@"34393D"];
    }
}

@end

@implementation PastPeriodicalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        triplePeriodicalView = [[TriplePeriodicalView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 190.0f)];
        triplePeriodicalView.delegate = self;
        [self.contentView addSubview:triplePeriodicalView];
    }
    return self;
}

- (void)loadPastPeriodical:(NSArray *)array
{
    [triplePeriodicalView loadData:array];
}

#pragma mark TriplePeriodicalViewDelegate methods
- (void)periodicalClicled:(PeriodicalInfo *)periodical
{
    [_delegate readPeriodicalContent:periodical];
}

@end
