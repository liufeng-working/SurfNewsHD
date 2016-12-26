//
//  PhoneMagazineController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneMagazineController.h"
#import "WebPeriodicalController.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"

#define TopRefreshDateSpace 15          // 15分钟刷新时间

@implementation PhoneMagazineController

- (id)init
{
    self = [super init];
    if (self) {
//        self.titleState = PhoneSurfControllerStateRoot;
        self.titleState = PhoneSurfControllerStateTop;
        refreshUpdatePeriodical = YES;
        operateIndex = NSNotFound;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"冲浪期刊";
    
    CGRect tableViewRect = CGRectMake(0.0f,
                                      [self StateBarHeight],
                                      320.0f,
                                      kContentHeight - [self StateBarHeight] - kTabBarHeight);

    guideAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    guideAddBtn.frame = CGRectMake((kContentWidth - 216.0f) / 2, (kContentHeight - [self StateBarHeight] - 76.0f) / 2, 216.0f, 76.0f);
    [guideAddBtn setBackgroundImage:[UIImage imageNamed:@"add_magazine_guide.png"] forState:UIControlStateNormal];
    [guideAddBtn addTarget:self action:@selector(addMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:guideAddBtn];
    
    magazineTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    [magazineTableView setDataSource:self];
    [magazineTableView setDelegate:self];
    magazineTableView.backgroundColor = [UIColor clearColor];
    [magazineTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:magazineTableView];
    
    CGRect topRect = magazineTableView.frame;
    topRect.origin.y = - topRect.size.height;
    topLoading = [[LoadingView alloc] initWithFrame:topRect atTop:YES];
    [topLoading setStyle:StateDescriptionTableStyleTop];
    [magazineTableView addSubview:topLoading];
    
    float addBtnW = 45.f, addBtnH = 45.f, lineH = 30.0f;
    verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(kContentWidth - addBtnW, (self.StateBarHeight - lineH) * 0.5, 1.0f, lineH)];
    [self.view addSubview:verticalLineView];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setFrame:CGRectMake(kContentWidth - addBtnW, 0.0f, addBtnW, addBtnH)];
    if (IOS7) {
        [addBtn setFrame:CGRectMake(kContentWidth - addBtnW, 15.0f, addBtnW, addBtnH)];
        verticalLineView.frame = CGRectMake(kContentWidth - addBtnW, (self.StateBarHeight - lineH) * 0.5+5, 1.0f, lineH);
    }
    [addBtn setBackgroundImage:[UIImage imageNamed:@"navAddBtn.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    MagazineManager *mm = [MagazineManager sharedInstance];
    [mm addMagazineObserver:self];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, 65.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    
    addMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreButton.frame = CGRectMake(10.0f, 15.0f, 300.0f, 35.0f);
    [addMoreButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [addMoreButton setTitle:@"+订阅更多期刊" forState:UIControlStateNormal];
    [addMoreButton addTarget:self action:@selector(addMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addMoreButton];
    
    magazineTableView.tableFooterView = footerView;
    
    //加载本地数据
    for (MagazineSubsInfo *magazine in [MagazineManager sharedInstance].subsMagazines) {
        //获取本地的更新期刊信息
        UpdatePeriodicalInfo *pe = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfUpdatePeriodicalInfoWithMagazineId:magazine.magazineId] encoding:NSUTF8StringEncoding error:nil] AsType:[UpdatePeriodicalInfo class]];
        if (pe) {
            magazine.lastUpdatePeriodicalInfo = pe;
        }
    }
    [magazineTableView reloadData];
    
    
    // 添加底部状态栏
    [self addBottomToolsBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //检查刷新时间是否超过15分钟
    MagazineManager *mm = [MagazineManager sharedInstance];
    NSDate *lastDate = [mm lastDateOfMagazineUpdate];
    BOOL isLoading = (lastDate==nil) ? YES : NO;
    if (!isLoading) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
        NSDateComponents *dateComponents = [calendar components:flags
                                                       fromDate:lastDate
                                                         toDate:[NSDate date] options:0];
        if (dateComponents.minute > TopRefreshDateSpace || dateComponents.hour != 0 ||
            dateComponents.day != 0 || dateComponents.month != 0 || dateComponents.year != 0 ) {
            isLoading = YES;
        }
    }
    
    //SYZ -- 2014/08/11
    //这里有三种情况
    //1.应用首次启动，期刊订阅关系刷新时间间隔 < TopRefreshDateSpace，加载本地数据并刷新更新的期刊信息
    //2.应用非首次启动，进入期刊tab页，只加载本地期刊
    //3.不管是否首次启动，期刊订阅关系刷新时间间隔 > TopRefreshDateSpace
    if (isLoading) {  //情况3
        topLoading.loading = YES;
        topLoading.state = kPRStateLoading;
        magazineTableView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        magazineTableView.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
        
        [self refreshMagazinesList];
    } else {
        if (refreshUpdatePeriodical) {  //情况1
            [self getUpdatePeriodical];
            refreshUpdatePeriodical = NO;
        }
    }
    
    //刷新未读数刷新
    if (operateIndex != NSNotFound) {
        NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:operateIndex inSection:0];
        NSArray *array = [NSArray arrayWithObject:reloadIndexPath];
        [magazineTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        operateIndex = NSNotFound;
    }
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    [topLoading viewNightModeChanged:night];
    [magazineTableView viewNightModeChanged:night];
    
    if (night) {
        magazineTableView.backgroundColor = [UIColor colorWithHexValue:0xFF242526];
        addMoreButton.backgroundColor = [UIColor colorWithHexValue:0xFF3C3D3E];
        [addMoreButton setTitleColor:[UIColor colorWithHexValue:0xFFFFFFFF] forState:UIControlStateNormal];
        verticalLineView.backgroundColor = [UIColor colorWithHexString:@"19191A"];
    } else {
        magazineTableView.backgroundColor = [UIColor clearColor];
        addMoreButton.backgroundColor = [UIColor colorWithHexValue:0xFFFFFFFF];
        [addMoreButton setTitleColor:[UIColor colorWithHexValue:0xFF999292] forState:UIControlStateNormal];
        verticalLineView.backgroundColor = [UIColor colorWithHexString:@"DCDBDB"];
    }
    
    NSArray *cells = [magazineTableView visibleCells];
    
    for (UITableViewCell *tCell in cells) {
        PhoneMagazineCell *cell = (PhoneMagazineCell*)tCell;
        [cell applyTheme];
    }
}

//添加订阅
- (void)addMagazineSubs:(id)sender
{
    AddMagazineSubsController *controller = [[AddMagazineSubsController alloc] init];
    [self presentController:controller
                   animated:PresentAnimatedStateFromRight];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //没有期刊订阅的时候,显示添加按钮 SYZ -- 2014/08/11
    NSInteger count = [[MagazineManager sharedInstance].subsMagazines count];
    guideAddBtn.hidden = (count > 0);
    tableView.hidden = !guideAddBtn.hidden;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"subsMagazine_cell";
    PhoneMagazineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PhoneMagazineCell alloc] initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    
    MagazineSubsInfo *magazine = [[MagazineManager sharedInstance].subsMagazines objectAtIndex:indexPath.row];

    [cell loadUpdatePeriodicalInfo:magazine.lastUpdatePeriodicalInfo];
    [cell applyTheme];
    
    return cell;
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagazineSubsInfo *magazine = [[MagazineManager sharedInstance].subsMagazines objectAtIndex:indexPath.row];
    UpdatePeriodicalInfo *up = (UpdatePeriodicalInfo *)magazine.lastUpdatePeriodicalInfo;
    PeriodicalHeadInfo *head;
    if (up && [up.periods count] > 0) {
        PeriodicalInfo *info = up.periods[0];
        head = (PeriodicalHeadInfo *)info.head;
    }
    NSArray *content = head.contentTitle;
    if (![head.iconViewPath isEmptyOrBlank] && head.iconViewPath) {
        if (content.count == 0) {
            return CellHeightWithImage + CellShadowHeight + CellSpace - 90.0f;
        } else if (content.count == 1) {
            return CellHeightWithImage + CellShadowHeight + CellSpace - 54.0f;
        } else if (content.count == 2) {
            return CellHeightWithImage + CellShadowHeight + CellSpace - 27.0f;
        } else if (content.count >= 3) {
            return CellHeightWithImage + CellShadowHeight + CellSpace;
        }
    } else {
        if (content.count == 0) { //这里的第一个标题有5个像素的偏差
            return CellHeightNoImage + CellShadowHeight + CellSpace - 95.0f;
        } else if (content.count == 1) {
            return CellHeightNoImage + CellShadowHeight + CellSpace - 54.0f;
        } else if (content.count == 2) {
            return CellHeightNoImage + CellShadowHeight + CellSpace - 27.0f;
        } else if (content.count >= 3) {
            return CellHeightNoImage + CellShadowHeight + CellSpace;
        }
    }
    return CellSpace;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MagazineSubsInfo *magazine = [[MagazineManager sharedInstance].subsMagazines objectAtIndex:indexPath.row];
//    UpdatePeriodicalInfo *up = magazine.lastUpdatePeriodicalInfo;
//    PeriodicalInfo *info;
//    if (up && up.periods) {
//        info = up.periods[0];
//        info.magazineId = up.magazineId;
//    }
//    WebPeriodicalController *viewController = [[WebPeriodicalController alloc] init];
//    viewController.periodicalInfo = info;
//    [self presentController:viewController animated:PresentAnimatedStateFromBottom];
}

