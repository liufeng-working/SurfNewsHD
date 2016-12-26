//
//  PhoneSinaWeiboUserFriendsController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSinaWeiboUserFriendsController.h"

@implementation SinaWeiboUserFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, 15.0f, 20.0f, 20.0f)];
        [self.contentView addSubview:selectedView];
        
        avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(45.0f, 5.0f, 40.0f, 40.0f)];
        [self.contentView addSubview:avatarView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 15.0f, 200.0f, 20.0f)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:13.0f];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)setUserInfo:(SinaWeiboUserInfo *)userInfo
{
    //先设成默认值
    avatarView.image = nil;
    nameLabel.text = @"";
    [selectedView setImage:[UIImage imageNamed:@"unDilog"]];
    
    //赋值开始
    if (userInfo.isSelected) {
        [selectedView setImage:[UIImage imageNamed:@"dilog"]];
    } else {
        [selectedView setImage:[UIImage imageNamed:@"unDilog"]];
    }
    
    nameLabel.text = userInfo.name;
    
    //将头像文件存于临时文件夹的
    NSString *imgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.img",userInfo.uid]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { //图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:userInfo.profile_image_url];
        [task setUserData:userInfo];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
             if (succeeded && idt != nil && [idt.userData isEqual:userInfo]) {
                 avatarView.image = [UIImage imageWithData:[idt resultImageData]];
             }
         }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        avatarView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
    }
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        nameLabel.textColor = [UIColor whiteColor];
    } else {
        nameLabel.textColor = [UIColor colorWithHexString:@"999292"];
    }
}

@end

@implementation SinaWeiboUserFriendSelectedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 30.0f, 30.0f)];
        avatarView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self.contentView addSubview:avatarView];
    }
    return self;
}

- (void)setUserInfo:(SinaWeiboUserInfo *)userInfo
{
    //先设成默认值
    avatarView.image = nil;
    
    //将头像文件存于临时文件夹的
    NSString *imgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.img",userInfo.uid]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { //图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:userInfo.profile_image_url];
        [task setUserData:userInfo];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if (succeeded && idt != nil && [idt.userData isEqual:userInfo]) {
                avatarView.image = [UIImage imageWithData:[idt resultImageData]];
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        avatarView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
    }
}

@end

@implementation PhoneSinaWeiboUserFriendsController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        
        friends = [NSMutableArray new];
        selectedFriends = [NSMutableArray new];
        nextCursor = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"新浪微博联系人";
    
    float toolsBarHeight = 48.0f;
    CGRect tableViewRwct = CGRectMake(0, self.StateBarHeight, kContentWidth, kContentHeight - self.StateBarHeight - toolsBarHeight);
    tableView = [[UITableView alloc] initWithFrame:tableViewRwct style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    
    [self addBottomToolsBar];
    
    float selectedTableViewX = 78.0f;
    CGRect selectedTableViewRwct = CGRectMake(selectedTableViewX, self.view.frame.size.height - selectedTableViewX, toolsBarHeight, kContentWidth - selectedTableViewX * 2);
    selectedTableView = [[UITableView alloc] initWithFrame:selectedTableViewRwct style:UITableViewStylePlain];
    [selectedTableView.layer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [selectedTableView setTransform:CGAffineTransformMakeRotation(M_PI / -2)];
    [selectedTableView setFrame:CGRectMake(70.0f, self.view.frame.size.height - 3.0f, kContentWidth - selectedTableViewX * 2, 40.0f)];
    [selectedTableView setDelegate:self];
    [selectedTableView setDataSource:self];
    [selectedTableView setBackgroundColor:[UIColor clearColor]];
    selectedTableView.showsVerticalScrollIndicator = NO;
    selectedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:selectedTableView];
    
    [self loadFriendData];
}

