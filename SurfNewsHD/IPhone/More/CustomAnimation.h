//
//  CustomAnimation.h
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "IndicatorView.h"

#define kWaitingViewTag 98647

@interface CustomAnimation : NSObject {
    UILabel         *bubbleMsgLabel_;
}

+ (void)showFromTop:(UIView*)aView bounce:(BOOL)bounce;//可以选择是否有反弹效果
+ (void)showFromTop:(UIView*)aView;//有反弹效果
+ (void)showFromTop:(UIView*)aView backgroundFadein:(UIView*)backView;
+ (void)showFromButtom:(UIView*)aView;
+ (void)hideToTopAndRemove:(UIView*)aView;
+ (void)hideToButtomAndRemove:(UIView*)aView;
+ (void)showWaitingView;
+ (void)hideWaitingView;
+ (void)showWaitingViewInView:(UIView*)view;
+ (void)showWaitingViewInView:(UIView*)view belowSubView:(UIView*)subView;
+ (void)showWaitingViewInView:(UIView*)view waitingViewPosition:(CGPoint)position belowSubView:(UIView*)subView;
+ (void)hideWaitingViewFromView:(UIView*)view;
+ (void)modifyNewsView:(UIView*)aView;
+ (void)showNewsDetail:(UIView*)aView;
+ (void)showShadow:(UIView*)aView;
+ (void)showBubbleMessage:(NSString*)message;

+ (void)showWaitingViewInView:(UIView *)view waitingViewFram:(CGRect)rectFram;
+ (void)showWaitingViewWithoutNavgation;
+ (void)showWaitingViewInViewWithoutNavgation:(UIView *)view;

+ (void)showAlertView:(NSString *)messageStr;

+ (UIImage *)imageRetun:(NSString *)imageName :(CGRect)rect alpha:(float)alpha;

@end
