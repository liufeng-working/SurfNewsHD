//
//  SocialAccountController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SocialAccountController.h"
#import "AppDelegate.h"


@implementation SocialBind

@end

@implementation SocialBindCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat socialY = (CGRectGetHeight(self.bounds) - 30)/2;
        CGRect socialR = CGRectMake(70, socialY, 100, 30);
        _socialNameLabel = [[UILabel alloc] initWithFrame:socialR];
        [_socialNameLabel setBackgroundColor:[UIColor clearColor]];
        [_socialNameLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_socialNameLabel setTextColor:[UIColor colorWithHexString:@"DED9D1"]];
        [self.contentView addSubview:_socialNameLabel];
        
        _unbindLabel = [[UILabel alloc] initWithFrame:CGRectMake(250.0f, 10.5f, 60.0f, 20.0f)];
        [_unbindLabel setTextAlignment:NSTextAlignmentCenter];
        [_unbindLabel setFont:[UIFont systemFontOfSize:14]];
        _unbindLabel.layer.cornerRadius = 0.0f;
        [self.contentView addSubview:_unbindLabel];
        
//        bindCmImage = [UIImage imageNamed:@"bind_cm_logo"];
        bindSinaImage = [UIImage imageNamed:@"bind_sina_logo"];
//        bindTencentImage = [UIImage imageNamed:@"bind_tencent_logo"];
//        bindRenrenImage = [UIImage imageNamed:@"bind_renren_logo"];
        
//        unBindCmImage = [UIImage imageNamed:@"unbind_cm_logo"];
        unBindSinaImage = [UIImage imageNamed:@"unbind_sina_logo"];;
//        unBindTencentImage = [UIImage imageNamed:@"unbind_tencent_logo"];
//        unBindRenrenImage = [UIImage imageNamed:@"unbind_renren_logo"];
    }
    return self;
}

- (void)setWeiboBind:(SocialBind *)weibo
{
    NSLog(@"weibo.name: %@", weibo.name);
    _socialNameLabel.text = weibo.name;
    if (weibo.bind)
    {
        [_unbindLabel setBackgroundColor:[UIColor colorWithRed:192/255.0f green:0/255.0f blue:36/255.0f alpha:1]];//[UIColor colorWithHexString:@"707070"]];
        [_unbindLabel setTextColor:[UIColor colorWithHexString:@"E4E4E4"]];//2C2C2C
        _unbindLabel.text = @"解绑";
        if ([weibo.name isEqualToString:@"新浪微博"])
            [self.imageView setImage:bindSinaImage];
//        else if([weibo.name isEqualToString:@"腾讯微博"])
//            [self.imageView setImage:bindTencentImage];
//        else if([weibo.name isEqualToString:@"人人网"])
//            [self.imageView setImage:bindRenrenImage];
//        else if([weibo.name isEqualToString:@"中国移动微博"])
//            [self.imageView setImage:bindCmImage];
    }
    else
    {
        [_unbindLabel setBackgroundColor:[UIColor colorWithRed:192/255.0f green:0/255.0f blue:36/255.0f alpha:1]];//colorWithHexString:@"515151"
        [_unbindLabel setTextColor:[UIColor colorWithHexString:@"E4E4E4"]];
        _unbindLabel.text = @"未绑定";
        if ([weibo.name isEqualToString:@"新浪微博"])
            [self.imageView setImage:unBindSinaImage];
//        else if([weibo.name isEqualToString:@"腾讯微博"])
//            [self.imageView setImage:unBindTencentImage];
//        else if([weibo.name isEqualToString:@"人人网"])
//            [self.imageView setImage:unBindRenrenImage];
//        else if([weibo.name isEqualToString:@"中国移动微博"])
//            [self.imageView setImage:unBindCmImage];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat imgY = (CGRectGetHeight(self.bounds) - 30) / 2;
    CGRect imgR = CGRectMake(10, imgY, 30, 30);
    [self.imageView setFrame:imgR];

}

@end

@implementation SocialAccountController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        socialAccountArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"账号绑定";
    
    
    [self addBottomToolsBar];
    [self socialAccountStatus];
    
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, [self StateBarHeight], kContentWidth, 160-40-40-40) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [tableView setScrollEnabled:NO];
    [tableView setSeparatorColor:[UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1]];

    [self.view addSubview:tableView];
}