// 改变offset 都会回调这个函数，
// 这里改变headerView和FooterView状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (topLoading.state == kPRStateLoading) {
        return;
    }
    
    CGPoint offset = scrollView.contentOffset;
    //    CGSize size = scrollView.frame.size;
    //    CGSize contentSize = scrollView.contentSize;
    
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        topLoading.state = kPRStatePulling;
    }
    else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){ //header part appeared
        topLoading.state = kPRStateLocalDisplay;
    }
}

// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (topLoading.state == kPRStateLoading) {
        return;
    }
    
    // headerView 状态是拉伸状态
    if (topLoading.state == kPRStatePulling) {
        // 下啦刷新
        topLoading.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            //刷新操作
            [self refreshMagazinesList];
        }];
    }
    else if(topLoading.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
        } completion:^(BOOL finished) {
            topLoading.state = kPRStateNormal;
        }];
    }
}

#pragma mark PhoneMagazineCellDelegate methods
- (void)tableViewRowSelected:(MagazineSubsInfo *)magazine
{
    PastPeriodicalController *controller = [[PastPeriodicalController alloc] init];
    controller.magazine = magazine;
    [self presentController:controller
                   animated:PresentAnimatedStateFromRight];
}

- (void)readPeriodicalContent:(MagazineSubsInfo *)magazine
{
    UpdatePeriodicalInfo *up = magazine.lastUpdatePeriodicalInfo;
    PeriodicalInfo *info;
    if (up && up.periods) {
        info = up.periods[0];
        info.magazineId = up.magazineId;
    }
    WebPeriodicalController *viewController = [[WebPeriodicalController alloc] init];
    viewController.periodicalInfo = info;
    [self presentController:viewController
                   animated:PresentAnimatedStateFromRight];
}

