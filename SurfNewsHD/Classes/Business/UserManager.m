//
//  UserManager.m
//  SurfNewsHD
//
//  Created by apple on 13-3-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UserManager.h"
#import "EzJsonParser.h"
#import "PathUtil.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "Encrypt.h"
#import "FileUtil.h"
#import "SubsChannelsManager.h"
#import "MagazineManager.h"
#import "NotificationManager.h"
#import "LongPullServletResponse.h"
#import "CustomAnimation.h"
#import "DispatchUtil.h"

@implementation UserDes

@end

@implementation UserInfo

- (void)setUserID:(NSString *)userID
{
    _userID = userID;
    _encryptUserID = [Encrypt encryptUseDES:_userID];
}

@end


@implementation UserTaskData
@synthesize id_id = __KEY_NAME_id;

@end

#define kDefaultUserInfo @"DefaultID"

@implementation UserManager

+ (UserManager*)sharedInstance
{
    static UserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        observers_ = [[NSMutableArray alloc] init];
        UserInfo *user = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfUserInfo] encoding:NSUTF8StringEncoding error:nil] AsType:[UserInfo class]];
        if (user && user.isValid != 1) { //表示这个userinfo是无用的要删除
            [FileUtil deleteContentsOfDir:[PathUtil rootPathOfUser]];
        }
    }
    return self;
}

- (UserInfo *)loginedUser
{
    loginedUser = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfUserInfo] encoding:NSUTF8StringEncoding error:nil] AsType:[UserInfo class]];
    if (loginedUser.userID) {
        return loginedUser;
    }
    return nil;
}

-(void)quitLogin
{
    loginedUser = nil;
    _userFlow = nil;
    [self userLoginChanged];
}

-(void)userLogin:(NSString *)phoneNum
        password:(NSString *)password
withCompletionHandler:(void(^)(BOOL succeeded, NSInteger code))handler
{
    id req = [SurfRequestGenerator userLoginRequestWithPhoneNum:[Encrypt encryptUseDES:phoneNum]
                                                       password:[Encrypt encryptUseDES:password]];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        if(!error) {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SurfLoginResponse *resp = [EzJsonParser deserializeFromJson:body AsType:[SurfLoginResponse class]];
            if (resp.code == 200) {
                [self getSubsAfterLogin:resp phone:phoneNum withCompletionHandler:^(BOOL succeeded) {
                    if (succeeded) {
                        handler(YES, resp.code);
                    } else {
                        handler(NO, 0);
                    }
                }];
            } else {
                handler(NO, resp.code);
            }
        } else {
            handler(NO, 0);
        }
    }];
}

-(void)getVerifyCode:(NSString *)phoneNum
             capType:(NSString *)type
withCompletionHandler:(void (^)(BOOL succeeded, NSInteger code))handler
{
    id req = [SurfRequestGenerator getVerifyCodeWithPhoneNum:[Encrypt encryptUseDES:phoneNum]
                                                     capType:type];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        if(!error) {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SurfGetVerifyCodeResponse *resp = [EzJsonParser deserializeFromJson:body AsType:[SurfGetVerifyCodeResponse class]];
            if (resp.code == 200) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kResultGetVerifyCode object:@"SUCCESS"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kResultGetVerifyCode object:@"FAIL"];
            }
            handler(YES, resp.code);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kResultGetVerifyCode object:@"FAIL"];
            handler(NO, 0);
        }
    }];
}

-(void)userRegister:(NSString *)phoneNum
           password:(NSString *)password
             verify:(NSString *)code
withCompletionHandler:(void (^)(BOOL succeeded, NSInteger code))handler
{
    id req = [SurfRequestGenerator userRegisterWithPhoneNum:[Encrypt encryptUseDES:phoneNum]
                                                   password:[Encrypt encryptUseDES:password]
                                                     verify:code];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        if(!error) {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SurfRegisterUserResponse *resp = [EzJsonParser deserializeFromJson:body AsType:[SurfRegisterUserResponse class]];
            if (resp.code == 200) {
                [AppSettings setBool:YES forKey:BoolKeyShowSubsPrompt];
                UserInfo *info = [UserInfo new];
                info.userID = resp.uid;
                info.phoneNum = phoneNum;
                info.cityId = resp.cityId;
//                info.password = [Encrypt encryptUseDES:password];
                loginedUser = info;
                [self savePathOfUserInfo];
                
                //这里也要先取订阅关系
                [[SubsChannelsManager sharedInstance] refreshSubsChannelListWithUser:info handler:^(BOOL succeeded) {
                    loginedUser.isValid = 1; //表示这个保存的文件可用
                    [self savePathOfUserInfo];
                    [AppSettings setString:phoneNum
                                    forKey:StringLoginedUser];
                    handler(YES, resp.code);
                }];
            } else {
                handler(YES, resp.code);
            }
        } else {
            handler(NO, 0);
        }
    }];
}

