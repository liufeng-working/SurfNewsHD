//
//  SurfNotification.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNotification.h"
#import "AppDelegate.h"

#define MARGIN_TOP                 20.0f
#define MARGIN_LEFT                30.0f
#define INDICATORVIEW_WIDTH        40.0f
#define INDICATORVIEW_NOTICE_SPACE 20.0f


static NSString *notice = nil;

@implementation SurfNotification

@synthesize noticeLabel;
@synthesize indicatorView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        noticeLabel = [[UILabel alloc] init];
        noticeLabel.hidden = YES;
        noticeLabel.textColor = [UIColor whiteColor];
        noticeLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        noticeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:noticeLabel];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, INDICATORVIEW_WIDTH, INDICATORVIEW_WIDTH)];
        indicatorView.hidden = YES;
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:indicatorView];
        
        self.alpha = 0.7f;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

//显示在屏幕上方
+ (SurfNotification*)surfNotification:(NSString *)_notice
{
    return [self surfNotification:_notice showIndicator:NO autoHide:YES];
}

//铺满整个屏幕,在屏幕中间显示一个风火轮
+ (SurfNotification*)surfNotificatioIndicatorAutoHide:(BOOL)hide
{
    notice = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = appDelegate.window;
    
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:[SurfNotification class]]) {
            return nil;
        }
    }
    
    SurfNotification *notification = [[SurfNotification alloc] initWithFrame:window.bounds];
    notification.indicatorView.hidden = NO;
    [notification.indicatorView startAnimating];
    notification.indicatorView.center = window.center;
    
    [window addSubview:notification];
    
    if (hide) {
        [notification performSelector:@selector(hideNotificatioIndicator:) withObject:nil afterDelay:2.0f];
    }
    return notification;
}

//显示在屏幕上方
+ (SurfNotification*)surfNotification:(NSString *)_notice showIndicator:(BOOL)show autoHide:(BOOL)hide
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *rootController = appDelegate.window.rootViewController;
    
    for (UIView *view in rootController.view.subviews) {
        if ([view isKindOfClass:[SurfNotification class]]) {
            return nil;
        }
    }
    
    if (_notice == nil || [_notice isEqualToString:@""]) {
        return [SurfNotification surfNotificatioIndicatorAutoHide:hide];
    }
    notice = _notice;
    
    CGSize notificationSize;
    CGSize stringSize = [notice surfSizeWithFont:[UIFont boldSystemFontOfSize:20.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 40.0f) lineBreakMode:NSLineBreakByWordWrapping];
    if (show) {
        notificationSize = CGSizeMake(stringSize.width + 2 * MARGIN_LEFT + INDICATORVIEW_NOTICE_SPACE + INDICATORVIEW_WIDTH,
                                      stringSize.height + 2 * MARGIN_TOP);
    } else {
        notificationSize = CGSizeMake(stringSize.width + 2 * MARGIN_LEFT, stringSize.height + 2 * MARGIN_TOP);
    }
    
    
    
    CGRect frame = {CGPointMake(kSplitPositionMin + kSplitDividerWidth +
                                (859.0f - notificationSize.width) / 2, - (notificationSize.height + 100.0f)),
                                notificationSize};
    SurfNotification *notification = [[SurfNotification alloc] initWithFrame:frame];
    notification.noticeLabel.hidden = NO;
    notification.noticeLabel.text = notice;
    notification.layer.cornerRadius = 4.0f;
    [rootController.view bringSubviewToFront:notification];
    [rootController.view addSubview:notification];
    
    if (show) {
        notification.indicatorView.hidden = NO;
        [notification.indicatorView startAnimating];
        notification.indicatorView.frame = CGRectMake(MARGIN_LEFT, (frame.size.height - INDICATORVIEW_WIDTH ) / 2,
                                                      INDICATORVIEW_WIDTH, INDICATORVIEW_WIDTH);
        notification.noticeLabel.frame = CGRectMake(MARGIN_LEFT + INDICATORVIEW_WIDTH + INDICATORVIEW_NOTICE_SPACE,
                                                    MARGIN_TOP, stringSize.width, stringSize.height);
    } else {
        notification.noticeLabel.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP, stringSize.width, stringSize.height);
    }
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect notificationFrame = notification.frame;
                         notificationFrame.origin.y = 100.0f;
                         notification.frame = notificationFrame;                     
                     }
                     completion:nil
     ];
    
    if (hide) {
        [notification performSelector:@selector(hideNotificatioNotice) withObject:nil afterDelay:2.0f];
    }
    return notification;
}

//用于隐藏全屏的提示
- (void)hideNotificatioIndicator:(void (^)(BOOL finished))handler
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.0f;
                         [self.indicatorView stopAnimating];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (handler) {
                              handler(finished);
                         }                        
                     }
     ];
}

//用于隐藏在屏幕上方的提示
- (void)hideNotificatioNotice
{
    if (notice == nil || [notice isEqualToString:@""]) {
        [self hideNotificatioIndicator:nil];
        return;
    }
    
    [self.indicatorView stopAnimating];
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect notificationFrame = self.frame;
                         notificationFrame.origin.y = - (notificationFrame.size.height + 100.0f);
                         self.frame = notificationFrame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }
     ];
}

@end
