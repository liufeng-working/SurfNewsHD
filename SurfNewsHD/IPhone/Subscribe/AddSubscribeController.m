//
//  AddSubscribeController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AddSubscribeController.h"

@implementation CategoryViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellBg = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 40.0f)];
        [self.contentView addSubview:cellBg];
        
        categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 38.0f)];
        categoryLabel.font = [UIFont systemFontOfSize:18.0f];
        [categoryLabel setTextAlignment:NSTextAlignmentCenter];
        categoryLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:categoryLabel];
        
        divideLine = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 38.0f, 75.0f, 2.0f)];
        [self.contentView addSubview:divideLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        if (isNightMode) {
            cellBg.backgroundColor = [UIColor colorWithHexString:@"2D2E2F"];
        } else {
            cellBg.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
        }
        categoryLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
        categoryLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    } else {
        if (isNightMode) {
            categoryLabel.textColor = [UIColor whiteColor];
        } else {
            categoryLabel.textColor = [UIColor colorWithHexString:@"34393D"];
        }
        cellBg.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont systemFontOfSize:18.0f];
    }
}

- (void)loadCategory:(NSString*)cate
{
    categoryLabel.text = cate;
}

- (void)applyTheme:(BOOL)isNight
{
    isNightMode = isNight;
    
    if (isNightMode) {
        categoryLabel.textColor = [UIColor whiteColor];
        divideLine.image = [UIImage imageNamed:@"category_divider_night.png"];
    } else {
        categoryLabel.textColor = [UIColor colorWithHexString:@"34393D"];
        divideLine.image = [UIImage imageNamed:@"category_divider.png"];
    }
}

@end

