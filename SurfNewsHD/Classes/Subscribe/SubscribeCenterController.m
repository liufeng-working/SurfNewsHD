 //
//  SubscribeRootController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubscribeCenterController.h"
#import "SubscribeViewController.h"
#import "NSString+Extensions.h"

@implementation SearchSubscribeView

@synthesize searchField;

- (id)initWithFrame:(CGRect)frame controller:(id)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *searchBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 39.0f, kContentWidth, 66.0f)];
        searchBackground.image = [UIImage imageNamed:@"search_subs_bg"];
        [self addSubview:searchBackground];
        
        UIButton *cancelSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelSearchButton setFrame:CGRectMake(20.0f, 45.0f, 30.0f, 40.0f)];
        [cancelSearchButton setBackgroundImage:[UIImage imageNamed:@"cancle_search_subs"] forState:UIControlStateNormal];
        [cancelSearchButton addTarget:controller action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelSearchButton];
        
        UIImageView *searchFieldBackground = [[UIImageView alloc] initWithFrame:CGRectMake(70.0f, 45.0f, 605.0f, 40.0f)];
        UIImage *searchFieldImage = [UIImage imageNamed:@"input_view"];
        searchFieldBackground.image = [searchFieldImage stretchableImageWithLeftCapWidth:30.0f topCapHeight:0.0f];
        [self addSubview:searchFieldBackground];
        
        searchField = [[UITextField alloc] initWithFrame:CGRectMake(80.0f, 45.0f, 595.0f, 40.0f)];
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        searchField.returnKeyType = UIKeyboardTypeDefault;
        searchField.placeholder = @"搜索订阅";
        searchField.backgroundColor = [UIColor clearColor];
        [self addSubview:searchField];
        
        UIButton *doSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doSearchButton setFrame:CGRectMake(700.0f, 43.0f, 125.0f, 43.0f)];
        [doSearchButton setTitle:@"搜索" forState:UIControlStateNormal];
        [doSearchButton setBackgroundImage:[UIImage imageNamed:@"public_popup_button"]
                                  forState:UIControlStateNormal];
        [doSearchButton addTarget:controller action:@selector(doSearchSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        [doSearchButton setTitleColor:[UIColor hexChangeFloat:@"6f5639"]
                             forState:UIControlStateNormal];
        [doSearchButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [doSearchButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doSearchButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [self addSubview:doSearchButton];
    }
    return self;
}

@end

@implementation SubscribeCenterController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        subsChannels = [[NSMutableArray alloc] init];
        currentShowCategory = NSNotFound;
        
        self.titleState = ViewTitleStateSpecial;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [gridView reloadView];
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(0.0f, 0.0f, kContentWidth, 748.0f);
    
    ///**我的订阅view开始
    gridView = [[SubscribeChannelGridView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, kContentWidth, 739.0f)];
    gridView.delegate = self;
    gridView.dataSource = self;
    gridView.widthOfView = self.view.frame.size.width;
    gridView.cellHorizontalSpacing = 25.0f;
    gridView.cellVerticalSpacing = 10.0f;
    gridView.edgeInsets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 10.0f);
    gridView.widthOfView = kContentWidth;
    gridView.hidden = YES;
    [self.view addSubview:gridView];
    
    [gridView addObserver:self
               forKeyPath:@"heightOfView"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    //*/我的订阅view结束
    
    ///**搜索订阅view开始
    searchView = [[SearchSubscribeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 900.0f, 105.0f)
                                                 controller:self];
    searchView.hidden = YES;
    [self.view addSubview:searchView];
    //*/搜索订阅view结束
    
    ///**中间的view开始
    subscribView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 900.0f, 748.0f)];
    [self.view addSubview:subscribView];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subscribe_center_bg"]];
    imageView.frame = CGRectMake(0.0f, 34.0f, 900.0f, 714.0f);
    [subscribView addSubview:imageView];
    
    UIView *titleLineTopView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 39.0f, kContentWidth, 5)];
    titleLineTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hotchannel_item_border"]];
    [subscribView addSubview:titleLineTopView];
    
    {
        CGRect btnCtrlRect = CGRectMake(10.0f, 44.0f, 75.0f, 40.0f);
        UIControl *btnCtrl = [[UIControl alloc] initWithFrame:btnCtrlRect];    
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(14.f, 0, 3.f, 10.f)];
        [line setBackgroundColor:[UIColor blackColor]];
        [btnCtrl addSubview:line];
        
        refreshImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh"]];
        [refreshImage setFrame:CGRectMake(0, 10.f, 30.f, 30.f)];
        [btnCtrl addSubview:refreshImage];
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(30.f, 10.f, 45.0f, 30.0)];
        [text setTextAlignment:NSTextAlignmentRight];
        [text setText:@"刷新"];
        [text setTextColor:[UIColor blackColor]];
        [text setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [text setBackgroundColor:[UIColor clearColor]];
        [btnCtrl addSubview:text];
        
        [btnCtrl addTarget:self action:@selector(refreshSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        [subscribView addSubview:btnCtrl];
    
    }
    
    
//    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [refreshButton setImage:[UIImage imageNamed:@"refresh_subscribe_button"] forState:UIControlStateNormal];
//    [refreshButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 45.0f)];
//    [refreshButton setTitleEdgeInsets:UIEdgeInsetsMake(9.0f, 0.0f, 0.0f, 0.0f)];
//    [refreshButton setFrame:CGRectMake(10.0f, 44.0f, 75.0f, 40.0f)];
//    [refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
//    [refreshButton addTarget:self action:@selector(refreshSubscribe:) forControlEvents:UIControlEventTouchUpInside];
//    [refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    refreshButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
//    [subscribView addSubview:refreshButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"search_subscribe_button"] forState:UIControlStateNormal];
    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 45.0f)];
    [searchButton setTitleEdgeInsets:UIEdgeInsetsMake(9.0f, 0.0f, 0.0f, 0.0f)];
    [searchButton setFrame:CGRectMake(650.0f, 44.0f, 75.0f, 40.0f)];
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchSubscribe:) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [subscribView addSubview:searchButton];
    
    UIButton *mySubscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mySubscribeButton setImage:[UIImage imageNamed:@"my_subscribe_button"] forState:UIControlStateNormal];
    [mySubscribeButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 82.0f)];
    [mySubscribeButton setTitleEdgeInsets:UIEdgeInsetsMake(9.0f, 0.0f, 0.0f, 0.0f)];
    [mySubscribeButton setFrame:CGRectMake(745.0f, 44.0f, 112.0f, 40.0f)];
    [mySubscribeButton setTitle:@"订阅管理" forState:UIControlStateNormal];
    [mySubscribeButton addTarget:self action:@selector(mySubscribe:) forControlEvents:UIControlEventTouchUpInside];
    [mySubscribeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    mySubscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [subscribView addSubview:mySubscribeButton];
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, kPaperTopY + 13.0f, self.view.frame.size.width, self.view.frame.size.height- kPaperTopY - kPaperBottomY - 13.0f)];
    tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableview.dataSource = self;
    tableview.delegate = self;
    tableview.backgroundColor = [UIColor clearColor];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [subscribView addSubview:tableview];
    //*/中间的view结束
    
    ///**搜索时的背景view
    searchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 34.0f, kContentWidth, 714.0f)];
    searchBackgroundView.alpha = 0.0f;
    [searchBackgroundView setBackgroundColor:[UIColor hexChangeFloat:@"E1DDD1"]];
    [self.view addSubview:searchBackgroundView];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(singleTapDetected:)];
    [searchBackgroundView addGestureRecognizer:tapRecognizer];
    
    searchResultView = [[SearchResultView alloc] initWithFrame: CGRectMake(0.0f, 105.0f, kContentWidth, kContentHeight-kPaperBottomY - 105.0f)];
    searchResultView.hidden = YES;
    [searchResultView setDelegate:self];
    [self.view addSubview:searchResultView];
    
    [self loadCategories];
    
    UIColor *bgColor = [UIColor colorWithHexValue:0xD8e1ddd1];
    shadowHead = [[UIControl alloc] init];
    shadowHead.backgroundColor = bgColor;
    [shadowHead setHidden:YES];
    [shadowHead addTarget:self action:@selector(maskClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shadowHead];
    
    shadowFoot = [[UIControl alloc] init];
    shadowFoot.backgroundColor = bgColor;
    [shadowFoot setHidden:YES];
    [shadowFoot addTarget:self action:@selector(maskClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shadowFoot];
    
    
    imgPool = [SubscribeImagePool sharedInstance];
    [imgPool setDelegate:self];
    
    // 订阅通知事件
    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    [scm addChannelObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//刷新订阅
- (void)refreshSubscribe:(UIControl*)control
{
    control.enabled = NO;
    NSString *animationKey = @"buttonrotationAnimation";
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1.f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = FLT_MAX;
    [refreshImage.layer addAnimation:rotationAnimation forKey:animationKey];
    
    [self refreashcategories:^{
        control.enabled = YES;        
        [refreshImage.layer removeAnimationForKey:animationKey];// 停止刷新按钮旋转
    }];
}

//搜索订阅
- (void)searchSubscribe:(UIButton*)button
{
    [searchView.searchField becomeFirstResponder];
    searchView.hidden = NO;
    subscribView.hidden = NO;
    [self.view bringSubviewToFront:searchBackgroundView];
    
    imageView.frame = CGRectMake(0.0f, 34.0f, 900.0f, 642.0f);
    searchBackgroundView.frame = CGRectMake(0.0f, 34.0f, 887.0f, 635.0f);
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         searchBackgroundView.alpha = 0.85f;
                         searchBackgroundView.frame = CGRectMake(0.0f, 105.0f, 887.0f, 635.0f);
                         subscribView.frame = CGRectMake(0.0f, 60.0f, 900.0f, 688.0f);
                     }
                     completion:^(BOOL finished) {
                         imageView.hidden = YES;
                         [self.view bringSubviewToFront:searchView];
                     }
     ];
}

//取消搜索
- (void)cancelSearch:(UIButton*)button
{
    [self cancleSearchAnimations];
}

//点击无搜索数据时的灰色背景
- (void)singleTapDetected:(UIGestureRecognizer*)sender
{
    [self cancleSearchAnimations];
}

//取消搜索的动画
- (void)cancleSearchAnimations
{
    [searchView.searchField resignFirstResponder];
    searchView.searchField.text = nil;
    
    searchResultView.hidden = YES;
    subscribView.hidden = NO;
    imageView.hidden = NO;
    [self.view bringSubviewToFront:subscribView];
    [self.view bringSubviewToFront:searchBackgroundView];

    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         searchBackgroundView.frame = CGRectMake(0.0f, 34.0f, kContentWidth, 635.0f);
                         subscribView.frame = CGRectMake(0.0f, 0.0f, 900.0f, 748.0f);
                         imageView.frame = CGRectMake(0.0f, 34.0f, 900.0f, 642.0f);
                     }
                     completion:^(BOOL finished) {
                         searchView.hidden = YES;
                         searchBackgroundView.alpha = 0.0f;
                         searchBackgroundView.frame = CGRectMake(0.0f, 34.0f, kContentWidth, 714.0f);
                         imageView.frame = CGRectMake(0.0f, 34.0f, 900.0f, 714.0f);
                         [self.view bringSubviewToFront:shadowHead];
                         [self.view bringSubviewToFront:shadowFoot];
                     }
     ];

}

