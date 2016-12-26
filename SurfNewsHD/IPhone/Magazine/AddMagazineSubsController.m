//
//  AddMagazineSubsController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AddMagazineSubsController.h"

#define DEFAULT_MAGAZINE_PER_PAGE  15

@interface AddMagazineSubsController ()

@end

@implementation AddMagazineSubsController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        magazines = [NSMutableArray new];
        page = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setTitle:@"添加期刊"];
    
    float toolBarH = 47.0f;
    float tvHeight = kContentHeight - [self StateBarHeight] - toolBarH;
    CGRect tViewRect = CGRectMake(0.0f, [self StateBarHeight], 320.0f, tvHeight);
    tableView = [[UITableView alloc] initWithFrame:tViewRect style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self addBottomToolsBar];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"addSubs" ofType:@"aiff"];
    //在这里判断以下是否能找到这个音乐文件
    if (path) {
        //从path路径中 加载播放器
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:path]
                                                       error:nil];
        player.numberOfLoops = 0;
        player.volume = 1.0f;
    }
    
    [PhoneNotification manuallyHideWithIndicator];
    [self getMagazineList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    isNightMode = night;
}

- (void)dismissBackController
{
    [self commitSubs];
}

- (void)didBackGestureEndHandle
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

//获取期刊列表
- (void)getMagazineList
{
    loadingMore = NO;
    
    MagazineManager *mm = [MagazineManager sharedInstance];
    [mm refreshMagazineWithPage:page
              completionHandler:^(BOOL succeeded, NSArray *array) {
                  if (succeeded) {
                      if (array) {
                          [magazines addObjectsFromArray:array];
                          //请求回来正好是15个则加上加载更多的cell
                          if ([array count] == DEFAULT_MAGAZINE_PER_PAGE) {
                              loadingMore = YES;
                          }
                          page ++;
                      } else {
                          loadingMore = NO;
                      }
                      [PhoneNotification hideNotification];
                  } else { //网络请求失败时,如果之前有15个的倍数则还是要加上加载更多的cell
                      if ([magazines count] % DEFAULT_MAGAZINE_PER_PAGE == 0 &&
                          [magazines count] != 0) {
                          loadingMore = YES;
                      }
                      [PhoneNotification autoHideWithText:@"网络请求超时"];
                  }
                  [tableView reloadData];
              }];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    if (loadingMore) {
        return [magazines count] + 1;
    }
    return [magazines count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [magazines count]) {
        NSString *identifier = @"magazinelist_more";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.userInteractionEnabled = NO;
        }
        [cell viewNightModeChanged:isNightMode];
        return cell;
    } else {
        static NSString *CellIdentifier = @"addsubs_cell";
        AddSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[AddSubscribeCell alloc] initWithStyle:UITableViewCellStyleValue1
                                           reuseIdentifier:CellIdentifier];
            cell.delegate = self;
            cell.backgroundColor = [UIColor clearColor];
            UIView *bgView = [[UIView alloc] initWithFrame:[cell bounds]];
            bgView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
        }
        
        [cell applyTheme:isNightMode];
        [cell loadSubsInfo:[magazines objectAtIndex:indexPath.row]];
        
        return cell;
    }
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [magazines count]) {
        return 40.0f;
    }
    return 55.0f;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MagazineInfoController *controller = [[MagazineInfoController alloc] init];
    controller.magazine = [magazines objectAtIndex:indexPath.row];
    [self presentController:controller
                   animated:PresentAnimatedStateFromRight];
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 滚动到底部，自动加载更多数据
    float scrollContentHeight = scrollView.contentSize.height;
    float scrollHeight = scrollView.bounds.size.height;
    if (scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - 40.0f &&
        loadingMore) {
        [self getMagazineList];
    }
}

#pragma mark AddSubscribeCellDelegate methods
- (void)playAudioWhenAddSubs
{
    if (!player) return;
    
    if ([player isPlaying]) {
        [player stop];
    }
    player.currentTime = 0;
    [player play];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self commitSubs];
    } else if (buttonIndex == 0) {
        [[SubsChannelsManager sharedInstance] removeAllToSubs];
        [self dismissControllerAnimated:PresentAnimatedStateFromRight];
    }
}

@end
