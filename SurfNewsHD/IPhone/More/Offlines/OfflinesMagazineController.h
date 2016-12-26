//
//  OfflinesMagazineController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "OfflineIssueInfo.h"
#import "OfflineDownloader.h"

@interface OfflinesMagazineCell : UITableViewCell
{
    UILabel *nameLabel;
    UILabel *statusLabel;
    UIButton *selectedButton;
    UIView *lineView;
}

@property(nonatomic, strong) OfflineIssueInfo *offlineIssueInfo;

- (void)setOfflineIssueInfo:(OfflineIssueInfo *)offlineIssueInfo deleteModel:(BOOL)del;
- (void)deleteModelAnimation;    //删除选择框出来时的动画
- (void)normalModelAnimation;    //取消删除时的动画
- (void)applyTheme;
- (void)didSelectedAction;
@end

@interface OfflinesMagazineController : PhoneSurfController <UITableViewDelegate, UITableViewDataSource,OfflineDownloaderDelegate>
{
    NSMutableArray *offlinesArray;
    UIButton *cleanButton;
    UIButton *okDeleteButton;
    UIButton *cancleDeleteButton;
    UIButton *pauseButton;
    UIButton *startButton;
    UIButton *cleanAllButton;
    UITableView *tableView;
    UIView *toolBarView;
    
    BOOL deleteModel;
    UIView *bgView;

}

- (void)deleteButtonCountChange;

@end
