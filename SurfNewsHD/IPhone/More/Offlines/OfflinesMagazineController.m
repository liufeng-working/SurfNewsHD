//
//  OfflinesMagazineController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "OfflinesMagazineController.h"

#define ButtonWidth   64.0f
#define ButtonHeight  49.0f

@implementation OfflinesMagazineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 230.0f, 20.0f)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:nameLabel];
        
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(250.0f, 15.0f, 60.0f, 20.0f)];
        statusLabel.backgroundColor = [UIColor clearColor];
        [statusLabel setTextAlignment:NSTextAlignmentRight];
        statusLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:statusLabel];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 49.0f, self.contentView.bounds.size.width, 1.0f)];
        [lineView setBackgroundColor:[UIColor grayColor]];
        [self addSubview:lineView];
    }
    return self;
}

- (void)setOfflineIssueInfo:(OfflineIssueInfo *)info deleteModel:(BOOL)del;
{
    _offlineIssueInfo = info;
    
    nameLabel.text = info.name;
    
    switch (info.issueStatus) {
        case IssueStatusDataReady:
            statusLabel.text = @"已完成";
            break;
        case IssueStatusPending:
            statusLabel.text = @"准备中";
            break;
        case IssueStatusDownloading:
            statusLabel.text = @"下载中";
            break;
        case IssueStatusStopped:
            statusLabel.text = @"暂停";
            break;
        case IssueStatusUnzipping:
            statusLabel.text = @"解压中";
            break;
        case IssueStatusWillDiscard:
            statusLabel.text = @"出错了";
            break;
        default:
            break;
    }
    
    if (del) {
        if (!selectedButton) {
            selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectedButton.frame = CGRectMake(10.0f, 15.0f, 20.0f, 20.0f);
            [selectedButton addTarget:self action:@selector(didSelectedAction) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:selectedButton];
        }
        nameLabel.frame = CGRectMake(50.0f, 15.0f, 180.0f, 20.0f);
    } else {
        if (selectedButton) {
            [selectedButton removeFromSuperview];
            selectedButton = nil;
        }
        nameLabel.frame = CGRectMake(10.0f, 15.0f, 230.0f, 20.0f);
    }
    
    if (_offlineIssueInfo.isDeleteStatus) {
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    } else {
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
    }
}

- (void)deleteModelAnimation
{
    if (!selectedButton) {
        selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectedButton.frame = CGRectMake(-30.0f, 15.0f, 20.0f, 20.0f);
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
        [selectedButton addTarget:self action:@selector(didSelectedAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectedButton];
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         selectedButton.frame =  CGRectMake(10.0f, 15.0f, 20.0f, 20.0f);
                         nameLabel.frame = CGRectMake(50.0f, 15.0f, 180.0f, 20.0f);
    }];
}

- (void)normalModelAnimation
{
    if (selectedButton) {
        [selectedButton removeFromSuperview];
        selectedButton = nil;
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         selectedButton.frame =  CGRectMake(-30.0f, 15.0f, 20.0f, 20.0f);
                         nameLabel.frame = CGRectMake(10.0f, 15.0f, 230.0f, 20.0f);
                     }];
}

- (void)didSelectedAction
{
    if (_offlineIssueInfo.isDeleteStatus) {
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
    } else {
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    }
    
    _offlineIssueInfo.isDeleteStatus = !_offlineIssueInfo.isDeleteStatus;
    
    OfflinesMagazineController *controller = [self findUserObject:[OfflinesMagazineController class]];
    if ([controller isKindOfClass:[OfflinesMagazineController class]]) {
        [controller deleteButtonCountChange];
    }
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        nameLabel.textColor = [UIColor grayColor];
        statusLabel.textColor = [UIColor grayColor];
        lineView.backgroundColor = [UIColor grayColor];
    } else {
        nameLabel.textColor = [UIColor colorWithHexString:@"999292"];
        statusLabel.textColor = [UIColor colorWithHexString:@"999292"];
        lineView.backgroundColor = [UIColor colorWithHexString:@"999292"];
    }
}

