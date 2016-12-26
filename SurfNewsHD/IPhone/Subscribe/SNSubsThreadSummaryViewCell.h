//
//  SNSubsThreadSummaryViewCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSubsThreadSummaryViewCell : UITableViewCell{
    UILabel *_titleLabel;
}
@property(nonatomic,retain) UIFont *titleFont;
@property(nonatomic)        NSTextAlignment titleAlignment;     // default is NSTextAlignmentLeft
@property(nonatomic)        UIEdgeInsets titleEdgeInsets;       // default is UIEdgeZero


+ (float)CellHeight;
//- (void)reloadThreadSummary:(ThreadSummary*)ts;
- (void)setTitle:(NSString *)title;
@end
