//
//  SurfSettingController.m
//  SurfNewsHD
//
//  Created by apple on 13-3-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfSettingController.h"
#import "AppDelegate.h"
#import "SurfRootViewController.h"
#import "WeatherManager.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "HotChannelsManager.h"
#import "SurfSettingChangePwdController.h"

#define  UnbindSina     @"新浪微博"
#define  UnbindTencent  @"腾讯微博"
#define  UnbindRenren   @"人人网"
#define  UnbindCM       @"中国移动微博"

@implementation WeiboBind

@end

@implementation WeiboBindCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        socialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 7.5f, 105.0f, 20.0f)];
        [socialNameLabel setBackgroundColor:[UIColor clearColor]];
        [socialNameLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [socialNameLabel setTextColor:[UIColor hexChangeFloat:@"DED9D1"]];
        [self.contentView addSubview:socialNameLabel];
        
        unbindLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0f, 7.5f, 40.0f, 20.0f)];
        unbindLabel.textAlignment = UITextAlignmentCenter;
        [unbindLabel setFont:[UIFont systemFontOfSize:16.0f]];
        unbindLabel.layer.cornerRadius = 0.0f;
        [self.contentView addSubview:unbindLabel];
    }
    return self;
}

- (void)setWeiboBind:(WeiboBind *)weibo
{
    socialNameLabel.text = weibo.name;
    if (weibo.bind) {
        [unbindLabel setBackgroundColor:[UIColor hexChangeFloat:@"707070"]];
        [unbindLabel setTextColor:[UIColor hexChangeFloat:@"2C2C2C"]];
        unbindLabel.text = @"解绑";
    } else {
        [unbindLabel setBackgroundColor:[UIColor hexChangeFloat:@"515151"]];
        [unbindLabel setTextColor:[UIColor hexChangeFloat:@"E4E4E4"]];
        unbindLabel.text = @"绑定";
    }
}

@end

@interface SurfSettingController ()

@end

@implementation SurfSettingController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = ViewTitleStateNone;
        weiboArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 20.0f, 178.0f, 30.0f)];
    titleImageView.image = [UIImage imageNamed:@"setting_center"];
    [self.view addSubview:titleImageView];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(2.0f, 60.0f, 186.0f, 648.0f)
                                             style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor hexChangeFloat:@"535353"];
    [self.view addSubview:tableView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(11.0f, 713.0f, 164.0f, 25.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"setting_back"]
                          forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(didBack)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self weiboBind];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager addUserLoginObserver:self];
}

- (void)didBack
{
    CATransition *t = [CATransition animation];
    t.subtype = kCATransitionFromLeft;
    t.type = kCATransitionPush;
    t.duration = 0.3f;
    [self.navigationController.view.layer addAnimation:t forKey:@"Transition"];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)weiboBind
{
    [weiboArray removeAllObjects];
    
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    
    NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
    WeiboBind *sinaWeibo = [WeiboBind new];
    sinaWeibo.name = @"新浪微博";
    if ([sinaDict valueForKey:@"access_token"] && [sinaDict valueForKey:@"uid"]) {
        sinaWeibo.bind = YES;
    } else {
        sinaWeibo.bind = NO;
    }
    
    NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
    WeiboBind *tencentWeibo = [WeiboBind new];
    tencentWeibo.name = @"腾讯微博";
    if ([tencentDict valueForKey:@"access_token"]) {
        tencentWeibo.bind = YES;
    } else {
        tencentWeibo.bind = NO;
    }
    
    NSDictionary *renrenDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
    WeiboBind *renrenWeibo = [WeiboBind new];
    renrenWeibo.name = @"人人网";
    if ([renrenDict valueForKey:@"access_token"]) {
        renrenWeibo.bind = YES;
    } else {
        renrenWeibo.bind = NO;
    }
    
    NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
    WeiboBind *cmWeibo = [WeiboBind new];
    cmWeibo.name = @"移动微博";
    if ([cmDict valueForKey:@"access_token"]) {
        cmWeibo.bind = YES;
    } else {
        cmWeibo.bind = NO;
    }

    [weiboArray addObject:sinaWeibo];
    [weiboArray addObject:tencentWeibo];
    [weiboArray addObject:renrenWeibo];
    [weiboArray addObject:cmWeibo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 窗口在返回的时候，需要更新列表。
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [weiboArray count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 3) {
        return @"";
    } else if (section == 1) {
        return @"社交账号";
    } else {
        return @"天气城市";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 3) {
        return 0.0f;
    } else {
        return 35.0f;
    } 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        WeiboBindCell *cell = [tView dequeueReusableCellWithIdentifier:@"weibo_cell"];
        if (cell == nil) {
            cell = [[WeiboBindCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"weibo_cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
            cell.contentView.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
            cell.contentView.layer.cornerRadius = 6.0f;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        [cell setWeiboBind:[weiboArray objectAtIndex:indexPath.row]];
        return cell;
    } else {
        UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
            cell.contentView.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
            cell.contentView.layer.cornerRadius = 6.0f;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(155.0f, 14.5f, 6.0f, 10.0f)];
            arrowView.image = [UIImage imageNamed:@"setting_right_arrow"];
            [cell addSubview:arrowView];
        }
        cell.textLabel.textColor = [UIColor hexChangeFloat:@"DED9D1"];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        if ([indexPath section] == 0) {
            UserManager *manager = [UserManager sharedInstance];
            if (manager.loginedUser) {
                cell.textLabel.text = @"冲浪账号";
            } else {
                cell.textLabel.text = @"登录";
            }
        } else if ([indexPath section] == 2) {        
            cell.textLabel.text = [[WeatherManager sharedInstance] weatherInfo].cityName;
        } else if ([indexPath section] == 3) {
            cell.textLabel.text = @"清除缓存";
        }
        return cell;
    }
}

#pragma mark -  UITableViewDelegate methods
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UserManager *manager = [UserManager sharedInstance];
        if (manager.loginedUser) {
            SurfAccountController *controller = [[SurfAccountController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef ipad
            SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
            [rootController.leftController loginAction];
#else
#endif
        }
    } else if (indexPath.section == 1) {
        WeiboBind *weibo = [weiboArray objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            if (weibo.bind) {
                unbind = UnbindSina;
                [self showAlert];
            } else {
                [self oauthWebViewController:SinaOAuth];
            }
        } else if (indexPath.row == 1) {
            if (weibo.bind) {
                unbind = UnbindTencent;
                [self showAlert];
            } else {
                [self oauthWebViewController:TencentOAuth];
            }
        } else if (indexPath.row == 2) {
            if (weibo.bind) {
                unbind = UnbindRenren;
                [self showAlert];
            } else {
                [self oauthWebViewController:RenRenOAuth];
            }
        } else if (indexPath.row == 3) {
            if (weibo.bind) {
                unbind = UnbindCM;
                [self showAlert];
            } else {
                [self oauthWebViewController:ChinaMobielOAuth];
            }
        }
    } else if (indexPath.section == 2) {
        SurfSelectCityController *cityController = [[SurfSelectCityController alloc] init];
        [self.navigationController pushViewController:cityController animated:YES];
    } else if (indexPath.section == 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认清除缓存"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        alertView.tag = 100;
        [alertView show];
    }

    [tView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 166.0f, 30.0f)];
        sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
        sectionTitle.font = [UIFont systemFontOfSize:18.0f];
        sectionTitle.backgroundColor = [UIColor clearColor];
        sectionTitle.textColor = [UIColor hexChangeFloat:@"9D9696"];
        [view addSubview:sectionTitle];
        return view;
    } else {
        return tView.tableHeaderView;
    }
}

