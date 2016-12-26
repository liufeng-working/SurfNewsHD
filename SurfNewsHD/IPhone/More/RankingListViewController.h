//
//  RankingListViewController.h
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "RankingListCell.h"
#import "RankingManager.h"
#import "RankingInfoResponse.h"
#import "NSString+Extensions.h"
#import "RankingShareCtl.h"
#import "SNThreadViewerController.h"

#import "PhoneSinaWeiboUserFriendsController.h"
#import "OAuth2Client.h"
#import "AppDelegate.h"
#import "FileUtil.h"
#import "UIView+NightMode.h"
#import <MessageUI/MessageUI.h>
#import "ContentShareController.h"


typedef enum {
    DateType = 0,
    WeekType
    
} RankingType;

@interface RankingListViewController : PhoneSurfController<UITableViewDelegate,UITableViewDataSource, NightModeChangedDelegate,RankingShareCtlDelegate,OauthWebViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    UIActivityIndicatorView*    mActivityIndicator;
    
    UITableView     *rankingListTableView;
    NSMutableArray *my_rankingList;
    UIView *SwitchRankingBgView;
    UISegmentedControl *segmentedControl;
    
    BOOL addBtn;
    UIButton *addButton;
    UIButton *cancelButton;
    UIButton *dateButton;
    BOOL dateBtnSelcted;
    UIButton *weekButton;
    BOOL weekBtnSelcted;
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
    
    RankingShareCtl *RankingShare;
}

@end
