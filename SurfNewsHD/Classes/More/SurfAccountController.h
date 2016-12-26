//
//  SurfAccountController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "UserManager.h"
@interface SurfAccountController : SurfNewsViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    UITableView *tableView;
    
    UILabel *accountLabel;
}

+ (void)logoutAccount:(void(^)(BOOL))succeeded;

@end