@end

@implementation OfflinesMagazineController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        offlinesArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"期刊下载管理";
    
//    if (!bgView) {
//        bgView=[[UIView alloc] initWithFrame:CGRectMake(0, self.StateBarHeight, self.view.frame.size.width, self.view.frame.size.height)];
//    }
//    if (![self.view.subviews containsObject:bgView]) {
//        [self.view addSubview:bgView];
//    }
	
    CGRect tableViewRwct = CGRectMake(0, self.StateBarHeight, 320, self.view.frame.size.height-self.StateBarHeight);
    tableView = [[UITableView alloc] initWithFrame:tableViewRwct style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    [offlinesArray addObjectsFromArray:[[OfflineDownloader sharedInstance] getAllOfflineIssuesInfo]];
    
    toolBarView = [self addBottomToolsBar];
    if (toolBarView && offlinesArray.count > 0) {
        cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cleanButton setFrame:CGRectMake(256, 0, 64, 49)];
        [cleanButton setImage:[UIImage imageNamed:@"clearAllBt"] forState:UIControlStateNormal];
        [cleanButton addTarget:self action:@selector(deleteOfflineIssue) forControlEvents:UIControlEventTouchUpInside];
        [toolBarView addSubview:cleanButton];
        
        for (OfflineIssueInfo *info in offlinesArray) {
            if (info.issueStatus == IssueStatusDownloading ||
                info.issueStatus == IssueStatusPending) {
                pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [pauseButton setFrame:CGRectMake((kContentWidth - ButtonWidth) / 2, 0, ButtonWidth, ButtonHeight)];
                [pauseButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                [pauseButton addTarget:self action:@selector(pauseDownload) forControlEvents:UIControlEventTouchUpInside];
                [toolBarView addSubview:pauseButton];
                return;
            }
        }
        for (OfflineIssueInfo *info in offlinesArray) {
            if (info.issueStatus == IssueStatusStopped) {
                startButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [startButton setFrame:CGRectMake((kContentWidth - ButtonWidth) / 2, 0, ButtonWidth, ButtonHeight)];
                [startButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
                [startButton addTarget:self action:@selector(resumeDownload) forControlEvents:UIControlEventTouchUpInside];
                [toolBarView addSubview:startButton];
                return;
            }
        }
    }
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
//    bgView.backgroundColor = [UIColor colorWithHexString:night?@"2D2E2F":@"F8F8F8"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[OfflineDownloader sharedInstance] addEventDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[OfflineDownloader sharedInstance] removeEventDelegate:self];
    
    for (OfflineIssueInfo *info in offlinesArray) {
        info.isDeleteStatus = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return offlinesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"offlines_cell";
    OfflinesMagazineCell *cell = [tView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[OfflinesMagazineCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell applyTheme];
    }
    
    OfflineIssueInfo *info = [offlinesArray objectAtIndex:indexPath.row];
    [cell setOfflineIssueInfo:info deleteModel:deleteModel];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tView indexPathForSelectedRow] animated:YES];
    OfflineIssueInfo *info = [offlinesArray objectAtIndex:indexPath.row];
    if (info.issueStatus == IssueStatusDownloading || info.issueStatus == IssueStatusPending) {
        [[OfflineDownloader sharedInstance] removeIssueTaskWithMagId:info.magId issueId:info.issId];
    } else if (info.issueStatus == IssueStatusStopped) {
        [self addMagazineTask:info];
    } else {
        return;
    }
    
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

//-(NSString *)tableView:(UITableView *)tView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}
//
//- (void)tableView:(UITableView *)tView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    OfflineIssueInfo *info = [offlinesArray objectAtIndex:indexPath.row];
//    [[OfflineDownloader sharedInstance] deleteDataForMagIssue:info];
//    [offlinesArray removeObject:info];
//    [self reloadTableView];
//}

//清除数据
- (void)deleteOfflineIssue
{
    BOOL isAllStopped = YES;
    for (OfflineIssueInfo* info in offlinesArray)
    {
        if(info.issueStatus != IssueStatusStopped
           && info.issueStatus != IssueStatusDataReady)
        {
            isAllStopped = NO;
            break;
        }
    }
    if(!isAllStopped)
    {
        [PhoneNotification autoHideWithText:@"请先暂停任务后再进行操作!"];
        return;
    }
    
    
    deleteModel = YES;
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        if ([cell isKindOfClass:[OfflinesMagazineCell class]]) {
            OfflinesMagazineCell *omCell = (OfflinesMagazineCell *)cell;
            [omCell deleteModelAnimation];
        }
    }
    
    cleanButton.hidden = YES;
    pauseButton.hidden = YES;
    startButton.hidden = YES;
    
    if (!cancleDeleteButton && !okDeleteButton && !cleanAllButton) {
        cancleDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancleDeleteButton setFrame:CGRectMake(0, 0, 77, 49)];
        [cancleDeleteButton setBackgroundImage:[UIImage imageNamed:@"gray_button"] forState:UIControlStateNormal];
        [cancleDeleteButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleDeleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancleDeleteButton addTarget:self action:@selector(cancleDeleteOfflineIssue) forControlEvents:UIControlEventTouchUpInside];
        [cancleDeleteButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 10.0f, 0.0f, 0.0f)];
        [toolBarView addSubview:cancleDeleteButton];
        
        okDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [okDeleteButton setFrame:CGRectMake(243, 7, 67, 34)];
        [okDeleteButton setBackgroundImage:[UIImage imageNamed:@"navBtnBG"] forState:UIControlStateNormal];
        [okDeleteButton setTitle:@"确定" forState:UIControlStateNormal];
        [okDeleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okDeleteButton addTarget:self action:@selector(okDeleteOfflineIssue) forControlEvents:UIControlEventTouchUpInside];
        [toolBarView addSubview:okDeleteButton];
        
        cleanAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cleanAllButton setFrame:CGRectMake(127, 7, 67, 34)];
        [cleanAllButton setBackgroundImage:[UIImage imageNamed:@"navBtnBG"] forState:UIControlStateNormal];
        [cleanAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [cleanAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cleanAllButton addTarget:self action:@selector(clickClearAllButton) forControlEvents:UIControlEventTouchUpInside];
        [toolBarView addSubview:cleanAllButton];
    } else {
        cancleDeleteButton.hidden = NO;
        okDeleteButton.hidden = NO;
        cleanAllButton.hidden = NO;
    }
