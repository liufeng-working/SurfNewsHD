//
//  CollectTableViewCell.m
//  SurfNewsHD
//
//  Created by duanmu on 15/10/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "CollectTableViewCell.h"

@implementation CollectTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _myNameLabel = [[UILabel alloc]init];
        self.myNameLabel.frame = CGRectMake(10, 10, 300, 30);
        self.myNameLabel.font = [UIFont systemFontOfSize:15.0f];
        self.myNameLabel.textColor = [UIColor blackColor];
        [self addSubview:self.myNameLabel];
        
        _myTimeLabel = [[UILabel alloc]init];
        self.myTimeLabel.frame = CGRectMake(250, 45, 60, 20);
        self.myTimeLabel.font = [UIFont systemFontOfSize:10.0f];
        self.myTimeLabel.textAlignment = NSTextAlignmentRight;
        
        self.myTimeLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.myTimeLabel];
        
        
        _myTitleLabel = [[UILabel alloc]init];
        self.myTitleLabel.frame = CGRectMake(10, 45, 60, 20);
        self.myTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.myTitleLabel.font = [UIFont systemFontOfSize:10.0f];
        self.myTitleLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.myTitleLabel];
        
        UIView* lineView = [[UIView alloc]init];
        lineView.frame = CGRectMake(10, 69, 300, 1);
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