//执行搜索
- (void)doSearchSubscribe:(UIButton*)button
{
    if (searchView.searchField.text == nil || [searchView.searchField.text isEmptyOrBlank]) {
        return;
    }
    
    searchResultView.hidden = NO;
    subscribView.hidden = YES;
    
    [searchView.searchField resignFirstResponder];
    [self.view bringSubviewToFront:searchResultView];
    
    NSMutableArray *allChannelsArray = [[NSMutableArray alloc] init];
    for (CategoryItem *item in subsChannels) {
        [allChannelsArray addObjectsFromArray:item.channels];
    }
    [searchResultView showSearchResutlWithSearchText:searchView.searchField.text subscribeArray:allChannelsArray];
}

//我的订阅
- (void)mySubscribe:(UIButton*)button
{
    if (!gridView.hidden) {
        return;
    }
    [gridView reloadView];
    
    gridViewShow = YES;
    gridView.hidden = NO;
    subscribView.hidden = NO;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = subscribView.frame;
                         frame.origin.y += gridView.heightOfView + 5.0f;
                         frame.size.height -= gridView.heightOfView + 5.0f;
                         subscribView.frame = frame;
//                         CGRect tableViewFrame = tableview.frame;
//                         tableViewFrame.origin.y += gridView.heightOfView + 5.0f;
//                         tableViewFrame.size.height -= gridView.heightOfView + 5.0f;
//                         tableview.frame = tableViewFrame;
                     }
                     completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:gridView];
                         imageView.hidden = YES;
                     }
     ];
}

