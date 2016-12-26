//
//  SNVoteButton.h
//  SurfNewsHD
//
//  Created by duanmu on 15/10/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNVoteButton : UIButton
-(id)initWithFrame:(CGRect)frame;
@property(nonatomic,retain)UIImageView* mySelectImage;
@property(nonatomic,retain)UILabel* myTitileLabel;
@end
