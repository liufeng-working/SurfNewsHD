//
//  PastPeriodicalController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PastPeriodicalController.h"
#import "EzJsonParser.h"
#import "NotificationManager.h"

@interface PastPeriodicalController ()

@end

@implementation PastPeriodicalController

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
    
    self.title = _magazine.name;
    
    float titleViewH = 30.0f;
    titleView = [[PastPeriodicalTitle alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight, kContentWidth, titleViewH)];
    [self.view addSubview:titleView];
    
    CGRect tableViewRect = CGRectMake(0.0f, [self StateBarHeight] + titleViewH, kContentWidth, kContentHeight - [self StateBarHeight] - titleViewH);
    periodicalTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    [periodicalTableView setDataSource:self];
    [periodicalTableView setDelegate:self];
    [periodicalTableView setBackgroundColor:[UIColor clearColor]];
    [periodicalTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:periodicalTableView];
    
    UIView *bottomToolsBar = [self addBottomToolsBar];
    
    //加一个空的footerView,以便在拖到最后一行时能完整显示最后一行
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.0f, kContentWidth, bottomToolsBar.frame.size.height)];
    periodicalTableView.tableFooterView = footerView;
    
    [self loadPastPeriodicalData];
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    isNightMode = night;
    [titleView applyTheme:night];
}

//返回按钮点击事件
-(void)dismissBackController
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

//加载所有的往期期刊
- (void)loadPastPeriodicalData
{
    [PhoneNotification manuallyHideWithIndicator];
    MagazineManager *mm = [MagazineManager sharedInstance];
    [mm refreshPeriodicalsWithMagazineId:_magazine.magazineId 
                       completionHandler:^(BOOL succeeded, BOOL changeUI, NSArray *array) {
                           [PhoneNotification hideNotification];
                           if (succeeded) {
                               [self groupedArray:array];
                               [periodicalTableView reloadData];
                           }
                       }];
}

//将往期期刊2期分为一组 SYZ -- 2014/08/11
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"past_cell";
    PastPeriodicalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PastPeriodicalCell alloc] initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell loadPastPeriodical:[groupArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark PastPeriodicalCellDelegate methods
- (void)readPeriodicalContent:(PeriodicalInfo *)periodical
{
    //如果是新期刊,点击过后置为不是新期刊,覆盖期刊对应的txt SYZ -- 2014/08/11
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
