//
//  SurfLeftController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//
#ifdef ipad
#import "SurfLeftController.h"
#import "ImageDownloader.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "AppDelegate.h"
#import "SurfRootViewController.h"


#define kMinTouchTime 1.5f
@interface SurfLeftController ()

@end

@implementation SurfLeftController

#define kHotNSIndexPath     [NSIndexPath indexPathForRow:0 inSection:0]
#define kCloudNSIndexPath   [NSIndexPath indexPathForRow:1 inSection:0]
#define kNewestNSIndexPath     [NSIndexPath indexPathForRow:2 inSection:0]
#define kSubsMoreNSIndexPath     [NSIndexPath indexPathForRow:0 inSection:2]
#define kSubscribeNSIndexPath     [NSIndexPath indexPathForRow:0 inSection:3]
@synthesize delegate;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = ViewTitleStateNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    UIImage *image = [[UIImage imageNamed:@"left_line_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:10];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, kSplitPositionMax, 768.0f-20.0f)];
    imageView.image = image;
    [self.view addSubview:imageView];

    UIImageView *titleImage = [[UIImageView alloc] initWithFrame: CGRectMake(kSplitPositionMin, 15.0f, 110, 30.0f)];
    titleImage.image = [UIImage imageNamed:@"surf_Title.png"];
    [self.view addSubview:titleImage];
    
    
    headerLogo = [UIButton buttonWithType:UIButtonTypeCustom];
    headerLogo.frame = CGRectMake(13.0f, 10.0f, 45.0f, 47.0f);
    [headerLogo addTarget:self action:@selector(changeSplitPosition) forControlEvents:UIControlEventTouchUpInside];
    [headerLogo setBackgroundImage:[UIImage imageNamed:@"default_Header"] forState:UIControlStateNormal];
    [headerLogo setBackgroundImage:[UIImage imageNamed:@"default_Header"] forState:UIControlStateHighlighted];
    [self.view addSubview:headerLogo];

    UIImageView *iconBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head_Icon.png"]];
    iconBg.frame = headerLogo.frame;
    [self.view addSubview:iconBg];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10,  713.0f, 49.0f, 25.0f);
    [btn addTarget:self action:@selector(changeSplitPosition) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"showBtn.png"] forState:UIControlStateNormal];
    [self.view addSubview:btn];

    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(kSplitPositionMax -35.0f,  713.0f, 25.0f, 25.0f);
    [settingBtn addTarget:self action:@selector(settingSurf) forControlEvents:UIControlEventTouchUpInside];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"settingBtn"] forState:UIControlStateNormal];
    [self.view addSubview:settingBtn];
    
    /*
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:longPress];
    [self reloadTableView];
    */


    
    
    maskBottomView = [[UIImageView alloc] initWithImage:
                      [UIImage imageNamed:@"splite_line_expand"]];
    
    maskTopView = [[UIImageView alloc] initWithImage:
                   [UIImage imageNamed:@"splite_line_expand"]];


    leftAllSubsView = [[LeftAllSubsView alloc] initWithFrame:CGRectMake(kSplitPositionMax ,
                                                               0.0f,
                                                               kSplitPositionLeftMax - kSplitPositionMax,
                                                               748.0f)];
    leftAllSubsView.delegate = self;
    
    UIPanGestureRecognizer * tapGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    tapGR.delegate = self;
    [self.view addGestureRecognizer: tapGR];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - touch
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.x >kSplitPositionMax) {
        return NO;
    }
    return YES;
}
-(void)btnLong:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView: self.view];
    float position = [self.delegate splitePositionInLeft:self];
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        canMove = NO;
    }
    else if ([sender state] == UIGestureRecognizerStateChanged )
    {
        if (point.x >= position || canMove) {
             canMove = YES;
            if (point.x < kSplitPositionMin)
            {
                [delegate splitePosition:kSplitPositionMin Animated:NO];
            }else
            {
                [delegate splitePosition:point.x Animated:NO];
            }
        }        
    }
    else if ([sender state] == UIGestureRecognizerStateCancelled ||[sender state] == UIGestureRecognizerStateEnded)
    {
        canMove = NO;
        if (position - kSplitPositionMin < (kSplitPositionMax -kSplitPositionMin)/2)
        {
            [delegate splitePosition:kSplitPositionMin Animated:YES];
        }
        else if(style != MGSplitDividerBeganStyleMax)
        {
            if (position - kSplitPositionMax > (kSplitPositionLeftMax -kSplitPositionMax)/3)
            {
                [delegate splitePosition:kSplitPositionLeftMax Animated:YES];
            }else
            {
                [delegate splitePosition:kSplitPositionMax Animated:YES];
            }
            
        }else
        {
            if (position - kSplitPositionMax < (kSplitPositionLeftMax -kSplitPositionMax)/3*2)
            {
                [delegate splitePosition:kSplitPositionMin Animated:YES];
            }else
            {
                [delegate splitePosition:kSplitPositionLeftMax Animated:YES];
            }
        }
    }
}
/*
-(void)btnLong:(UILongPressGestureRecognizer *)gestureRecognizer{
  
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {

        CGPoint point = [gestureRecognizer locationInView:self.view];
        CGPoint newPoint;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                newPoint =[self.view convertPoint:point toView:view];
                if (newPoint.x >kSplitPositionMax) {
                    break;
                }
                UITableView *tView = (UITableView *)view;
                if ([tView pointInside:newPoint withEvent:nil]) {
                    
                    
                    NSIndexPath *indexPath = [tView indexPathForRowAtPoint:newPoint];
                    LeftSubsChannelCell *cell = (LeftSubsChannelCell *)[tView cellForRowAtIndexPath:indexPath];
                    if (!cell) {
                        break;
                    }
                    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row inSection:tView.tag];
                    if (index.row == kSubsMoreNSIndexPath.row && index.section == kSubsMoreNSIndexPath.section)
                    {
                        break;
                    }
                    else if ([delegate splitePositionInLeft:self] == kSplitPositionLeftMax)
                    {
                        [delegate splitePosition:kSplitPositionMin Animated:NO];
                        maskTopView.hidden = YES;
                        maskBottomView.hidden = YES;
                    }
                    [selectCell isCurrent:NO];
                    
                    [cell isCurrent:YES];
                    selectCell = cell;
                    
                    [delegate didSelectRowAtIndexPath:index left:self];
                    beganTouchPosition = [self.delegate splitePositionInLeft:self];
                    if (beganTouchPosition == kSplitPositionMin) {
                        [self eventTouchChanged];
                    }

                    break;
                }
            }
        }
    }else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if (beganTouchPosition == kSplitPositionMin) {
            [self eventTouchCancel];
            beganTouchPosition = 0.0f;
        }

    }
     
}
*/
-(void)eventTouchChanged
{
    [delegate splitePosition:kSplitPositionMax Animated:NO];
}
-(void)eventTouchCancel
{
    [delegate splitePosition:kSplitPositionMin Animated:YES];
}
-(void)eventTouchInside
{
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(eventTouchCancel) object:nil];
    [self performSelector:@selector(eventTouchCancel) withObject:nil afterDelay:kMinTouchTime];
}
-(void)changeSplitPosition
{
    float position = [self.delegate splitePositionInLeft:self];
    if (position == kSplitPositionMax)
    {
        [delegate splitePosition:kSplitPositionMin Animated:YES];
    }
    else if (position == kSplitPositionMin)
    {
        [delegate splitePosition:kSplitPositionMax Animated:YES];    
    }
    else if (position == kSplitPositionLeftMax)
    {
        [delegate splitePosition:kSplitPositionMin Animated:YES];
    }
}
#pragma mark - reload
-(void)setDelegate:(id<SurfLeftControllerDelegate>)_delegate
{
    delegate = _delegate;

}
-(void)reloadTableView
{
    selectCell = nil;
    int section = [delegate numberOfSectionsInLeft:self];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            [view removeFromSuperview];
        }
    }
    if (section == 0) {
        return;
    }
    float y = 65;
    float splitPosition = [delegate splitePositionInLeft:self];
    if (splitPosition > kSplitPositionMax) {
        splitPosition = kSplitPositionMax;
    }
    for (int i = 0 ; i< section; i++) {
        float height = [delegate heightForTableViewInSection:i left:self];
        UITableView *tView = [[UITableView alloc] initWithFrame:CGRectMake(8.0f, y, 178.0f, height)
                                                          style:UITableViewStylePlain];
        tView.tag = i;
        tView.scrollEnabled = [delegate scrollViewCanMoveLeft:self numberOfRowsInSection:i];
        tView.dataSource = (id<UITableViewDataSource>)self;
        tView.backgroundColor = [UIColor clearColor];
        tView.delegate = (id<UITableViewDelegate>)self;
        tView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        tView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:tView];
        if (i == 0) {
            maskTopView.frame = CGRectMake(9.0f, y+height- 10.0f, splitPosition - 9.0f, 3);
            [self.view addSubview:maskTopView];
        }else if(i == 1){
            maskBottomView.frame = CGRectMake(9.0f, y+height - 10.0f, splitPosition - 9.0f, 3);
            [self.view addSubview:maskBottomView];
            y -= 10;
        }

        y = y + height;
        
    }

    [self.view addSubview:leftAllSubsView];
}
#pragma tableView
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [delegate numberOfRowsInSection:tableView.tag left:self];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [delegate numberOfAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:tableView.tag]
                                    left:self];
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"left_CellIdentifier";
    LeftSubsChannelCell *cell = (LeftSubsChannelCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[LeftSubsChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    cell.bgImageHidden = NO;
    if (tableView.tag == kHotNSIndexPath.section && indexPath.row == kHotNSIndexPath.row)
    {
        cell.desLabel.text = @"冲浪热推";
        cell.logoImage.image = [UIImage imageNamed:@"hotchanel_logo"];
        cell.deleteBtn.hidden = YES;
    }
    else if (tableView.tag == kCloudNSIndexPath.section && indexPath.row == kCloudNSIndexPath.row)
    {
        cell.desLabel.text = @"我的收藏";
        cell.logoImage.image = [UIImage imageNamed:@"fav_logo.png"];
        cell.deleteBtn.hidden = YES;
    }
    else if (tableView.tag == kNewestNSIndexPath.section && indexPath.row == kNewestNSIndexPath.row)
    {
        cell.desLabel.text = @"最近更新";
        cell.logoImage.image = [UIImage imageNamed:@"Sub_logo.png"];
        cell.deleteBtn.hidden = YES;
    }
    else if (tableView.tag == kSubscribeNSIndexPath.section && indexPath.row == kSubscribeNSIndexPath.row)
    {
        cell.desLabel.text = @"订阅中心";
        cell.logoImage.image = [UIImage imageNamed:@"add_SubBtn"];
        cell.bgImageHidden = NO;
        cell.deleteBtn.hidden = YES;
    }
    else if (tableView.tag == kSubsMoreNSIndexPath.section && indexPath.row == kSubsMoreNSIndexPath.row)
    {
        cell.desLabel.text = @"查看全部";
        cell.logoImage.image = [UIImage imageNamed:@"show_Sub"];
        cell.bgImageHidden = YES;
        cell.deleteBtn.hidden = YES;
    }    
    else
    {
        SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:tableView.tag];
        if ([[manager loadLocalSubsChannels] count] > 1) {
            cell.deleteBtn.hidden = NO;
        }else
        {
            cell.deleteBtn.hidden = YES;
        }

        SubsChannel *channel = [self.delegate scrollViewForChannel:self numberOfIndexPath:path];
        cell.channel = channel;
        cell.desLabel.text = channel.name;
        NSString *imagePath = [PathUtil pathOfSubsChannelLogo:channel];
        if ([FileUtil fileExists:imagePath]) {
            cell.logoImage.image = [UIImage imageWithContentsOfFile:imagePath];
        }else{
            ImageDownloadingTask *task = [ImageDownloadingTask new];
            DJLog(@"%@",channel.imageUrl);
            task.targetFilePath = imagePath;
            task.imageUrl = channel.imageUrl;
            [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                if(succeeded && idt != nil){
                    UIImage *img = [UIImage imageWithData:[idt resultImageData]];
                    // 通知图片发生改变
                    cell.logoImage.image = img;
                }
            }];
            ImageDownloader *downloader = [ImageDownloader sharedInstance];
            [downloader download:task];
        }        
    }
    NSIndexPath *currentIndex = [self.delegate currentIndex];
    BOOL select =(currentIndex.row == indexPath.row && currentIndex.section == tableView.tag);
    if (select) {
        selectCell = cell;
    }
    [cell isCurrent:select];
    
    return cell;
    
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row inSection:tableView.tag];
    if (index.row == kSubsMoreNSIndexPath.row && index.section == kSubsMoreNSIndexPath.section) {
        if ([delegate splitePositionInLeft:self] == kSplitPositionLeftMax)
        {
            [delegate splitePosition:kSplitPositionMin Animated:YES];
        }
        else
        {
            [delegate splitePosition:kSplitPositionLeftMax Animated:YES];
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(eventTouchCancel) object:nil];
        }
        return;
    }
    if ([delegate splitePositionInLeft:self] == kSplitPositionMin) {
        [self eventTouchChanged];
        [self eventTouchInside];
        
    }else if ([delegate splitePositionInLeft:self] == kSplitPositionLeftMax) 
    {
        [delegate splitePosition:kSplitPositionMin Animated:YES];
    }else
    {
        [self eventTouchInside];
    }
    [selectCell isCurrent:NO];
    
    LeftSubsChannelCell *cell = (LeftSubsChannelCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell isCurrent:YES];
    selectCell = cell;

    
    DJLog(@"%d %d",index.row,index.section);    

    [delegate didSelectRowAtIndexPath:index left:self];


}
#pragma mark - LeftAllSubsViewDelegate
-(void)singleTapDetected:(SubsChannel *)channel
{
    [delegate splitePosition:kSplitPositionMin Animated:YES];
        
    [selectCell isCurrent:NO];
    selectCell = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    [rootController.rightController didSelectRowAtSection:channel
                                                         :[NSIndexPath indexPathForRow:0 inSection:1]];
    [rootController setSplitPosition:kSplitPositionMin animated:YES];
}
-(void)managerSubs
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    [rootController changedSelectController:[NSIndexPath indexPathForRow:0 inSection:3]];
    [delegate splitePosition:kSplitPositionMin Animated:YES];
    [self performSelector:@selector(showMySubscribe) withObject:nil afterDelay:0.5f];
}
-(void)showMySubscribe
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    UINavigationController *navController = (UINavigationController *)rootController.rightController.selectedViewController;
    if ([[navController.topViewController class] isSubclassOfClass:[SubscribeCenterController class]]) {
        SubscribeCenterController *view = (SubscribeCenterController *)navController.topViewController;
        [view mySubscribe:nil];
    }
}
#pragma mark - reloadMaskView
-(void)reloadMaskView
{
    float splitPosition = [delegate splitePositionInLeft:self];
    if (splitPosition > kSplitPositionMax) {
        splitPosition = kSplitPositionMax;
    }
    maskTopView.frame = CGRectMake(9.0f,
                                   maskTopView.frame.origin.y,
                                   splitPosition - 9.0f, 3);
    maskBottomView.frame = CGRectMake(9.0f,
                                      maskBottomView.frame.origin.y,
                                      splitPosition - 9.0f, 3);

}
#pragma mark - setting
-(void)settingSurf
{
    if ([delegate splitePositionInLeft:self] >= kSplitPositionMax)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [delegate splitePosition:kSplitPositionMax Animated:NO];
        } completion:^(BOOL finished) {
            CATransition *t = [CATransition animation];
            t.subtype = kCATransitionFromRight;
            t.type = kCATransitionPush;
            t.duration = 0.3f;
            [self.navigationController.view.layer addAnimation:t forKey:@"Transition"];
            
            SurfSettingController *viewController = [[SurfSettingController alloc] init];
            [self.navigationController pushViewController:viewController animated:NO];
        }];
    }
}

-(void)loginAction
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    [rootController changedSelectController:[NSIndexPath indexPathForRow:1 inSection:0]];
    [self eventTouchCancel];
}

@end
#endif