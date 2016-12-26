//
//  ActivityTableViewCell.m
//  SurfNewsHD
//
//  Created by 潘俊申 on 15/7/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#import "ActivityTableViewCell.h"

@implementation ActivityTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeUI];
    }
    return self;
}
-(void)configUI:(ActivityModel *)model {


}

- (void)makeUI {
    bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    [self.contentView addSubview:bigImageView];
    newsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, bigImageView.frame.size.height+5, SCREEN_WIDTH*4/5, 15)];
    newsLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.contentView addSubview:newsLabel];
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(newsLabel.frame.origin.x, newsLabel.frame.origin.y+3+newsLabel.frame.size.height, newsLabel.frame.size.width, 8)];
    numberLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.contentView addSubview:numberLabel];
    joinButton = [UIButton buttonWithType:UIButtonTypeSystem];
    joinButton.layer.cornerRadius = 8.0f;
    joinButton.backgroundColor = [UIColor redColor];
    [joinButton setTitle:@"参加" forState:UIControlStateNormal];
    joinButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.contentView addSubview:joinButton];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
