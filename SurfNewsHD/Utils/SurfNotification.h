//
//  SurfNotification.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SurfNotification : UIView
{
    UILabel *noticeLabel;
    UIActivityIndicatorView *indicatorView;
}

@property(nonatomic, strong) UILabel *noticeLabel;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;

+ (SurfNotification*)surfNotification:(NSString*)notice;
+ (SurfNotification*)surfNotificatioIndicatorAutoHide:(BOOL)hide;
+ (SurfNotification*)surfNotification:(NSString*)notice showIndicator:(BOOL)show autoHide:(BOOL)hide;

- (void)hideNotificatioIndicator:(void (^)(BOOL finished))handler;
- (void)hideNotificatioNotice;

@end