//    BOOL cleanSuccess = YES;
//    [PhoneNotification manuallyHideWithIndicator];
//    
//    for (OfflineIssueInfo *info in offlinesArray) {
//        if ([FileUtil deleteContentsOfDir:[PathUtil pathOfOfflineDataForIssue:info]]) {
//            [offlinesArray removeObject:info];
//        } else {
//            cleanSuccess = NO;
//            [PhoneNotification autoHideWithText:@"删除过程中出现错误,请重试"];
//            break;
//        }
//    }
//    
//    if (cleanSuccess) {
//        OfflinesMagazines *offlines = [OfflinesMagazines new];
//        offlines.issues = offlinesArray;
//        [[EzJsonParser serializeObjectWithUtf8Encoding:offlines] writeToFile:[PathUtil pathOfOfflineMagazineInfo] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        [self getMagazineOfflines];
//        [self reloadTableView];
//        [PhoneNotification autoHideWithText:@"期刊离线包都已删除"];
//    }
}

- (void)cancleDeleteOfflineIssue
{
    deleteModel = NO;
    cancleDeleteButton.hidden = YES;
    okDeleteButton.hidden = YES;
    cleanButton.hidden = NO;
    cleanAllButton.hidden = YES;
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        if ([cell isKindOfClass:[OfflinesMagazineCell class]]) {
            OfflinesMagazineCell *omCell = (OfflinesMagazineCell *)cell;
            [omCell normalModelAnimation];
        }
    }
    for (OfflineIssueInfo *info in offlinesArray) {
        info.isDeleteStatus = NO;
    }
    [self pauseAndResumeButtonStatus];
    
    //要把按钮titile复位
    [okDeleteButton setTitle:@"确定"
                    forState:UIControlStateNormal];
}

