//
//  SetPasswordController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "SetPasswordView.h"
#import "UserManager.h"

@interface SetPasswordController : SurfNewsViewController <SetPasswordViewDelegate>
{
    SetPasswordView *setPasswordView;
    BOOL keyboardShowing;
}

@property(nonatomic) SetPasswordType setPasswordType;

+ (SetPasswordController*)sharedInstance;
- (void)addViewToSuperViewWithType:(SetPasswordType)type phone:(NSString*)number;

@end
