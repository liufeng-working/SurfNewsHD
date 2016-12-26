//
//  ActivityTableViewCell.h
//  SurfNewsHD
//
//  Created by 潘俊申 on 15/7/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityModel.h"
@interface ActivityTableViewCell : UITableViewCell
{
    UIImageView *bigImageView;
    UILabel *newsLabel;
    UILabel *numberLabel;
    UIButton *joinButton;
    

}
- (void)configUI:(ActivityModel *)model;
@end