-(void)loadCategories
{
    if ([subsChannels count] > 0 ) {
        return;
    }
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    [manager loadCategoriesWithCompletionHandler:^(NSArray* cates){
        for(CategoryItem *item  in cates){
            [subsChannels addObject:item];
            [self loadSubsChannelsOfCategory:item];
        }
        [tableview  reloadData];
    }];
    
}
- (void)refreashcategories:(void(^)())refreashComplete{
    [subsChannels removeAllObjects];
    [tableview reloadData];
    
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    [manager refreshCategoriesWithCompletionHandler:^(NSArray* cates){
        [subsChannels addObjectsFromArray:cates];
        [tableview  reloadData];
        
        
        // 加载分类数据
//        for(CategoryItem *item  in cates){
//            [self loadSubsChannelsOfCategory:item];
//        }

        
        {
            // step 1 加载屏幕中可见的数据
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:cates];
            NSArray *indexPaths = [tableview indexPathsForVisibleRows];
            for (NSIndexPath *path in indexPaths){
                if (path.row < [tempArray count]) {
                    id category = [tempArray objectAtIndex:[path row]];
                    [self loadSubsChannelsOfCategory:category];
                    [tempArray removeObject:category];
                }
            }
          
            // step 2 异步加载剩余数据
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for(CategoryItem *item  in tempArray){
                    [self loadSubsChannelsOfCategory:item];
                }
                [tempArray removeAllObjects];
            });            
        }
        
        if (refreashComplete) {
            refreashComplete();
        }
    }];

}

