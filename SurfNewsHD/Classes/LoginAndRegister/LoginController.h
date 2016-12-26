//
//  LoginController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "LoginView.h"

@interface LoginController : SurfNewsViewController <LoginViewDelegate>
{
    LoginView *loginView;
}

- (void)didEnter:(UIButton*)button;

@end
