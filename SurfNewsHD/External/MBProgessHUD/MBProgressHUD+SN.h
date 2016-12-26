//
//  MBProgessHUD+SN.h
//  SurfNewsHD
//
//  Created by Tianyao on 16/1/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (SN)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view afterDelay:(NSTimeInterval)delay;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