-(void)loadSubsChannelsOfCategory:(CategoryItem *)category
{
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    //这里要改啊!!!有分页的,可怜的iPad版,page就先用1吧!
    [manager loadSubsChannelsOfCategory:category.cateId page:1 withCompletionHandler:^(NSArray* cates)
    {
        category.channels = cates;
        int row = [subsChannels indexOfObject:category];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
        SubscribeCenterCell *cell = (SubscribeCenterCell *)[tableview cellForRowAtIndexPath:indexPath];
        if (cell != nil) {
            [cell loadData:indexPath cateItem:category isExpansion:NO];
            [self startDownloadImage:cell cellForRowAtIndexPath:indexPath];
        }        
    }];

}

#pragma mark SubscribeChannelGridViewDataSource methods
- (void)saveSubscribe
{
    if (!gridViewShow) {
        return;
    }
    gridViewShow = NO;
    
    
    [self.view bringSubviewToFront:subscribView];
    [self.view bringSubviewToFront:shadowHead];
    [self.view bringSubviewToFront:shadowFoot];
    imageView.hidden = NO;
    subscribView.hidden = NO;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         subscribView.frame = CGRectMake(0.0f, 0.0f, 900.0f, 748.0f);
                         tableview.frame = CGRectMake(0.0f, kPaperTopY + 13.0f, kContentWidth, self.view.frame.size.height- kPaperTopY - kPaperBottomY - 13.0f);
                     }
                     completion:^(BOOL finished) {
                         gridView.hidden = YES;
                         SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
                         [manager commitChangesWithHandler:^(BOOL succeeded) {
                             
                         }];

                     }
     ];
    

}

#pragma mark SubscribeChannelGridViewDataSource methods
- (NSMutableArray*)arrayOfInvisibleCell
{
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    return manager.invisibleSubsChannels;
}

- (NSMutableArray*)arrayOfVisibleCell
{
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    return manager.visibleSubsChannels;
}

