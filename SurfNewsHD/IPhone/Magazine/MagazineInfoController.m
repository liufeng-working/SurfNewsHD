//
//  MagazineInfoController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MagazineInfoController.h"
#import "EzJsonParser.h"

@implementation MagazineInfoController

#define InfoViewHeight          80

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        
        groupArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = _magazine.magazineName;
    
    CGRect tableViewRect = CGRectMake(0.0f, [self StateBarHeight], kContentWidth, kContentHeight - [self StateBarHeight]);
    tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    infoView = [[MagazineInfoView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, InfoViewHeight)];
    infoView.backgroundColor = [UIColor clearColor];
    [infoView loadMagazineInfo:_magazine];
    tableView.tableHeaderView = infoView;
    
    //加一个空的footerView,以便在拖到最后一行时能完整显示最后一行
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.0f, kContentWidth, [self addBottomToolsBar].frame.size.height)];
    tableView.tableFooterView = footerView;
    
    //往期期刊
    titleView = [[PastPeriodicalTitle alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, 30.0f)];
    
    [self loadPastPeriodical];
}

//在返回的时候提提交订阅
- (void)dismissBackController
{
    [self commitSubs];
}

//提交订阅
- (void)commitSubs
{
    if ([[SubsChannelsManager sharedInstance] hasMagazineToSubs]) {
        // 弹出风火轮
        [PhoneNotification manuallyHideWithText:@"提交订阅关系" indicator:YES];
        [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
            [PhoneNotification hideNotification];
            if (succeeded) {
                [PhoneNotification autoHideWithText:@"操作成功"];
                [self dismissControllerAnimated:PresentAnimatedStateFromRight];
            } else {
                [PhoneNotification hideNotification];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交订阅失败，是否重试？"
                                                                    message:@""
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"重试",nil];
                [alertView show];
            }
        }];
    } else {
        [self dismissControllerAnimated:PresentAnimatedStateFromRight];
    }
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    isNightMode = night;
    [infoView applyTheme:isNightMode];
}

//加载所有的往期期刊
- (void)loadPastPeriodical
{
    MagazineManager *mm = [MagazineManager sharedInstance];
    [mm refreshPeriodicalsWithMagazineId:_magazine.magazineId
                       completionHandler:^(BOOL succeeded, BOOL changeUI, NSArray *array) {
                           if (succeeded) {
                               [self groupedArray:array];
                               [tableView reloadData];
                           }
                       }];
}

//SYZ -- 2014/08/11 将往期期刊2期分为一组
- (void)groupedArray:(NSArray *)array
{
    [groupArray removeAllObjects];
    for (NSInteger i = 0; i < [array count]; i++) {
        if (i % 2 == 0) {
            NSInteger grouped = i + 1;
            NSMutableArray *tripleArray = [NSMutableArray new];
            for (NSInteger x = grouped; x >=i ; x--) {
                if ([array count] <= grouped) {
                    grouped--;
                }
            }
            for (NSInteger y = i; y <= grouped; y++) {
                [tripleArray addObject:[array objectAtIndex:y]];
            }
            [groupArray addObject:tripleArray];
        }
    }
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return [groupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"introduction_cell";
        UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:titleView];
        }
        [titleView applyTheme:isNightMode];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"pastperiodical_cell";
        PastPeriodicalCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[PastPeriodicalCell alloc] initWithStyle:UITableViewCellStyleValue1
                                             reuseIdentifier:CellIdentifier];
            cell.delegate = self;
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell loadPastPeriodical:[groupArray objectAtIndex:indexPath.row]];
        
        return cell;
    }
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 30.0f;
    }
    return 190.0f;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark PhoneMagazineCellDelegate methods
- (void)readPeriodicalContent:(PeriodicalInfo *)periodical
{
    //SYZ -- 2014/08/11 如果是新期刊,点击过后置为不是新期刊,覆盖期刊对应的txt
    if (periodical.isNew == 1) {
        periodical.isNew = 0;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *periodicalDir = [PathUtil pathOfPeriodical:periodical];
        [fm createDirectoryAtPath:periodicalDir withIntermediateDirectories:YES attributes:nil error:nil];
        [[EzJsonParser serializeObjectWithUtf8Encoding:periodical] writeToFile:[PathUtil pathOfPeriodicalInfo:periodical] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    WebPeriodicalController *viewController = [[WebPeriodicalController alloc] init];
    viewController.periodicalInfo = periodical;
    [self presentController:viewController
                   animated:PresentAnimatedStateFromRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
