//
//  SurfAccountRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfAccountRequest.h"
#import "UserManager.h"


@implementation SurfPostUserScoreRequest

- (id)init{
    if (self = [super init]) {
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        SurfJsonRequestBase *surfJsonRequestBase=[[SurfJsonRequestBase alloc] init];
        
        
        self.uid = userInfo.userID;
        self.os = surfJsonRequestBase.os;
        self.taskId = userInfo.userGold.id_id;
        self.type = userInfo.userGold.type;
    }
    return self;
}

@end

@implementation SurfFindTasksRequest

- (id)init{
    if (self = [super init]) {
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        SurfJsonRequestBase *surfJsonRequestBase=[[SurfJsonRequestBase alloc] init];

        
        self.uid = userInfo.userID;
        self.os = surfJsonRequestBase.os;
    }
    return self;
}

@end

@implementation SurfGetUserInfoRequest

- (id)initWithUserId:(NSString *)userId{
    if (self = [super init]) {
        self.uid = userId;
    }
    return self;
}

@end

@implementation SurfModifyUserInfoRequest

- (id)initWithNickName:(NSString *)nickName andSex:(NSString *)sex{
    if (self = [super init]) {
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        self.uid = userInfo.userID;
        self.nickName = nickName;
        self.sex = sex;
    }
    return self;
}

@end

@implementation SurfLoginRequest

- (id)initWithPhoneNum:(NSString *)number password:(NSString *)pwd
{
    if (self = [super init]) {
        self.phoneNum = number;
        self.userPwd = pwd;
    }
    return self;
}

@end

@implementation SurfGetVerifyCodeRequest

- (id)initWithPhoneNum:(NSString *)number capType:(NSString *)type
{
    if (self = [super init]) {
        self.phoneNum = number;
        self.capType = type;
    }
    return self;
}

@end

@implementation SurfRegisterUserRequest

- (id)initWithPhoneNum:(NSString *)number password:(NSString *)pwd verify:(NSString *)code
{
    if (self = [super init]) {
        self.phoneNum = number;
        self.userPwd = pwd;
        self.verifyCode = code;
    }
    return self;
}

@end

@implementation SurfResetPwdRequest

@synthesize pwd = __KEY_NAME_newPwd;

- (id)initWithPhoneNum:(NSString *)number password:(NSString *)pwd verify:(NSString *)code
{
    if (self = [super init]) {
        self.phoneNum = number;
        self.pwd = pwd;
        self.verifyCode = code;
    }
    return self;
}

@end
