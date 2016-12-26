//
//  RankingListCell.m
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RankingListCell.h"

@implementation RankingListCell
@synthesize indexLabel;
@synthesize titleLabel;
@synthesize soureLabel;
@synthesize typeImgView;;
@synthesize statusImgView;
@synthesize countLabel;
@synthesize energyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
        indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 12.0f, 50.0f, 50.0f)];
        indexLabel.font = [UIFont systemFontOfSize:12.0f];
        indexLabel.backgroundColor = [UIColor clearColor];
        indexLabel.numberOfLines = 1;
        indexLabel.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kUnreadTitleColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0f, 10.0f, 240.0f, 28.0f)];
        titleLabel.font = [UIFont systemFontOfSize:12.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 1;
        titleLabel.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kUnreadTitleColor];

        soureLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0f, 45.0f, 60.0f, 10.0f)];
        soureLabel.font = [UIFont systemFontOfSize:12.0f];
        soureLabel.backgroundColor = [UIColor clearColor];
        soureLabel.numberOfLines = 1;
        soureLabel.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kReadTitleColor];;
        
        typeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0f, 42.0f, 25.0f, 18.0f)];

        statusImgView = [[UIImageView alloc] initWithFrame:CGRectMake(275.0f, 22.0f, 15.0f, 15.0f)];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(291.0f, 13.0f, 35.0f, 35.0f)];
        countLabel.font = [UIFont systemFontOfSize:12.0f];
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.textColor = [UIColor redColor];
        
        energyLabel = [[UILabel alloc] initWithFrame:CGRectMake(275.0f, 45.0f, 45.0f, 10.0f)];
        energyLabel.font = [UIFont systemFontOfSize:12.0f];
        energyLabel.backgroundColor = [UIColor clearColor];
        energyLabel.numberOfLines = 1;
        energyLabel.textColor = [UIColor hexChangeFloat:@"ad2f2f"];
        
        [self addSubview:indexLabel];
        [self addSubview:titleLabel];
        [self addSubview:soureLabel];
        [self addSubview:typeImgView];
        [self addSubview:statusImgView];
        [self addSubview:countLabel];
        [self addSubview:energyLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
