//
//  CollectViewController.h
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableFootView.h"
#import "LoadingView.h"
#import "PhoneSurfController.h"
#import "UserManager.h"
#import "CustomCellBackgroundView.h"
#import "NSString+Extensions.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"
#import "CollectTableViewCell.h"



@interface CollectViewController : PhoneSurfController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NightModeChangedDelegate>
{
    UITableView* myTable;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    BOOL isLast;//是否是最后一页
    int currentPage;    UIImageView         *backImage;
}

@property (nonatomic, strong)   NSMutableArray     *collectLocationArr;


@end
