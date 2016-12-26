//
//  CloudRootController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "FavsManager.h"
#import "ThreadSummary.h"
#import "UserManager.h"

@interface CloudRootController : SurfNewsViewController<UITableViewDataSource,
UITableViewDelegate, UserManagerObserver, UIAlertViewDelegate>
{

}

@end
