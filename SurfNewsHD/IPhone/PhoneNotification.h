//
//  PhoneNotification.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface PhoneNotification : NSObject

//自动隐藏
+ (void)autoHideWithIndicator;
+ (void)autoHideWithText:(NSString*)text;
+ (void)autoHideWithText:(NSString*)text indicator:(BOOL)show;
+ (void)autoHideJokeWithText:(NSString *)text;

//手动隐藏
+ (void)manuallyHideWithIndicator;
+ (void)manuallyHideWithText:(NSString*)text;
+ (void)manuallyHideWithText:(NSString*)text indicator:(BOOL)show;

//隐藏
+ (void)hideNotification;

+ (void)setHUDUserInteractionEnabled:(BOOL)enabled;

@end