- (void)resetCellViewFrame
{
    NSArray *cells = [magazineTableView visibleCells];
    for (UITableViewCell *tCell in cells) {
        PhoneMagazineCell *cell = (PhoneMagazineCell*)tCell;
        [cell resetViewFrame];
    }
}

- (void)setReloadMode:(ReloadMode)mode atIndex:(NSInteger)index
{
    reloadMode = mode;
    operateIndex = index;
}

#pragma mark SubsMagazineChangedObserver methods
- (void)subsMagazineChanged
{
    //SYZ -- 2014/08/11
    //涉及到订阅关系改变的时候都会调用此方法
    //所以用ReloadMode来区别删除和置顶,可以对操作的NSIndexPath进行单独操作
    if (reloadMode == ReloadDelete) {
        NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:operateIndex inSection:0];
        NSArray *array = [NSArray arrayWithObject:deleteIndexPath];
        [magazineTableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        reloadMode = ReloadNormal;
        operateIndex = NSNotFound;
        return;
    } else if (reloadMode == ReloadSetTop) {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *operateIndexPath = [NSIndexPath indexPathForRow:operateIndex inSection:0];
        [magazineTableView moveRowAtIndexPath:operateIndexPath toIndexPath:firstIndexPath];
        reloadMode = ReloadNormal;
        operateIndex = NSNotFound;
        return;
    }
    // 下拉刷新
    if (topLoading.isLoading)
    {
        topLoading.loading = NO;
        [topLoading setState:kPRStateNormal animated:YES];
        [UIView animateWithDuration:kUpDownUpdateDuration * 2
                              delay:0.3f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
                        {
                             [magazineTableView setContentInset:UIEdgeInsetsZero];
                        }
                         completion:^(BOOL finished)
                        {
                             [self getUpdatePeriodical];
                             [topLoading updateRefreshDate:[[MagazineManager sharedInstance] lastDateOfMagazineUpdate]];
                         }];
    }
    else{
        [self getUpdatePeriodical];
//        [magazineTableView setContentOffset:CGPointZero animated:YES];// 这个是用来滚动到顶部
    }
}

//刷新期刊列表
- (void)refreshMagazinesList
{
    MagazineManager *mm = [MagazineManager sharedInstance];
    [topLoading updateRefreshDate:[mm lastDateOfMagazineUpdate]];
    
    [mm refreshMagazinesWithCompletionHandler:^(BOOL success, BOOL channgeUI) {
        if (channgeUI) {
            [self subsMagazineChanged];
        } else {
            if (topLoading.isLoading) {
                topLoading.loading = NO;
                [topLoading setState:kPRStateNormal animated:YES];
                [UIView animateWithDuration:kUpDownUpdateDuration * 2
                                      delay:0.3f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{ [magazineTableView setContentInset:UIEdgeInsetsZero];}
                                 completion:^(BOOL finished) {
                                     [topLoading updateRefreshDate:[mm lastDateOfMagazineUpdate]];
                                 }];
            }
        }
    }];
}

- (void)getUpdatePeriodical
{
    [[MagazineManager sharedInstance] getUpdatePeriodicalListCompletionHandler:^(BOOL success, BOOL changeUI) {
        [magazineTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    MagazineManager *mm = [MagazineManager sharedInstance];
    [mm removeMagazineObserver:self];
}

@end