-(void)findUserInfowithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler{
    id req = [SurfRequestGenerator getFindUserInfoRequest:[[UserManager sharedInstance] loginedUser].userID];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [PhoneNotification manuallyHideWithIndicator];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        BOOL sucess = NO;
        NSDictionary*dic = nil;
        [PhoneNotification hideNotification];

        if(!error) {
            NSString* st = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            
            
            
            if (1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                NSDictionary *userInfoDic = [dic objectForKey:@"userInfo"];
                UserDes *userDes = [UserDes new];
                userDes.nickName = [userInfoDic objectForKey:@"nickName"];
                userDes.credit = [userInfoDic objectForKey:@"credit"];
                userDes.lvl = [userInfoDic objectForKey:@"lvl"];
                userDes.sex = [userInfoDic objectForKey:@"sex"];
                userDes.title = [userInfoDic objectForKey:@"title"];
                userDes.upgradeCredit = [userInfoDic objectForKey:@"upgradeCredit"];
                userDes.headPic = [userInfoDic objectForKey:@"headPic"];

                [self loginedUser].userDes = userDes;
                
                [self savePathOfUserInfo];
                
                //保存头像到本地
                if (userDes.headPic) {
                    // 下载图片
                    ImageDownloadingTask *task = [ImageDownloadingTask new];
                    [task setImageUrl:userDes.headPic];
                    [task setTargetFilePath:[PathUtil pathUserHeadPic]]; // 保存图片
                    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                        if(succeeded && idt != nil){
                            
                        }
                    }];
                    [[ImageDownloader sharedInstance] download:task];
                }
                
                sucess = YES;
            }
        }
        handler(sucess, dic);
    }];
}

- (void)modifyUserInfoNickName:(NSString *)nickName andSex:(NSString *)Sex WithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler{
    id req = [SurfRequestGenerator modifyUserInfoRequestNickName:nickName andSex:Sex];
    [PhoneNotification manuallyHideWithIndicator];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        BOOL sucess = NO;
        NSDictionary*dic = nil;
        [PhoneNotification hideNotification];

        if(!error) {
            NSString* st = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            
            if (1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                
                sucess = YES;
            }
            else{
                UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"操作错误" message:[[dic objectForKey:@"res"] objectForKey:@"resMessage"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alt show];
            }
            
        }
        handler(sucess, dic);
    }];
}

- (void)uploadHeadPic:(UIImage *)imageData_PNG WithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler{
    id req = [SurfRequestGenerator UpdateImageRequest:imageData_PNG];
    [CustomAnimation showWaitingView];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        BOOL sucess = NO;
        NSDictionary*dic = nil;
        [CustomAnimation hideWaitingView];

        if(!error) {
            NSString* st = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            NSLog(@"st: %@", st);
            dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            
            if (1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                
                sucess = YES;
            }
            else{
                UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"操作错误" message:[[dic objectForKey:@"res"] objectForKey:@"resMessage"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alt show];
            }
            
        }
        handler(sucess, dic);
    }];
}

- (void)findTasksWithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler{
    id req = [SurfRequestGenerator findTasksRequest];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [PhoneNotification manuallyHideWithIndicator];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        BOOL sucess = NO;
        NSDictionary*dic = nil;
        [PhoneNotification hideNotification];
        
        if(!error) {
            NSString* st = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            
            if (1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
                
                NSArray *item = [dic objectForKey:@"item"];
                for (NSDictionary *itemDic in item) {
                    if ([[itemDic objectForKey:@"id"] integerValue] == 1) {
                        UserTaskData *userTaskData = [UserTaskData new];
                        userTaskData.desc = [itemDic objectForKey:@"desc"];
                        userTaskData.exp = [itemDic objectForKey:@"exp"];
                        userTaskData.finishNum = [itemDic objectForKey:@"finishNum"];
                        userTaskData.gold = [itemDic objectForKey:@"gold"];
                        userTaskData.id_id = [itemDic objectForKey:@"id"];
                        userTaskData.stateDesc = [itemDic objectForKey:@"stateDesc"];
                        userTaskData.title = [itemDic objectForKey:@"title"];
                        userTaskData.totalNum = [itemDic objectForKey:@"totalNum"];
                        userTaskData.type = [itemDic objectForKey:@"type"];
                        
                        userInfo.userGold = userTaskData;
                        break;
                    }
                   
                }
                
                [self savePathOfUserInfo];
                sucess = YES;
            }
        }
        handler(sucess, dic);
    }];
}