//社交账号绑定状态
- (void)socialAccountStatus
{
    [socialAccountArray removeAllObjects];
    
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    
    NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
    SocialBind *sinaWeibo = [SocialBind new];
    sinaWeibo.name = Sina;
    if ([sinaDict valueForKey:@"access_token"] && [sinaDict valueForKey:@"uid"]) {
        sinaWeibo.bind = YES;
    } else {
        sinaWeibo.bind = NO;
    }
    
//    NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
//    SocialBind *tencentWeibo = [SocialBind new];
//    tencentWeibo.name = Tencent;
//    if ([tencentDict valueForKey:@"access_token"]) {
//        tencentWeibo.bind = YES;
//    } else {
//        tencentWeibo.bind = NO;
//    }
    
//    NSDictionary *renrenDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
//    SocialBind *renrenWeibo = [SocialBind new];
//    renrenWeibo.name = Renren;
//    if ([renrenDict valueForKey:@"access_token"]) {
//        renrenWeibo.bind = YES;
//    } else {
//        renrenWeibo.bind = NO;
//    }
    
//    NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
//    SocialBind *cmWeibo = [SocialBind new];
//    cmWeibo.name = CM;
//    if ([cmDict valueForKey:@"access_token"]) {
//        cmWeibo.bind = YES;
//    } else {
//        cmWeibo.bind = NO;
//    }
    
    [socialAccountArray addObject:sinaWeibo];
//    [socialAccountArray addObject:tencentWeibo];
//    [socialAccountArray addObject:renrenWeibo];
//    [socialAccountArray addObject:cmWeibo];
}

- (void)reloadCell:(SocialBindCell *)cell andIndex:(NSIndexPath *)indexPath
{
    if ([ThemeMgr sharedInstance].isNightmode)
    {
        [cell.socialNameLabel setTextColor:[UIColor grayColor]];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor grayColor]];
    }
    else
    {
        [cell.socialNameLabel setTextColor:[UIColor grayColor]];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
    }
}


#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return [socialAccountArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SocialBindCell *cell = [tView dequeueReusableCellWithIdentifier:@"weibo_cell"];
    if (cell == nil) {
        cell = [[SocialBindCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:@"weibo_cell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor colorWithHexString:@"7B7777"];
//        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"7B7777"];
        
//        cell.contentView.layer.cornerRadius = 6.0f;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    }
    
    [self reloadCell:cell andIndex:indexPath];
    [cell setWeiboBind:[socialAccountArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark -  UITableViewDelegate methods
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SocialBind *weibo = [socialAccountArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        if (weibo.bind) {
            unbindSocialAccount = Sina;
            [self showAlert];
        } else {
            [self oauthWebViewController:SinaOAuth];
        }
    }
//        else if (indexPath.row == 1) {
//        if (weibo.bind) {
//            unbindSocialAccount = Tencent;
//            [self showAlert];
//        } else {
//            [self oauthWebViewController:TencentOAuth];
//        }
//    }
//    else if (indexPath.row == 2) {
//        if (weibo.bind) {
//            unbindSocialAccount = CM;
//            [self showAlert];
//        } else {
//            [self oauthWebViewController:ChinaMobielOAuth];
//        }
//    }
    [tView deselectRowAtIndexPath:indexPath animated:YES];
}

//跳转到授权界面
- (void)oauthWebViewController:(OAuthClientType)type
{
    [theApp.oauthWebViewController setOAuthClientType:type];
//    OauthWebViewController *controller = [[OauthWebViewController alloc] initWithOAuthClientType:type];
    theApp.oauthWebViewController.delegate = self;
//    [self presentModalViewController:theApp.oauthWebViewController animated:YES];
    [self presentViewController:theApp.oauthWebViewController
                       animated:YES completion:nil];
}

//弹出框
- (void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"是否解除绑定%@", unbindSocialAccount]
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定",nil];
    alertView.tag = 100;
    [alertView show];
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];

//    bgView.backgroundColor = [UIColor colorWithHexString:night?@"2D2E2F":@"F8F8F8"];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 100) {
        SurfDbManager *dbManager = [SurfDbManager sharedInstance];
        if ([unbindSocialAccount isEqualToString:Sina]) {
            [dbManager clearSinaWeiboInfoForUser:kDefaultID];
        }
//        else if ([unbindSocialAccount isEqualToString:Tencent]) {
//            [dbManager clearTencentWeiboInfoForUser:kDefaultID];
//        } else if ([unbindSocialAccount isEqualToString:Renren]) {
//            [dbManager clearRenrenWeiboInfoForUser:kDefaultID];
//        } else if ([unbindSocialAccount isEqualToString:CM]) {
//            [dbManager clearCMWeiboInfoForUser:kDefaultID];
//        }
        [self socialAccountStatus];
        [tableView reloadData];
    }
}

#pragma mark OauthWebViewControllerDelegate methods
//授权成功
- (void)oauthResult:(OauthWebViewController *)controller oauthTpye:(OAuthClientType)type
{
//    [controller dismissModalViewControllerAnimated:YES];
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self socialAccountStatus];
    [tableView reloadData];
    
    [PhoneNotification autoHideWithText:@"授权成功"];
}

//授权失败
- (void)oauthFailed:(OauthWebViewController *)controller oauthTpye:(OAuthClientType)type
{
//    [controller dismissModalViewControllerAnimated:YES];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
