//
//  SocialAccountController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "UserManager.h"
#import "OauthWebViewController.h"
#import "NSDictionary+QueryString.h"


#define  Sina     @"新浪微博"
//#define  Tencent  @"腾讯微博"
//#define  Renren   @"人人网"
//#define  CM       @"中国移动微博"

@interface SocialBind : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic) BOOL bind;

@end

@interface SocialBindCell : UITableViewCell
{
    UIImage         *bindSinaImage;
//    UIImage         *bindTencentImage;
//    UIImage         *bindRenrenImage;
//    UIImage         *bindCmImage;
    
    UIImage         *unBindSinaImage;
//    UIImage         *unBindTencentImage;
//    UIImage         *unBindRenrenImage;
//    UIImage         *unBindCmImage;
}
@property(nonatomic, strong)UILabel *socialNameLabel;
@property(nonatomic, strong)UILabel *unbindLabel;

- (void)setWeiboBind:(SocialBind*)weibo;

@end

@interface SocialAccountController : PhoneSurfController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, OauthWebViewControllerDelegate>
{
    UITableView *tableView;
    NSMutableArray *socialAccountArray;
    
    NSString *unbindSocialAccount;
    UIView *bgView;
}

@end
