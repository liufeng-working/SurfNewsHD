//
//  SurfAccountController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfAccountController.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "SurfDbManager.h"
#import "SurfSettingChangePwdController.h"

@interface SurfAccountController ()

@end

@implementation SurfAccountController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = ViewTitleStateNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 20.0f, 178.0f, 30.0f)];
    titleImageView.image = [UIImage imageNamed:@"account_center"];
    [self.view addSubview:titleImageView];
    
    accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 65.0f, 175.0f, 30.0f)];
    [accountLabel setBackgroundColor:[UIColor clearColor]];
    [accountLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [accountLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:accountLabel];
    
    UserManager *manager = [UserManager sharedInstance];
    accountLabel.text = [NSString stringWithFormat:@"账号:%@", manager.loginedUser.phoneNum];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(2.0f, 100.0f, 186.0f, 620.0f)
                                             style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor colorWithHexString:@"535353"];
    [self.view addSubview:tableView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(11.0f, 713.0f, 164.0f, 25.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"setting_back"]
                          forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(didBack)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithHexString:@"7B7777"];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"DED9D1"];
        cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"7B7777"];
        cell.contentView.layer.cornerRadius = 6.0f;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(155.0f, 14.5f, 6.0f, 10.0f)];
        arrowView.image = [UIImage imageNamed:@"setting_right_arrow"];
        [cell addSubview:arrowView];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"修改密码";
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"退出账号";
    }
    return cell;
}

#pragma mark -  UITableViewDelegate methods
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SurfSettingChangePwdController *controller = [[SurfSettingChangePwdController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认退出账户"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        alertView.tag = 100;
        [alertView show];
    }
    [tView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 100) {  
        [SurfAccountController logoutAccount:^(BOOL result) {
            if (result) {
            	[self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}


// 注销用户，由于时间比较紧，没有去封装成工具类。
+ (void)logoutAccount:(void(^)(BOOL))result{
    UserManager *manager = [UserManager sharedInstance];    
    [FileUtil deleteContentsOfDir:[PathUtil rootPathOfUser] withCompletionHandler:^(BOOL succeeded) {
        if (succeeded) {
            [manager quitLogin];
        }
        if (result != nil) {
            result(succeeded);
        }
    }];
}

@end