- (void)postUserScoreWithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler{
    id req = [SurfRequestGenerator postUserScoreRequest];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
//    [PhoneNotification manuallyHideWithIndicator];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        BOOL success = NO;
        NSDictionary*dic = nil;
//        [PhoneNotification hideNotification];
        
        if(!error) {
            NSString* st = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            dic = [EzJsonParser deserializeFromJson:st AsType:[NSDictionary class]];
            
            if (1 == [[[dic objectForKey:@"res"] objectForKey:@"reCode"] integerValue]) {
                success = YES;
            }
            //如果领取过了，就提示“今日已领取“（已经关闭了这个功能，如果已经领取了，再点击就会进入设置个人信息页面）
            else{

//                [PhoneNotification autoHideWithText:[[dic objectForKey:@"res"] objectForKey:@"resMessage"]];
            }
        }
        
        handler(success, dic);

    }];
}

// 获取用户流量，必须是登录用户，否则获取不到数据
-(void)userFlowInfo:(void(^)(SNUserFlow *flowInfo))handler
{
    if (![self loginedUser]) {
        [DispatchUtil dispatch:^{
            if (handler) {
                handler(nil);
            };
        } after:0.1f];
        return;
    }
    
    
    // 已经请求过用户流量信息
    if (_userFlow) {
        [DispatchUtil dispatch:^{
            if (handler) {
                handler(_userFlow);
            };
        } after:0.1f];
        return;
    }
    
    
    
    
// TODO:  请求用户流量和套餐信息
    id req = [SurfRequestGenerator checkFindFlowRequestWithUserId:[UserManager sharedInstance].loginedUser.userID andIsAuto:@"0"];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         if(!error) {
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
  
             _userFlow = [SNUserFlow objectWithKeyValues:body];
             if (![_userFlow.res.reCode isEqualToString:@"1"]) {
                 _userFlow = nil;
             }
             
             if (handler) {
                 handler(_userFlow);
             };
         }
     }];
    
}


-(void)resetPassword:(NSString *)phoneNum
            password:(NSString *)password
              verify:(NSString *)code
withCompletionHandler:(void (^)(BOOL succeeded, NSInteger code))handler
{
    id req = [SurfRequestGenerator resetPasswordWithPhoneNum:[Encrypt encryptUseDES:phoneNum]
                                                    password:[Encrypt encryptUseDES:password]
                                                      verify:code];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        if(!error) {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SurfResetPwdResponse *resp = [EzJsonParser deserializeFromJson:body AsType:[SurfResetPwdResponse class]];
            if (resp.code == 200) {
                UserInfo *info = [UserInfo new];
                info.userID = resp.uid;
                info.phoneNum = phoneNum;
//                info.password = [Encrypt encryptUseDES:password];
                loginedUser = info;
                [self savePathOfUserInfo];
                //这里也要先取订阅关系
                [[SubsChannelsManager sharedInstance] refreshSubsChannelListWithUser:info handler:^(BOOL succeeded) {
                    if (succeeded) {
                        [[MagazineManager sharedInstance] refreshMagazineListWithUser:info handler:^(BOOL succeeded) {
                            if (succeeded) {
                                loginedUser.isValid = 1; //表示这个保存的文件可用
                                [self savePathOfUserInfo];
                                [AppSettings setString:phoneNum forKey:StringLoginedUser];
                                handler(YES, resp.code);
                            } else {
                                loginedUser = nil;
                                handler(NO, 0);
                            }
                        }];
                    } else {
                        loginedUser = nil;
                        handler(NO, 0);
                    }
                }];
            } else {
                handler(YES, resp.code);
            }
        } else {
            handler(NO, 0);
        }
    }];
}