- (void)okDeleteOfflineIssue
{
    NSInteger deleCount = 0;
    for (NSInteger i = 0; i < offlinesArray.count; i++) {
        OfflineIssueInfo *info = offlinesArray[i];
        if (info.isDeleteStatus) {
            [[OfflineDownloader sharedInstance] removeIssueTaskWithMagId:info.magId
                                                                 issueId:info.issId];
            [[OfflineDownloader sharedInstance] deleteDataForMagIssue:info];
            [offlinesArray removeObject:info];
            i --;
            deleCount ++;
        }
    }
    
    if (deleCount != 0) {
        [self reloadTableView];
    } else {
        [PhoneNotification autoHideWithText:@"请勾选要删除的期刊"];
    }
}

- (void)clickClearAllButton{
    if (offlinesArray.count > 0) {
        NSArray *cellArr = tableView.visibleCells;//OfflinesMagazineCell *cell
        
        for(NSInteger i = 0; i < offlinesArray.count; i++) {
            OfflineIssueInfo *info = [offlinesArray objectAtIndex:i];
            info.isDeleteStatus = YES;
            OfflinesMagazineCell *cell = [cellArr objectAtIndex:i];
            [cell setOfflineIssueInfo:info deleteModel:YES];
        }
        
        [okDeleteButton setTitle:[NSString stringWithFormat:@"确定(%@)", @(offlinesArray.count)] forState:UIControlStateNormal];
    }
}