- (void)loadFriendData
{
    if (isloading) {
        return;
    }
    
    isloading = YES;
    
    //SYZ -- 2014/08/11 关于微博这一块的请求请参照微博开放文档
    WeiboManager *manager = [WeiboManager sharedInstance];
    [manager getSinaWeiboUserFriendsWithCursor:nextCursor complete:^(BOOL success,
                                                                     NSArray *array,
                                                                     int cursor,
                                                                     int totalNum) {
        if (success) {
            [friends addObjectsFromArray:array];
            nextCursor = cursor;
            total = totalNum;
            isloading = NO;
            
            [tableView reloadData];
        } 
    }];
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    if (night) {
        verticalLineView.backgroundColor = [UIColor colorWithHexString:@"19191A"];
    } else {
        verticalLineView.backgroundColor = [UIColor colorWithHexString:@"DCDBDB"];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    if (tView == tableView) {
        return friends.count;
    } else {
        return selectedFriends.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tView == tableView) {
        NSString *cellIdentifier = @"user_cell";
        SinaWeiboUserFriendCell *cell = [tView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[SinaWeiboUserFriendCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                  reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            [cell applyTheme];
        }
        
        SinaWeiboUserInfo *info = [friends objectAtIndex:indexPath.row];
        [cell setUserInfo:info];
        
        return cell;
    } else {
        NSString *cellIdentifier = @"selected_cell";
        SinaWeiboUserFriendSelectedCell *cell = [tView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[SinaWeiboUserFriendSelectedCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                  reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        SinaWeiboUserInfo *info = [selectedFriends objectAtIndex:indexPath.row];
        [cell setUserInfo:info];
        
        return cell;
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tView == tableView) {
        [tableView deselectRowAtIndexPath:[tView indexPathForSelectedRow] animated:YES];
        
        SinaWeiboUserInfo *info = [friends objectAtIndex:indexPath.row];
        info.isSelected = !info.isSelected;
        if (info.isSelected && ![self theFriendIsSelected:info]) {
            [selectedFriends addObject:info];
        } else if (!info.isSelected && [self theFriendIsSelected:info]) {
            [selectedFriends removeObject:info];
        }
        [selectedTableView reloadData];
        [self refreshOKButtonTitle];
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:selectedFriends.count - 1 inSection:0];
        [selectedTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tView == tableView) {
        return 50.0f;
    }
    return 40.0f;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height &&
        total > friends.count) {
        [self loadFriendData];
    }
}

//返回好友是否已被选择
- (BOOL)theFriendIsSelected:(SinaWeiboUserInfo*)info
{
    for (SinaWeiboUserInfo *userInfo in selectedFriends) {
        if (userInfo.uid == info.uid) {
            return YES;
        }
    }
    return NO;
}

//刷新确定按钮的标题
- (void)refreshOKButtonTitle
{
    [okButton setTitle:[NSString stringWithFormat:@"确定(%@)", @(selectedFriends.count)]
              forState:UIControlStateNormal];
}

- (UIView *)addBottomToolsBar
{
    if (toolsBottomBar) {
        return toolsBottomBar;
    }
    toolsBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 47.0f,
                                                              self.view.frame.size.width, 47.0f)];
    toolsBottomBar.backgroundColor = self.view.backgroundColor;
    
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:(id)[[UIColor colorWithWhite:1.0f alpha:0.0] CGColor]];
    [colors addObject:(id)[[UIColor colorWithWhite:0.0f alpha:0.2] CGColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:CGRectMake(0, -3.0f, toolsBottomBar.frame.size.width, 4.0f)];
    gradient.colors = colors;
    
    [toolsBottomBar.layer insertSublayer:gradient atIndex:0];
    
    [self.view addSubview:toolsBottomBar];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 49.0f);
    [backButton setBackgroundImage:[UIImage imageNamed:@"backBar.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissBackController) forControlEvents:UIControlEventTouchUpInside];
    [toolsBottomBar addSubview:backButton];
    
    float lineH = 30.0f;
    verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(60.0f, self.view.frame.size.height - 38.0f, 1.0f, lineH)];
    [self.view addSubview:verticalLineView];
    
    float finishBtnW = 68.f, finishBtnH = 34.f;
    okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setBackgroundImage:[UIImage imageNamed:@"navBtnBG.png"]
                         forState:UIControlStateNormal];
    okButton.frame = CGRectMake(kContentWidth - finishBtnW - 10.0f, 7.0f, finishBtnW, finishBtnH);
    [okButton setTitle:@"确定(0)" forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [okButton addTarget:self action:@selector(selectFinished) forControlEvents:UIControlEventTouchUpInside];
    [toolsBottomBar addSubview:okButton];
    
    return toolsBottomBar;
}

- (void)selectFinished
{
    if (selectedFriends.count == 0) {
        [PhoneNotification autoHideWithText:@"您还没有选择要@的好友"];
        return;
    }
    
    [_delegate selectFriendsToShare:selectedFriends controller:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