//登录后获取订阅关系
- (void)getSubsAfterLogin:(id)resp phone:(NSString *)phoneNum withCompletionHandler:(void (^)(BOOL succeeded))handler
{
    UserInfo *info = [UserInfo new];
    if ([resp isKindOfClass:[SurfLoginResponse class]]) {
        SurfLoginResponse *loginResp = (SurfLoginResponse *)resp;
        if (loginResp.isNew == 1) {
            [AppSettings setBool:YES forKey:BoolKeyShowSubsPrompt];
        } else {
            [AppSettings setBool:NO forKey:BoolKeyShowSubsPrompt];
        }
        info.userID = loginResp.uid;
        info.phoneNum = phoneNum;
        info.cityId = loginResp.cityId;
        //info.password = [Encrypt encryptUseDES:password]
    } else if ([resp isKindOfClass:[LongPullServletResponse class]]) {
        LongPullServletResponse *servletResp = (LongPullServletResponse *)resp;
        info.userID = [Encrypt decryptUseDES:servletResp.suid];
        info.phoneNum = [Encrypt decryptUseDES:servletResp.mob];
        info.cityId = servletResp.cityId;
        [AppSettings setBool:NO forKey:BoolKeyShowSubsPrompt];
    }
    loginedUser = info;
    [self savePathOfUserInfo];
    
    
    //等到栏目和期刊订阅关系都拿到后才算登陆成功
    [[SubsChannelsManager sharedInstance] refreshSubsChannelListWithUser:info handler:^(BOOL succeeded) {
        if (succeeded) {
            [[MagazineManager sharedInstance] refreshMagazineListWithUser:info handler:^(BOOL succeeded) {
                if (succeeded) {
                    loginedUser.isValid = 1; //表示这个保存的文件可用
                    [self savePathOfUserInfo];
                    [AppSettings setString:phoneNum forKey:StringLoginedUser];
                    handler(YES);
                } else {
                    loginedUser = nil;
                    handler(NO);
                }
            }];
        } else {
            loginedUser = nil;
            handler(NO);;
        }
    }];
}

-(void)defaultUserAutomaticLogiCompletionHandler:(void(^)(BOOL succeeded, UserInfo *info))handler
{
    loginedUser = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfUserInfo] encoding:NSUTF8StringEncoding error:nil] AsType:[UserInfo class]];

    if (loginedUser) {
        [self userLoginChanged];
        handler(YES, loginedUser);
    } else {
        handler(NO,nil);
    }
}

-(void)userLoginChanged
{
    for (NSInteger i = [observers_ count] - 1; i >= 0; --i) {
        id<UserManagerObserver> observer = [observers_ objectAtIndex:i];
        [observer currentUserLoginChanged];
    }
}

-(void)savePathOfUserInfo
{
    NSLog(@"[PathUtil pathOfUserInfo]: %@", [PathUtil pathOfUserInfo]);

    [[EzJsonParser serializeObjectWithUtf8Encoding:loginedUser] writeToFile:[PathUtil pathOfUserInfo]
                                                                 atomically:YES encoding:NSUTF8StringEncoding
                                                                      error:nil];
}

-(void)addUserLoginObserver:(id<UserManagerObserver>)observer
{
    if(![observers_ containsObject:observer])
        [observers_ addObject:observer];
}

-(void)removeUserLoginObserver:(id<UserManagerObserver>)observer
{
    [observers_ removeObject:observer];
}


- (void)removeUserInfo:(void(^)(BOOL))result
{
    [FileUtil deleteContentsOfDir:[PathUtil rootPathOfUser] withCompletionHandler:^(BOOL succeeded) {
        if (succeeded) {
            [self quitLogin];
        }
        if (result != nil) {
            result(succeeded);
        }
    }];
}

- (void)writeToSelectedMoreVC:(NSString* )writeStr{
    
    NSLog(@"writeFile");
    
    NSString *path = [PathUtil pathOfHotChannelSelectedMoreVC];
    
    NSError* error;
    
    [writeStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"写入失败:%@",error);
    }else{
        NSLog(@"写入成功");
    }
}

- (BOOL)readFileArraySelectedMoreVC
{
    BOOL req = NO;
    
    NSLog(@"readFile");
    NSString *filePath = [PathUtil pathOfHotChannelSelectedMoreVC];
    
    NSError* error;
    
    NSString *readStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"读出失败:%@",error);
    }else{
        NSLog(@"读出成功");
        NSLog(@"readStr = %@",readStr);
    }
    

    if (readStr && [readStr isEqualToString:@"YES"]) {
        return NO;
    }
    else{
        //第一次进入返回YES
        return YES;
    }
    
    return req;
}

@end