//跳转到授权界面
- (void)oauthWebViewController:(OAuthClientType)type
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    OauthWebViewController *controller = [[OauthWebViewController alloc] initWithOAuthClientType:type];
    controller.delegate = self;
    UINavigationController *navgation = [[UINavigationController alloc] initWithRootViewController:controller];
    rootController.willAppear = NO;
    [rootController presentModalViewController:navgation animated:YES];
}

- (void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"是否解除绑定%@", unbind]
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定",nil];
    alertView.tag = 200;
    [alertView show];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 100) {
        SurfNotification *notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
        [[ThreadsManager sharedInstance] cleanAllCaches];
        [notification hideNotificatioIndicator:nil];
    } else if (buttonIndex == 1 && alertView.tag == 200) {
        SurfDbManager *dbManager = [SurfDbManager sharedInstance];
        if ([unbind isEqualToString:UnbindSina]) {
            [dbManager clearSinaWeiboInfoForUser:kDefaultID];
        } else if ([unbind isEqualToString:UnbindTencent]) {
            [dbManager clearTencentWeiboInfoForUser:kDefaultID];
        } else if ([unbind isEqualToString:UnbindRenren]) {
            [dbManager clearRenrenWeiboInfoForUser:kDefaultID];
        } else if ([unbind isEqualToString:UnbindCM]) {
            [dbManager clearCMWeiboInfoForUser:kDefaultID];
        }
        [self weiboBind];
        [tableView reloadData];
    }
}

#pragma mark OauthWebViewControllerDelegate method
- (void)oauthResult:(OauthWebViewController*)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissModalViewControllerAnimated:YES];
    
    [self weiboBind];
    [tableView reloadData];
}

- (void)oauthFailed:(OauthWebViewController*)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissModalViewControllerAnimated:YES];
    
    if (type == SinaOAuth) {
        [SurfNotification surfNotification:@"绑定新浪微博失败,请重试"];
    } else if (type == TencentOAuth) {
        [SurfNotification surfNotification:@"绑定腾讯微博失败,请重试"];
    } else if (type == RenRenOAuth) {
        [SurfNotification surfNotification:@"绑定人人网失败,请重试"];
    } else if (type == ChinaMobielOAuth) {
        [SurfNotification surfNotification:@"绑定中国移动微博失败,请重试"];
    }
}

#pragma mark UserManagerObserver methods
- (void)currentUserLoginChanged
{
    [tableView reloadData];
}

- (void)dealloc
{
    UserManager *manager = [UserManager sharedInstance];
    [manager removeUserLoginObserver:self];
}

@end
