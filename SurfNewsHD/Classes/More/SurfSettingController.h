//
//  SurfSettingController.h
//  SurfNewsHD
//
//  Created by apple on 13-3-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurfNewsViewController.h"
#import "SurfDbManager.h"
#import "OauthWebViewController.h"
#import "SurfSelectCityController.h"
#import "SurfAccountController.h"

@interface WeiboBind : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic) BOOL bind;

@end

@interface WeiboBindCell : UITableViewCell
{
    UILabel *socialNameLabel;
    UILabel *unbindLabel;
}

- (void)setWeiboBind:(WeiboBind*)weibo;

@end

@interface SurfSettingController : SurfNewsViewController <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, OauthWebViewControllerDelegate, UserManagerObserver>
{
    UITableView *tableView;
    NSMutableArray *weiboArray;
    
    NSString *unbind;
}

@end
