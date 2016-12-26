//
//  PhoneLoginController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <AdSupport/ASIdentifierManager.h>
#import "AppDelegate.h"
#import "OpenUDID.h"
#import <MessageUI/MessageUI.h>
#import "PhoneSetPasswordView.h"
#import "PhoneSurfController.h"
#import "UserManager.h"
#import "PhoneSetPasswordController.h"
#import "GTMHTTPFetcher.h"
#import "LongPullServletResponse.h"
#import "DeviceIdentifier.h"
#import "EzJsonParser.h"

@protocol PhoneLoginViewDelegate <NSObject>

- (void)didLoginAction:(NSString*)phone password:(NSString*)pwd;
- (void)didForgetPasswordAction;

@end

//登录控件
@interface PhoneLoginView : UIView <UITextFieldDelegate>
{
    UIView *phoneBg;
    UITextField *phoneTextField;
    UIView *passwordBg;
    UITextField *passwordTextField;
}

@property(nonatomic, weak) id<PhoneLoginViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)applyTheme:(BOOL)isNight;
- (void)popupKeyboard;
- (void)hideKeyboard;

@end

//******************************************************************************

@interface PhoneLoginController : PhoneSurfController <UIScrollViewDelegate, PhoneLoginViewDelegate, PhoneSetPasswordViewDelegate, PhoneQuickRegisterViewDelegate, MFMessageComposeViewControllerDelegate>
{
    UIButton *loginButton;
    UIButton *registerButton;
    UIButton *quickRegisterButton;
    
    UITableView *loginTableView;
    UITableView *registerTableView;
    PhoneLoginView *loginView;
    PhoneSetPasswordView *registerView;
    
    UIScrollView *scrollView;
    
    BOOL keyboardShowing;
    UIView *bgView;
    
    NSString *identifier;
}

@end