@implementation AddSubscribeController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        _catesArray = [NSMutableArray new];
        currentIndexPath = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"添加订阅";
    
    float cateTableViewWidth = 75.0f;
    float searchBoxViewHeight = 45.0f;
    float tvHeight = kContentHeight - [self StateBarHeight] - searchBoxViewHeight;
    
    searchBoxControl = [[SearchBoxControl alloc] initWithFrame:CGRectMake(10.0f, [self StateBarHeight] + 5.0f, kContentWidth - 20.0f, 35.0f) tipString:@"请输入栏目名称"];
    [searchBoxControl addTarget:self action:@selector(beginSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBoxControl];
    
    CGRect cateTVRect = CGRectMake(0.0f, [self StateBarHeight] + searchBoxViewHeight,
                                   cateTableViewWidth, tvHeight);
    cateTableViewBg = [[UIImageView alloc] initWithFrame:cateTVRect];
    cateTableViewBg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    cateTableView = [[UITableView alloc] initWithFrame:cateTVRect];
    [cateTableView setDataSource:self];
    [cateTableView setDelegate:self];
    [cateTableView setBackgroundView:cateTableViewBg];
    [cateTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cateTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:cateTableView];
    
    CGRect subsViewRect = CGRectMake(cateTableViewWidth, [self StateBarHeight] + searchBoxViewHeight,
                                     kContentWidth - cateTableViewWidth, tvHeight);
    subscribeView = [[AddSubscribeView alloc] initWithFrame:subsViewRect];
    subscribeView.delegate = self;
    subscribeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:subscribeView];
    
    [self loadCategories];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //SYZ -- 2014/08/11 这里要注意上次选择的分类
    if (currentIndexPath) {
        CategoryItem *item = [_catesArray objectAtIndex:currentIndexPath.row];
        [subscribeView loadSubsCate:item.channels];
        
        UITableViewCell *cell = [cateTableView cellForRowAtIndexPath:currentIndexPath];
        CategoryViewCell *cateCell = (CategoryViewCell*)cell;
        [cateCell setSelected:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //防止有风火轮
    [PhoneNotification hideNotification];
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    isNightMode = night;
    
    [searchBoxControl setNeedsDisplay];
    [subscribeView applyTheme:isNightMode];
    
    if (isNightMode) {
        UIImage *image = [UIImage imageNamed:@"category_bg_night.png"];
        [cateTableViewBg setImage:[image stretchableImageWithLeftCapWidth:0.0f topCapHeight:25.0f]];
    } else {
        UIImage *image = [UIImage imageNamed:@"category_bg.png"];
        [cateTableViewBg setImage:[image stretchableImageWithLeftCapWidth:0.0f topCapHeight:25.0f]];
    }
}

- (void)dismissBackController
{
    [self commitSubs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didBackGestureEndHandle
{
    [self commitSubs];
}

//提交栏目订阅
- (void)commitSubs
{
    if ([[SubsChannelsManager sharedInstance] hasChannelToSubs]) {
        // 弹出风火轮
        [PhoneNotification manuallyHideWithText:@"提交订阅关系" indicator:YES];
        [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
            [PhoneNotification hideNotification];
            if (succeeded) {
                [PhoneNotification autoHideWithText:@"操作成功"];
                [self dismissControllerAnimated:PresentAnimatedStateFromRight];
            } else {
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

//加载分类
-(void)loadCategories
{
    [PhoneNotification manuallyHideWithIndicator];
    
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    [manager refreshCategoriesWithCompletionHandler:^(NSArray* cates) {
        if (cates) {
            for(CategoryItem *item in cates){
                item.channelCurrentPage = 1;    //默认设为1
                [_catesArray addObject:item];
            }
            [cateTableView reloadData];
            
            //加载分类之后默认选择第一个
            currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [cateTableView cellForRowAtIndexPath:currentIndexPath];
            CategoryViewCell *cateCell = (CategoryViewCell*)cell;
            [cateCell setSelected:YES];
            selectItem = [_catesArray objectAtIndex:0];
            [self loadSubsChannelsOfCategory:selectItem];
        } else {
            [PhoneNotification autoHideWithText:@"获取订阅列表失败"];
        }
    }];
}

//获取分类下的订阅栏目
-(void)loadSubsChannelsOfCategory:(CategoryItem *)category
{
    if (isLoadingMore) {
        return;
    }
    isLoadingMore = YES;
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    [manager loadSubsChannelsOfCategory:category.cateId page:category.channelCurrentPage withCompletionHandler:^(NSArray* cates) {
        if (cates) {
            if(category.channels == nil) {
                category.channels = [NSMutableArray new];
            }
            [category.channels addObjectsFromArray:cates];
            category.channelCurrentPage++;
        }
        isLoadingMore = NO;
        [subscribeView loadSubsCate:category.channels];
        [PhoneNotification hideNotification];
     }];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return [_catesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sort_cell";
    CategoryViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CategoryViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell applyTheme:isNightMode];
    CategoryItem *item = [_catesArray objectAtIndex:indexPath.row];
    [cell loadCategory:item.name];
    
    return cell;
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //先将之前的cell设定为不选择
    UITableViewCell *oldCell = [cateTableView cellForRowAtIndexPath:currentIndexPath];
    CategoryViewCell *oldCateCell = (CategoryViewCell*)oldCell;
    [oldCateCell setSelected:NO];
    
    currentIndexPath = indexPath;
    UITableViewCell *cell = [cateTableView cellForRowAtIndexPath:indexPath];
    CategoryViewCell *cateCell = (CategoryViewCell*)cell;
    [cateCell setSelected:YES];
    
    selectItem = [_catesArray objectAtIndex:currentIndexPath.row];
    [self loadSubsChannelsOfCategory:selectItem];
}

#pragma mark AddSubscribeViewDelegate methods
- (void)channelSelected:(SubsChannel *)channel
{
    SubsChannelSummaryViewController *summaryController = [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummarySubs];
    [summaryController setSubsChannel:channel];
    [self presentController:summaryController animated:PresentAnimatedStateFromRight];
}

- (void)loadMore
{
    [self loadSubsChannelsOfCategory:selectItem];
}

- (void)beginSearch
{
    void (^layoutBlock)(void) = ^{
        /*
        [UIView animateWithDuration:0.5f animations:^{
            self.view.frame = CGRectMake(0.0f, -25.0f,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height + 45.0f);
            self.view.alpha = 0.2f;
        } completion:^(BOOL finished) {
            self.view.alpha = 1.0f;
            self.view.frame = CGRectMake(0.0f, 20.0f,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height - 45.0f);
            
        }];
         */
        SearchChannelController *controller = [[SearchChannelController alloc] init];
        controller.allChannelsArray = allChannelsArray;
        [self presentController:controller
                       animated:PresentAnimatedStateFromRight];
    };
    
    //SYZ -- 2014/08/11数据准备完成则直接进入搜索界面,否则要先准备数据
    if (allChannelsArray) {
        layoutBlock();
    } else {
        [PhoneNotification manuallyHideWithIndicator];
        allChannelsArray = [NSMutableArray new];
        
        SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
        if (_catesArray.count == 0) {
            [allChannelsArray removeAllObjects];
            allChannelsArray = nil;
            [PhoneNotification autoHideWithText:@"加载数据失败,请重试"];
            return;
        }
        
        __block NSInteger i = 0;
        for (CategoryItem *item in _catesArray) {
            //SYZ -- 2014/08/11 这里page的值为1的原因是,要满足本地搜索的需求,加载了一部分的RSS频道供用户本地搜索
            [manager loadSubsChannelsOfCategory:item.cateId page:1 withCompletionHandler:^(NSArray* cates) {
                if (cates) {
                    [allChannelsArray addObjectsFromArray:cates];
                    i++;
                    if (i == _catesArray.count) {
                        [PhoneNotification hideNotification];
                        layoutBlock();
                    }
                } else {
                    [allChannelsArray removeAllObjects];
                    allChannelsArray = nil;
                    [PhoneNotification autoHideWithText:@"加载数据失败,请重试"];
                    return;
                }
            }];
        }
    }
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
