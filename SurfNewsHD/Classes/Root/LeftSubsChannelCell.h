//
//  LeftSubsChannelCell.h
//  SurfNewsHD
//
//  Created by apple on 13-2-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LeftSubsChannelCellDelegate <NSObject>
-(void)singleTapDetected:(SubsChannel *)channel;
@end
@interface LeftSubsChannelCell : UITableViewCell<UIAlertViewDelegate>
{

    UIImageView *logoImage;
    UIImageView *bgImage;
    UILabel *desLabel;
    UIButton *deleteBtn;
    UIImageView *selectBg;
}
@property(nonatomic,strong) SubsChannel *channel;
@property(nonatomic,strong) UIImageView *logoImage;
@property(nonatomic,strong) UILabel *desLabel;
@property BOOL bgImageHidden;
@property(nonatomic,strong) UIButton *deleteBtn;

@property(nonatomic,assign) id <LeftSubsChannelCellDelegate>observer;
-(void)isCurrent:(BOOL)_isCurrent;
@end
