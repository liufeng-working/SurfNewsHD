//
//  PhoneSetPasswordController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PhoneSetPasswordView.h"
#import "UserManager.h"
#import "PhoneWeiboPolicyController.h"

@interface PhoneSetPasswordController : PhoneSurfController <PhoneSetPasswordViewDelegate>
{
    UITableView *setPasswordTableView;
    PhoneSetPasswordView *setPasswordView;
    
    BOOL keyboardShowing;
}

@property(nonatomic) SetPasswordType setPasswordType;
@property(nonatomic, strong) NSString *phoneNumber;

@end
