//
//  SNTableViewCell.m
//  SurfNewsHD
//
//  Created by Tianyao on 16/2/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "SNTableViewCell.h"

@implementation SNTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)view).delaysContentTouches = NO;
            break;
        }
    }
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    return self;
}

@end