- (SubscribeChannelGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath
{
    SubscribeChannelGridViewCell *cell = [[SubscribeChannelGridViewCell alloc] init];
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    //只有一个订阅的时候不显示删除按钮
    BOOL only = [manager.invisibleSubsChannels count]  + [manager.visibleSubsChannels count] == 1 ? YES : NO;
    if (indexPath.section == 0) {
        [cell setSubsChannel:[manager.invisibleSubsChannels objectAtIndex:indexPath.row] onlyOne:only];
        [cell setCellBackground:@"invisible_subs_channel" textColor:@"B4CBD3"];
    } else if (indexPath.section == 1) {
        [cell setSubsChannel:[manager.visibleSubsChannels objectAtIndex:indexPath.row] onlyOne:only];
        [cell setCellBackground:@"visible_subs_channel" textColor:@"000000"];
    }
    return cell;
}

#pragma mark - 
#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [subsChannels count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == currentShowCategory)
    {
        return [SubscribeCenterCell cellExtHeight];
    }
    else{
        return [SubscribeCenterCell cellHeight];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hotChannels_Cell";
    
    SubscribeCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    BOOL isExp = currentShowCategory==indexPath.row;
    if (cell == nil || isExp)
    {        
        cell = [[SubscribeCenterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
        [cell setImgPool:imgPool];
    }
    
    // 加载数据
    CategoryItem *item = [subsChannels objectAtIndex:indexPath.row];
    [cell loadData:indexPath cateItem:item isExpansion:isExp];
    
    
    // tableview没有拖拽和减速，做加载图片操作
    if (!tableView.dragging &&
        !tableView.decelerating &&
        item.channels.count > 0) {
        // 加载图片        
        [self startDownloadImage:cell cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) // 不减速，就加载屏幕中的图片
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows]; // 加载屏幕中的图片
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark SubscribeCenterCellDelegate
// 蒙板被点击
-(void)maskClick{
    if (currentShowCategory != NSNotFound) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:currentShowCategory inSection:0];
        SubscribeCenterCell *cell = (SubscribeCenterCell*)[tableview cellForRowAtIndexPath:indexP];
        if (cell != nil) {
            [self handleExpansionCell:0 expCell:cell];
        }
    }
}

// 展开cell
- (void)handleExpansionCell:(float)cellY expCell:(SubscribeCenterCell*)cell{
    float headY = 40.f;
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    float  height = cell.frame.origin.y + tableview.frame.origin.y - tableview.contentOffset.y;
    if (currentShowCategory == indexPath.row) {// 做收缩处理
        currentShowCategory = NSNotFound;
        tableview.scrollEnabled = YES;
        
        float h = (tableview.frame.size.height -[SubscribeCenterCell cellHeight])/2 +tableview.frame.origin.y;
        if (indexPath.row == 0) {
            h = tableview.frame.origin.y;
        }else if (indexPath.row == [subsChannels count] - 1) {
            h = (tableview.frame.size.height - [SubscribeCenterCell cellHeight]) + tableview.frame.origin.y;
        }
        float footUnfoldHeight = tableview.frame.size.height - (h - tableview.frame.origin.y + [SubscribeCenterCell cellHeight]);
        
       
        [tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        // 刷新cell
        
        
        
        [UIView animateWithDuration:0.30f animations:^{
            
            shadowHead.frame = CGRectMake(0.0f, headY, tableview.frame.size.width, h-headY);
            shadowFoot.frame = CGRectMake(0.0f, h+[SubscribeCenterCell cellHeight], tableview.frame.size.width, footUnfoldHeight);
            [tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        } completion:^(BOOL finished) {
            [shadowHead setHidden:YES];
            [shadowFoot setHidden:YES];
        }];
    }
    else{   // 做展开处理
        float h = 0;        
        if (indexPath.row == 0) {
            h = tableview.frame.origin.y;
        }else if (indexPath.row == [subsChannels count] - 1) {
            h = (tableview.frame.size.height - [SubscribeCenterCell cellExtHeight]) + tableview.frame.origin.y;
        }else{
            h = (tableview.frame.size.height - [SubscribeCenterCell cellExtHeight])/2 + tableview.frame.origin.y;
        }
        [shadowHead setHidden:NO];
        [shadowFoot setHidden:NO];
        tableview.scrollEnabled = NO;
        currentShowCategory = indexPath.row;
        [cell setCellWillExpansion];
        [tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];        
        
        ///*
        float tempV = tableview.bounds.size.height - (cell.frame.origin.y - tableview.contentOffset.y);
        float footFoldHeight = tempV - cell.frame.size.height;
        float footUnfoldHeight = tableview.frame.size.height - (h - tableview.frame.origin.y + [SubscribeCenterCell cellExtHeight]);
        shadowHead.frame = CGRectMake(0.0f, headY, tableview.frame.size.width, height-headY);
        shadowFoot.frame = CGRectMake(0.0f, height+[SubscribeCenterCell cellHeight],
                                      tableview.frame.size.width, footFoldHeight);
        
        
        
        [UIView animateWithDuration:0.35f animations:^{            
            shadowHead.frame = CGRectMake(0.0f, headY +4.0, tableview.frame.size.width, h - headY - 4.0f);
            shadowFoot.frame = CGRectMake(0.0f, h+[SubscribeCenterCell cellExtHeight], tableview.frame.size.width, footUnfoldHeight);   
            
            [tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        } completion:^(BOOL finished) {            
            // 注意：函数参数中的cell 不可以用，这个是旧的cell ，
            // 上面代码调用过reloadRowsAtIndexPaths
            SubscribeCenterCell* tempCell = (SubscribeCenterCell*)[tableview cellForRowAtIndexPath:indexPath];
            if (tempCell != nil) { // 更新图片
                [self startDownloadImage:tempCell cellForRowAtIndexPath:indexPath];
            }
        }];
    }

}

// SubscribeCenterCellSubItem click , 打开订阅窗口
-(void)openSubsChannelView:(SubsChannel *)subsChannel{
    SubscribeViewController *svc = [SubscribeViewController new];
    svc.title = subsChannel.name;
    [svc setSubsChannel:subsChannel];
    [svc setShowBackButton:YES];
    [svc setShowSubscribeButton:YES];
    [self pushViewController:svc animated:YES];
}


#pragma mark 图片下载
//开始图片下载
- (void)startDownloadImage:(SubscribeCenterCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* array = [cell needDownloadImageChannels];
    if (array != nil && array.count > 0) {        
        for (SubsChannel* subsChannel in array) {
            [imgPool loadImage:indexPath subChannel:subsChannel];
        }        
    }    
}
// 加载屏幕范围内的图片
- (void)loadImagesForOnscreenRows
{
    if ([subsChannels count] > 0)
    {
        NSArray *cells = [tableview visibleCells];
        for (SubscribeCenterCell *cell in cells)
        {
            NSIndexPath* idxPath = [tableview indexPathForCell:cell];
            NSArray* array = [cell needDownloadImageChannels];
            if ([array count] > 0) {
                for (SubsChannel* subsChannel in array) {
                    [imgPool loadImage:idxPath subChannel:subsChannel];
                }
            }
        }
    }
}


- (void)appImageDidLoad:(NSIndexPath *)indexPath
            subsChannel:(SubsChannel*)channel
                  image:(UIImage *)img
{
    SubscribeCenterCell *cell = (SubscribeCenterCell *)[tableview cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        [cell updateImage:channel image:img];
    }
}


#pragma mark SubsChannelChangedObserver
-(void)subsChannelChanged{
    [gridView reloadView];
    NSArray *cells = [tableview visibleCells];
    for (UITableViewCell *cell in cells)
    {
        if ([cell isKindOfClass:[SubscribeCenterCell class]]) {
            [(SubscribeCenterCell*)cell checkSubscribeState];// 检查订阅状态
        }
    }
    
    // 搜索结果的更新    
    if (![searchResultView isHidden]) {
        [searchResultView checkSubsChannelState];
    }
}

#pragma mark Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
    if ([keyPath isEqualToString:@"heightOfView"] && !gridView.hidden) {
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect frame = subscribView.frame;
                             frame.origin.y = gridView.heightOfView + 5.0f;
                             frame.size.height = 748.0f - (gridView.heightOfView + 5.0f);
                             subscribView.frame = frame;
                             CGRect tableViewFrame = tableview.frame;
                             tableViewFrame.origin.y = kPaperTopY + 13.0f;
                             tableViewFrame.size.height = self.view.frame.size.height - kPaperTopY - kPaperBottomY - 13.0f - gridView.heightOfView;
                             tableview.frame = tableViewFrame;
                         }
                         completion:^(BOOL finished) {}
         ];
    }
}

- (void)dealloc
{
    [gridView removeObserver:self forKeyPath:@"heightOfView"];
}

@end
