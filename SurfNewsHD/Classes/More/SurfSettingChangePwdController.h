//
//  SurfSettingChangePwdController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"

#define Time 60

@protocol ChangePwdViewDelegate <NSObject>

- (void)didGetVerifyCodeWithPhoneNum:(NSString*)number;
- (void)didChangePwdWithPhoneNum:(NSString*)number
                          verify:(NSString*)code
                        password:(NSString*)pwd;

@end

@interface ChangePwdView : UIView <UITextFieldDelegate>
{
    UIButton *verifyButton;
    UIButton *doneButton;
    
    UILabel *accountLabel;
    UITextField *verifyTextFiled;
    UITextField *passwordTextField;
    
    NSTimer *timer;
    int time;
}

@property(nonatomic, unsafe_unretained) __unsafe_unretained id<ChangePwdViewDelegate> delegate;

@end

@interface SurfSettingChangePwdController : SurfNewsViewController <ChangePwdViewDelegate>

@end
