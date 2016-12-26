//
//  PopupLoginController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "LoginView.h"
#import "SetPasswordView.h"

@interface PopupLoginController : SurfNewsViewController <LoginViewDelegate, SetPasswordViewDelegate>
{
    LoginView *loginView;
    SetPasswordView *setPasswordView;
    
    BOOL keyboardShowing;
    BOOL animating;
    
    CGPoint centerPoint;
    CGPoint leftCenterPoint;
    CGPoint rightCenterPoint;
    
    SetPasswordType passwordType;
}

+ (PopupLoginController*)sharedInstance;
- (void)addLoginViewToSuperView;

@end