- (void)pauseDownload
{
    if (!startButton) {
        startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [startButton setFrame:CGRectMake((kContentWidth - ButtonWidth) / 2, 0, ButtonWidth, ButtonHeight)];
        [startButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [startButton addTarget:self action:@selector(resumeDownload) forControlEvents:UIControlEventTouchUpInside];
        [toolBarView addSubview:startButton];
    }
    pauseButton.hidden = YES;
    startButton.hidden = NO;
    
    
    OfflineDownloader* dlr = [OfflineDownloader sharedInstance];
    [dlr stopAllIssueTasks];
    offlinesArray = [[dlr getAllOfflineIssuesInfo] mutableCopy];
    [tableView reloadData];
}

- (void)resumeDownload
{
    if (!pauseButton) {
        pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pauseButton setFrame:CGRectMake((kContentWidth - ButtonWidth) / 2, 0, ButtonWidth, ButtonHeight)];
        [pauseButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [pauseButton addTarget:self action:@selector(pauseDownload) forControlEvents:UIControlEventTouchUpInside];
        [toolBarView addSubview:pauseButton];
    }
    startButton.hidden = YES;
    pauseButton.hidden = NO;
    for (OfflineIssueInfo *info in offlinesArray) {
        if (info.issueStatus != IssueStatusDataReady) {
            [self addMagazineTask:info];
        }
    }
}

- (void)pauseAndResumeButtonStatus
{
    for (OfflineIssueInfo *info in offlinesArray) {
        if (info.issueStatus == IssueStatusDownloading ||
            info.issueStatus == IssueStatusPending) {
            if (!pauseButton) {
                pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [pauseButton setFrame:CGRectMake((kContentWidth - ButtonWidth) / 2, 0, ButtonWidth, ButtonHeight)];
                [pauseButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                [pauseButton addTarget:self action:@selector(pauseDownload) forControlEvents:UIControlEventTouchUpInside];
                [toolBarView addSubview:pauseButton];
            }
            pauseButton.hidden = NO;
            return;
        }
    }
    for (OfflineIssueInfo *info in offlinesArray) {
        if (info.issueStatus == IssueStatusStopped) {
            if (!startButton) {
                startButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [startButton setFrame:CGRectMake((kContentWidth - ButtonWidth) / 2, 0, ButtonWidth, ButtonHeight)];
                [startButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
                [startButton addTarget:self action:@selector(resumeDownload) forControlEvents:UIControlEventTouchUpInside];
                [toolBarView addSubview:startButton];
            }
            startButton.hidden = NO;
            return;
        }
    }
    NSInteger i = 0;
    for (OfflineIssueInfo *info in offlinesArray) {
        if (info.issueStatus == IssueStatusDataReady) {
            i++;
        }
    }
    if (i == offlinesArray.count) {
        if (startButton) {
            [startButton removeFromSuperview];
            startButton = nil;
        }
        if (pauseButton) {
            [pauseButton removeFromSuperview];
            pauseButton = nil;
        }
    }
}

- (void)reloadTableView
{
    if (offlinesArray.count <= 0) {
        [cleanButton removeFromSuperview];
        [okDeleteButton removeFromSuperview];
        [cancleDeleteButton removeFromSuperview];
        [pauseButton removeFromSuperview];
        [startButton removeFromSuperview];
        [cleanAllButton removeFromSuperview];
        cleanButton = nil;
        okDeleteButton = nil;
        cancleDeleteButton = nil;
        pauseButton = nil;
        startButton = nil;
        cleanAllButton = nil;
    } else {
        if (!cleanButton) {
            cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [cleanButton setFrame:CGRectMake(256, 0, 64, 49)];
            [cleanButton setBackgroundImage:[UIImage imageNamed:@"clearAllBt"] forState:UIControlStateNormal];
            [cleanButton addTarget:self action:@selector(deleteOfflineIssue) forControlEvents:UIControlEventTouchUpInside];
            [toolBarView addSubview:cleanButton];
        }
        cleanButton.hidden = NO;
        [self pauseAndResumeButtonStatus];
    }
    [tableView reloadData];
}

- (void)addMagazineTask:(OfflineIssueInfo*)info
{
    if([[OfflineDownloader sharedInstance] isIssueOfflineDataReady:info.magId issId:info.issId])
        return;
    
    MagIssueOfflineDownloadTask *task = [MagIssueOfflineDownloadTask new];
    task.magId = info.magId;
    task.issueId = info.issId;
    task.url = info.zipUrl;
    task.issueName = info.name;
    
    [[OfflineDownloader sharedInstance] addDownloadTask:task];
}

- (void)deleteButtonCountChange
{
    NSInteger deleteCount = 0;
    
    for(OfflineIssueInfo *info in offlinesArray) {
        if (info.isDeleteStatus) {
            deleteCount ++;
        }
    }
    if (deleteCount == 0) {
        [okDeleteButton setTitle:@"确定"
                        forState:UIControlStateNormal];
        return;
    }
    [okDeleteButton setTitle:[NSString stringWithFormat:@"确定(%@)", @(deleteCount)]
                    forState:UIControlStateNormal];
}

#pragma mark - OfflineDownloaderDelegate
- (void)downloadingIssueStatusChanged:(OfflineIssueInfo*)issue;
{
    NSInteger row = [offlinesArray indexOfObject:issue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    
    //这里保证全部下载完成后不再出现按钮
    NSInteger i = 0;
    for (OfflineIssueInfo *info in offlinesArray) {
        if (info.issueStatus == IssueStatusDataReady) {
            i++;
        }
    }
    if (i == offlinesArray.count) {
        if (startButton) {
            [startButton removeFromSuperview];
            startButton = nil;
        }
        if (pauseButton) {
            [pauseButton removeFromSuperview];
            pauseButton = nil;
        }
    }
}

@end
